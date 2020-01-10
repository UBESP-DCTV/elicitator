usr <- "user_a"
psw <- Sys.getenv("USR_PSW")
vals <- 5:1

test_that("store_expert_vals return the correct class", {
    skip_on_ci()
    skip_on_cran()

    expect_is(store_expert_vals(usr, psw, vals), "logical")
})


# test_that("get_usr works properly", {
#     skip_on_ci()
#     skip_on_cran()
#
#     expect_equal(cl[["name"]], "Corrado")
#     expect_equal(cl[["role"]], 1)
#
#     expect_equal(none[["name"]], character(0))
#
#     expect_equal(dg[["name"]], "Dario")
#     expect_equal(dg[["role"]], 2)
# })


test_that("store_expert_vals manage wrong input", {
    expect_error(
        store_expert_vals(1, psw, vals),
        "usr is not of class 'character'"
    )

    expect_error(
        store_expert_vals(usr, 123, vals),
        "psw is not of class 'character'"
    )

    expect_error(
        store_expert_vals(usr, psw, "a"),
        "vals is not of class 'numeric'"
    )

    expect_error(
        store_expert_vals(usr, psw, 1:4),
        "vals has length 4, not 5"
    )

    expect_error(
        store_expert_vals("user_foo", psw, vals),
        "Incorrect username or password!"
    )

    expect_error(
        store_expert_vals(usr, "foo", vals),
        "Incorrect username or password!"
    )

})
