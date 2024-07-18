test_that("returns df", {
  data(wb)
  mdl <- tidymodl$new(wb,
                       pivot_column = "indicator",
                       pivot_value = "value")

  nc <- ncol(mdl$child)
  nr <- nrow(mdl$child)
  dm <- nc*nr
  dummy = matrix(runif(dm),
           ncol = nc) |>
           as.data.frame()
  names(dummy) = names(mdl$child)
  tmp = mdl$assemble(dummy)
  expect_s3_class(tmp, "data.frame")
})

test_that("assemble works", {
  data(wb)
  mdl <- tidymodl$new(wb,
                      pivot_column = "indicator",
                      pivot_value = "value")
  tmp <- mdl$assemble(mdl$child)
  test <- identical(tmp$value, tmp$yhat)
  expect_true(test)
})

test_that("assemble preserves data", {
  data(wb)
  mdl <- tidymodl$new(wb,
                      pivot_column = "indicator",
                      pivot_value = "value")
  tmp <-  mdl$assemble()
  tmp <- tmp[!is.na(tmp$value),]
  tmp <- tmp |>
    rename(yhat = value)
  tmp <- tmp %>% left_join(mdl$data,
                          by = c('iso3c',
                                 'indicator',
                                 'year'))
  test <- all(tmp$yhat == tmp$value)
  expect_true(test)
})
