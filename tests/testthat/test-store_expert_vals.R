usr <- "user_a"
psw <- Sys.getenv("USR_PSW")
vals <- 5:1

test_that("store_expert_vals return the correct class", {
    skip_on_ci()
    skip_on_cran()

    sev <- store_expert_vals(usr, psw, vals)

    expect_is(sev, "logical")
    expect_is(attr(sev, "time"), "POSIXct")
    expect_length(attr(sev, "time"), 1)
})


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
