test_that("returns df", {
  data(wb)
  mdl <- tidymodl$new(wb,
                      pivot_column = "indicator",
                      pivot_value = "value")

  nc <- ncol(mdl$child)
  nr <- nrow(mdl$child)
  dm <- nc * nr
  dummy <- matrix(runif(dm),
                  ncol = nc) |>
    as.data.frame()
  names(dummy) <- names(mdl$child)
  tmp <- mdl$assemble(dummy)
  expect_s3_class(tmp, "data.frame")
})

test_that("assemble preserves data", {
  data(wb)
  mdl <- tidymodl$new(wb,
                      pivot_column = "indicator",
                      pivot_value = "value")
  tmp <-  mdl$assemble(mdl$child)
  test <- identical(tmp$yhat, tmp$value)
  expect_true(test)
})


test_that("correlate returns cor_df", {
  data(wb)
  mdl <- tidymodl$new(wb,
                      pivot_column = "indicator",
                      pivot_value = "value")
  tmp <-  mdl$correlate()
  expect_s3_class(tmp, 'cor_df')
})

test_that("xgb_impute returns df", {
  data(wb)
  mdl <- tidymodl$new(wb,
                      pivot_column = "indicator",
                      pivot_value = "value")
  tmp <-  mdl$xgb_impute()
  expect_s3_class(tmp, 'data.frame')
})

test_that("xgb_impute returns correct values", {
  data(wb)
  mdl <- tidymodl$new(wb,
                      pivot_column = "indicator",
                      pivot_value = "value")
  tmp <-  mdl$xgb_impute()
  tmp <- tmp[!is.na(tmp$value), ]
  test <- identical(round(tmp$value, 2), round(tmp$yhat, 2))
  expect_true(test)
})

test_that("pca_impute returns correct values", {
  data(wb)
  mdl <- tidymodl$new(wb,
                      pivot_column = "indicator",
                      pivot_value = "value")
  tmp <-  mdl$pca_impute()
  tmp <- tmp[!is.na(tmp$value), ]
  test <- identical(round(tmp$value, 2), round(tmp$yhat, 2))
  expect_true(test)
})

test_that("print works", {
  data(wb)
  mdl <- tidymodl$new(wb,
                      pivot_column = "indicator",
                      pivot_value = "value")
  expect_output(print(mdl), "Key")
})

test_that("error works 1", {
  data(wb)
  mdl <- tidymodl$new(wb,
                      pivot_column = "indicator",
                      pivot_value = "value")
  expect_error(mdl$assemble(1))
})

test_that("error works 2", {
  data(wb)
  mdl <- tidymodl$new(wb,
                      pivot_column = "indicator",
                      pivot_value = "value")
  expect_error(mdl$assemble(mdl$child[, -1]))
})

test_that("wide works 1", {
  data(wb)
  mdl <- tidymodl$new(wb,
                      pivot_column = "indicator",
                      pivot_value = "value")
  tmp <- mdl$assemble(mdl$child, format = "wide")
  test <- identical(dim(mdl$parent |> cbind(mdl$child)), dim(tmp))
  expect_true(test)
})

# test_that("wide works 2", {
#   data(wb)
#   mdl <- tidymodl$new(wb,
#                       pivot_column = "indicator",
#                       pivot_value = "value")
#   tmp <- mdl$assemble(mdl$child, format = "wide")
#   test <- identical(dim(mdl$parent |> cbind(mdl$child)), dim(tmp))
#   expect_true(test)
# })
