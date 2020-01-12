usr <- "admin"
psw <- Sys.getenv("USR_PSW")

test_that("retrieval works", {
    skip_on_ci()
    skip_on_cran()

    store_expert_vals(usr, psw, c(1, 3, 5, 7, 11))
    store_expert_vals("user_a", psw, c(1, 3, 5, 7, 11))
    tbl <- retrieve_opinions(usr, psw)

    expect_is(tbl, "tbl_df")
    expect_equal(
        nrow(tbl),
        length(unique(tbl[["users_id"]]))
    )

    expect_equal(
        tbl[tbl$users_id == 5, ][["name"]],
        "Dario"
    )

    expect_identical(tbl, dplyr::ungroup(tbl))
})
