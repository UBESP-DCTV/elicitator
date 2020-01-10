usr <- "user_a"
psw <- Sys.getenv("USR_PSW")

test_that("last_stored_vals return the correct class", {
    skip_on_ci()
    skip_on_cran()

    expect_is(last_stored_vals(usr, psw), "tbl_df")
})

test_that("last_stored_vals manage wrong input", {
    expect_error(
        last_stored_vals(1, psw),
        "usr is not of class 'character'"
    )

    expect_error(
        last_stored_vals(usr, 123),
        "psw is not of class 'character'"
    )

    expect_error(
        last_stored_vals("user_foo", psw),
        "Incorrect username or password!"
    )

    expect_error(
        last_stored_vals(usr, "foo"),
        "Incorrect username or password!"
    )

})



test_that("get_usr works properly", {
    skip_on_ci()
    skip_on_cran()

    sev <- store_expert_vals(usr, psw, c(1, 3, 5, 7, 11))
    lsv <- last_stored_vals(usr, psw)
    last_lsv <- lsv[lsv$id_opinions == max(lsv$id_opinions), ]

    expect_equal(
        strtrim(as.character(attr(sev, "time")), 10),
        last_lsv[["date_opinion"]][[1]]
    )
})



