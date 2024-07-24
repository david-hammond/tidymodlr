#' \code{tidymodlr}: Modelling with tidy long data
#'
#'
#' \code{tidymodlr} transforms long data into a matrix form to allow for ease
#' of input into modelling packages for regression, principal components,
#' imputation or machine learning.
#'
#' In many fields it is common to have data in tidy long data, with
#' the rows representing many #' variables, but only \strong{one}
#' column representing the values (see \code{?wb} for an example).
#'
#' \code{tidymodlr} is particularly useful when the indicator names in the
#' columns are long descriptive strings, for example
#' 'Energy imports, net (% of energy use)'.
#' In such cases a straight `pivot wider` generates column names that are
#' not only cumbersome, but also generate errors in many standard
#' modelling packages that require `base` column names.
#'
#'High level analysis functions for correlation, imputation and principals
#'components analysis are provided.
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL
