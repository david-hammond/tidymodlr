#' @title Creates a model matrix style R6 class for modelling with long tidy
#' data
#' @description
#' Creates a model matrix style R6 class for modelling with long tidy data
#'
#'
#' @importFrom R6 R6Class
#' @importFrom dplyr select left_join all_of rename arrange
#' @importFrom tidyr pivot_wider pivot_longer complete
#' @importFrom tm removePunctuation removeWords stopwords
#' @importFrom corrr correlate autoplot dice
#' @param df A tidy long data frame
#' @param pivot_column The column name on which the pivot will occur
#' @param pivot_value The column name of the values to be pivotted
#' @examples
#' data(wb)
#' mdl <- tidymodl$new(wb,
#'                    pivot_column = "indicator",
#'                   pivot_value = "value")
#' ### Use mdl$child for modelling
#' fit <- lm(data = mdl$child, gni ~ gcu + ppt)
#'
#' ### Can be used to add a yhat value for processed data
#'
#' nc <- ncol(mdl$child)
#' nr <- nrow(mdl$child)
#' dm <- nc * nr
#' dummy <- matrix(runif(dm),
#'                 ncol = nc) |>
#'                 data.frame()
#' names(dummy) = names(mdl$child)
#' tmp <- mdl$assemble(dummy)
#'
#' # In built correlation function
#' mdl$correlate()
#'
# In built principal components analysis function
#' tmp <- mdl$pca()
#' plot(tmp, choix = "var")
#'
#' @export
#'

tidymodl <- R6::R6Class("tidymodl",
  #' @description
  #' Creates a new instance of this [R6][R6::R6Class] class.
  #' @field data (`data.frame()`)\cr
  #'   The original tidy long data frame
  #' @field parent (`data.frame()`)\cr
  #'   The parent identifiers of the original data
  #' @field child (`data.frame()`)\cr
  #'   The model matrix version of the data
  #' @field key (`data.frame()`)\cr
  #'   A `key value` table that links the parent
  #'   and child data.frames.
  lock_objects = FALSE,
  public = list(
    data = NULL,
    parent = NULL,
    child = NULL,
    key = NULL,
    #' @description
    #' Create a new tidymodl object.
    #' @param df A tidy long data frame
    #' @param pivot_column The column name on which the pivot will occur
    #' @param pivot_value The column name of the values to be pivotted
    #' @return A new `tidymodl` object.
    initialize = function(df,
                          pivot_column,
                          pivot_value) {
      ##CHECK FOR DUPLICATIONS
      df <- as.data.frame(df)
      test <- duplicated(df |> select(-eval(pivot_value)))
      if(sum(test) > 0){
        print(df[test,])
        stop("You have duplicated data in your data.frame, check the above
             entires, fix and retry")
      }
      df[, pivot_column] <- factor(df[, pivot_column])
      self$data <- as.data.frame(df) |>
        arrange(eval(pivot_column))
      private$pivot_column <- pivot_column
      private$pivot_value <- pivot_value
      self$key <- make_key_value(self$data[, private$pivot_column])
      names(self$key)[2] <- private$pivot_column
      tmp <- private$.get_dm()
      self$child <- tmp$child
      self$parent <- tmp$parent
    },
    #' @description
    #' Adds a results matrix
    #' @param newdata A new data set to append. Needs to be either:
    #' \itemize{
    #' \item A vector of length equal to the number of rows in the model matrix.
    #' For example, the output of `predict()` of a `lm` model.
    #' In this case the function returns a data.frame of dimensions
    #' `c(nrow(parent), ncol(parent) + 1)`
    #' \item A data.frame/matrix of equal dimensions of the model matrix.
    #' For example, the output of `xgb_impute()`.
    #' In this case the function returns a data.frame of dimensions
    #' `c(nrow(data), ncol(data) + 1)`
    #' }
    #' @param format The desired format of the returned data frame, can either
    #' be "long" or "wide".
    #'
    #' @details
    #' This returns a completed data.frame for four use cases based on user
    #' preference of the desired format.
    #' \itemize{
    #' \item \strong{Format "long":}
    #' \itemize{
    #' \item \strong{Use Case 1 - "newdata" is a vector of length nrow(child):}
    #' The function returns a combined data frame of the parent data and the
    #' "newdata" in a new column. Useful when the user wants to append an
    #' output of, for example, `predict` for a `lm` regression model.
    #' \item \strong{Use Case 2 - "newdata" is a matrix of dimensions
    #' dim(child):} The function returns a data.frame of the original data in
    #' long format with the "newdata" in a new column. Useful when the user
    #' wants to append an output of, for example, `xgb_impute` for all original
    #' data.
    #' }
    #' \item \strong{Format "wide":}
    #' \itemize{
    #' \item \strong{Use Case 3 - "newdata" is a vector of length nrow(child):}
    #' The function returns a combined data frame of the parent data and the
    #' "newdata" in a new column. Useful when the user wants to append an
    #' output of, for example, `predict` for a `lm` regression model.
    #' \item \strong{Use Case 4 - "newdata" is a matrix of dimensions
    #' dim(child):} The function returns a data.frame of the original data in
    #' wide format with the "newdata" as replacing the child matrix of the
    #' original data. Useful when the user \emph{is only} interested in using
    #' the output of, for example, `xgb_impute` for all original data.
    #' }
    #' }
    #' @note Use Cases 1 and 3 return identical results.
    #' @return df A Data Frame
    assemble = function(newdata, format = "long") {
      ### Perform checks
      stopifnot("The `format` parameter needs to be either 'long' or 'wide'" =
                  format %in% c("long", "wide"))
      if (!is.null(newdata)) {
        if (is.null(dim(newdata))) {
          stopifnot("The length of the parameter `newdata` needs to be the same
                      as the number of rows in the matrix model" =
                      length(newdata) == nrow(self$child))
        }else {
          stopifnot("The dimensions of the parameter `newdata` needs to be the
            same as the dimensions of the matrix model" =
                      identical(dim(newdata),  dim(self$child)))
        }
      }
      parent <- self$parent |>
        cbind(self$child)
      if (format == "long") {
        parent <- parent |>
          pivot_longer(!eval(names(self$parent)),
                       names_to = "key",
                       values_to = private$pivot_value) |>
          left_join(self$key, by = "key") |>
          select(-key)
        parent <- parent[, c(names(self$data))]
        if (identical(dim(newdata), dim(self$child))) {
          child <- self$parent |>
            cbind(newdata)
          child <- child |>
            pivot_longer(!eval(names(self$parent)),
                         names_to = "key",
                         values_to = "yhat") |>
            left_join(self$key, by = "key") |>
            select(-key)
          child <- child[, c(setdiff(names(self$data),
                                     private$pivot_value),
                             "yhat")]
          parent <- parent |> left_join(child,
                                        by = c(names(self$parent),
                                               private$pivot_column))
          parent <- parent[, c(names(self$data), "yhat")]
        }
      } else {
        parent <- self$parent |>
          cbind(newdata)
      }
      return(parent)
    },
    #' @description
    #' Prints the key and the head matrix
    print = function() {
      cat("Key: \n")
      print(self$key)
      cat("Matrix: \n")
      print(head(self$child, 5))
    },
    #' @description
    #' Correlates and reutrns pearson values
    #' @return df A Correlation Matrix of class `cor_df` (see
    #' \href{https://CRAN.R-project.org/package=corrr}{corrr})
    correlate = function() {
      cat("Key: \n")
      print(self$key)
      x <- correlate(self$child)
      print(autoplot(x))
      return(x)
    },
    #' @description
    #' Provides high level principal components analysis
    #' @importFrom FactoMineR PCA
    #' @return df A principle components of class `PCA` (see
    #' \href{https://CRAN.R-project.org/package=FactoMineR}{FactoMineR}
    pca = function() {
      tmp <- PCA(self$child, graph = FALSE)
      return(tmp)
    }
  ),
  private = list(
    pivot_column = NULL,
    pivot_value = NULL,
    .get_dm = function() {
      parent_cols <- setdiff(names(self$data), c(private$pivot_column,
                                                 private$pivot_value))
      df <- self$data |>
        left_join(self$key, by = private$pivot_column) |>
        select(-all_of(private$pivot_column))
      df <- df |>
        pivot_wider(names_from = key,
                    values_from = eval(private$pivot_value))
      parent <- df |> select(eval(parent_cols))
      child <- df |> select(-eval(parent_cols))
      child <- child[, self$key$key]
      tmp <- list(parent = parent, child = child)
      return(tmp)
    }
  )
)

#' Generate a key value table with unique key for a set of text
#'
#' Given a vector of characters, this will return a data frame of
#' a unique `key` column (of, where possible, 3 characters) and `value`
#' column listing the unique elements of the original `text`.
#'
#' @param text The text to abbreviate and create a key value table for
#'
#' @examples
#' data(wb)
#' make_key_value(wb$indicator)
#' @return df A `Key Value` table
#' @export

make_key_value <- function(text) {
  text <- as.character(text)
  key <- data.frame(key = sort(tolower(unique(text))),
                    value = sort(unique(text)))
  key$key <- removePunctuation(key$key)
  key$key <- removeWords(key$key, words = stopwords())
  key$key <- abbreviate(key$key, minlength = 3)
  key$key <- make.names(key$key)
  key$key <- make.unique(key$key)
  key$key <- abbreviate(key$key, minlength = 3)
  key$key <- gsub("\\.", "", key$key)
  key$key <- factor(key$key, key$key, ordered = TRUE)
  return(key)
}
