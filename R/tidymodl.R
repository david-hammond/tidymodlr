#' Creates a model matrix style R6 class for modelling with long tidy data
#'
#' Creates a model matrix style R6 class for modelling with long tidy data
#' @importFrom R6 R6Class
#' @importFrom dplyr select left_join all_of rename
#' @importFrom tidyr pivot_wider pivot_longer complete
#' @importFrom tm removePunctuation removeWords stopwords
#' @importFrom rlang .data
#' @param df A tidy long data frame
#' @param pivot_column The column name on which the pivot will occur
#' @param pivot_value The column name of the values to be pivotted
#' @examples
#' data(wb)
#' mdl <- tidymodl$new(wb,
#'                    pivot_column = "indicator",
#'                   pivot_value = "value")
#' ### Use mdldata for modelling
#' fit <- lm(data = mdl$child, gni ~ gcu + ppt)
#'
#' ### Can be used to add a yhat value for processed data
#'
#' ### This is useful for imputation purposes as below
#'
#' ### NOT RUN
#' # Use for xgboost imputation
#' # library(mixgb)
#' # imp <- mixgb(mdl$child, save.models = T)
#' # tmp <- mdl$assemble(newdata = imp$imputed.data[[1]])
#'
#' ### NOT RUN
#' # Use for mice imputation
#' # library(mice)
#' # imp <- mice(as.data.frame(scale(mdl$matrix)), print = FALSE)
#' # tmp <- mdl$assemble(complete(imp))
#'
#' ### In this example we will just use dummy new data
#' nc <- ncol(mdl$child)
#' nr <- nrow(mdl$child)
#' dm <- nc*nr
#' dummy <- matrix(runif(dm),
#'         ncol = nc) |>
#'         data.frame()
#' names(dummy) = names(mdl$child)
#' tmp = mdl$assemble(dummy)
#'

#' @export
#'

tidymodl <- R6::R6Class("tidymodl",
                            #' @description
                            #' Creates a new instance of this [R6][R6::R6Class] class.
                            #' @field data (`data.frame()`)\cr
                            #'   The original tidy long data frame
                            #' @field child (`data.frame()`)\cr
                            #'   The model matrix version of the data
                            lock_objects = FALSE,
                            public = list(
                              data = NULL,
                              child = NULL,
                              #' @description
                              #' Create a new tidymodl object.
                              #' @param df A tidy long data frame
                              #' @param pivot_column The column name on which the pivot will occur
                              #' @param pivot_value The column name of the values to be pivotted
                              #' @return A new `tidymodl` object.
                              initialize = function(df,
                                                    pivot_column,
                                                    pivot_value) {
                                self$data <- df
                                private$pivot_column <- pivot_column
                                private$pivot_value <- pivot_value
                                private$key <- private$.get_key()
                                tmp <- private$.get_dm()
                                self$child <- tmp$child
                                private$parent <- tmp$parent
                              },
                              #' @description
                              #' Adds a results matrix
                              #' @param newdata A results matrix
                              assemble = function(newdata = NULL) {
                                parent <- private$parent |>
                                  cbind(self$child)
                                parent <- parent |>
                                  pivot_longer(!eval(names(private$parent)),
                                               names_to = "hashkey",
                                               values_to = private$pivot_value) |>
                                  left_join(private$key, by = 'hashkey') |>
                                  select(-hashkey)
                                parent <- parent[, c(names(self$data))]
                                if(!is.null(newdata)){
                                  child <- private$parent |>
                                    cbind(newdata)
                                  child <- child |>
                                    pivot_longer(!eval(names(private$parent)),
                                                 names_to = "hashkey",
                                                 values_to = "yhat") |>
                                    left_join(private$key, by = 'hashkey') |>
                                    select(-hashkey)
                                  child <- child[, c(setdiff(names(self$data),
                                                             private$pivot_value),
                                                'yhat')]
                                  parent <- parent |> left_join(child,
                                                               by = c(names(private$parent),
                                                                      private$pivot_column))
                                  parent <- parent[, c(names(self$data),'yhat')]
                                }
                                return(parent)
                              },
                              #' @description
                              #' Prints the key and the head matrix
                              print = function() {
                                cat("Variable Key: \n")
                                print(private$key)
                                cat("Head Data Matrix: \n")
                                print(head(self$child, 5))
                              }
                            ),
                        private = list(
                          master = NULL,
                          key_ind = NULL,
                          key = NULL,
                          pivot_column = NULL,
                          pivot_value = NULL,
                          .get_key = function(){
                            key = data.frame(variable = unique(self$data[,private$pivot_column]),
                                             hashkey = apply(unique(self$data[,private$pivot_column]), 1, tolower))
                            names(key)[1] <- private$pivot_column
                            key$hashkey <- tm::removePunctuation(key$hashkey)
                            key$hashkey <- tm::removeWords(key$hashkey, words = stopwords())
                            key$hashkey <- abbreviate(key$hashkey, minlength = 3)
                            key$hashkey <- make.unique(key$hashkey)
                            return(key)
                          },
                          .get_dm = function(){
                            parent_cols <- setdiff(names(self$data), c(private$pivot_column, private$pivot_value))
                            df <- self$data |> left_join(private$key, by = private$pivot_column) |>
                              select(-all_of(private$pivot_column))
                            df <- df |>
                              pivot_wider(names_from = hashkey,
                                          values_from = eval(private$pivot_value))
                            parent <- df |> select(eval(parent_cols) )
                            child <- df |> select(-eval(parent_cols))
                            tmp <- list(parent = parent, child = child)
                            return(tmp)
                          }

                        )
)




