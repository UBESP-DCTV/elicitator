psw <- Sys.getenv("USR_PSW")

test_that("get_usr return the correct class", {
    skip_on_ci()
    skip_on_cran()

    cl <- get_usr("user_a", psw)
    none <- get_usr("user", psw)
    dg <- get_usr("admin", psw)

    expect_is(cl, "tbl_df")
    expect_is(none, "tbl_df")
    expect_is(dg, "tbl_df")
})


test_that("get_usr works properly", {
    skip_on_ci()
    skip_on_cran()

    cl <- get_usr("user_a", psw)
    none <- get_usr("user", psw)
    dg <- get_usr("admin", psw)

    expect_equal(cl[["name"]], "Corrado")
    expect_equal(cl[["role"]], 1)

    expect_equal(none[["name"]], character(0))

    expect_equal(dg[["name"]], "Dario")
    expect_equal(dg[["role"]], 2)
})

test_that("get_usr do not return password", {
    skip_on_ci()
    skip_on_cran()

    cl <- get_usr("user_a", psw)
    none <- get_usr("user", psw)
    dg <- get_usr("admin", psw)

    expect_equal(cl[["password"]], NULL)
    expect_equal(none[["password"]], NULL)
    expect_equal(dg[["password"]], NULL)
})


test_that("get_usr manage wrong input", {
    expect_error(
        get_usr(1, psw),
        "usr is not of class 'character'"
    )

    expect_error(
        get_usr("user_a", 123),
        "psw is not of class 'character'"
    )
})

