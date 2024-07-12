test_that("returns df", {
  data(wb)
  mdl <- tidymodl$new(wb,
                       pivot_column = "indicator",
                       pivot_value = "value")

  nc = ncol(mdl$mdldata)
  nr = nrow(mdl$mdldata)
  dm = nc*nr
  dummy = matrix(runif(dm),
           ncol = nc) |>
           as.data.frame()
  names(dummy) = names(mdl$mdldata)
  tmp = mdl$reconstitute(dummy)
  expect_s3_class(tmp, "data.frame")
})

test_that("reconstitute works", {
  data(wb)
  mdl <- tidymodl$new(wb,
                      pivot_column = "indicator",
                      pivot_value = "value")
  tmp = mdl$reconstitute(mdl$mdldata)
  test = identical(tmp$value, tmp$yhat)
  expect(test)
})
