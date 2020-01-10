#' Get user info
#'
#' Extract the user information from the **elicitator** MySQL database
#' stored on the server, and return them like a
#' [tibble][tibble::tibble-package].
#'
#' @note to access the database the following environmental variable must
#' be set-up:
#'
#'       - `USER_TEST`: username to access the **elicitator** MySQL
#'           database on the server
#'       - `PSW_TEST`: password to access **elicitator**
#'       - `TBL_KEY`: AES key used to encrypt the passwords on the
#'         **users** table of **elicitator**
#'
#' @param usr (chr) username
#' @param psw (chr) password
#'
#' @return a [tibble][tibble::tibble-package] including the following
#' user info from the **users** database (see the section Notes):
#'
#'   - `id_users`: the user's ID
#'   - `username`: the user's username
#'   - `name`: the user's name
#'   - `lastname`: the user's surname
#'   - `role`: the user's role group (1 = expert elicitator, 2 = admin)
#'
#' @examples
#' \dontrun{
#'     # On r-ubesp server
#'     psw <- Sys.getenv("USR_PSW")
#'
#'     get_usr("user_a", psw)
#'     get_usr("user_a", psw)
#'     get_usr("admin", psw)
#' }
get_usr <- function(usr, psw) {

    assertive::assert_is_a_string(usr)
    assertive::assert_is_a_string(psw)

    con <- DBI::dbConnect(RMySQL::MySQL(),
        host = "127.0.0.1",
        port = 3306,
        user = Sys.getenv("USER_TEST"),
        password = Sys.getenv("PSW_TEST"),
        dbname = "elicitator"
    )

    on.exit(DBI::dbDisconnect(con), add = TRUE)

    key <- Sys.getenv('TBL_KEY')

    sql_query <- dbplyr::build_sql(
        "SELECT * ",
        "FROM users WHERE username = '", dbplyr::ident_q(usr), "' ",
        "AND password = AES_ENCRYPT('",
            dbplyr::ident_q(psw), "', '",
            dbplyr::ident_q(key),
        "')",
        con = con
    )

    res <- DBI::dbSendQuery(con, sql_query)
    on.exit(DBI::dbClearResult(res), add = TRUE, after = FALSE)

    DBI::dbFetch(res) %>%
        dplyr::select(-"password") %>%
        tibble::as_tibble()
}
