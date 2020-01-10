#' Read last expert elicitated stored values
#'
#' Read the last stored elicitated values on the **opinions** table of
#' the **elicitator** MySQL database stored on the server.
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
#' informations from the **opinions** database (see the section Notes):
#'
#'     - `users_id`: the id of the user
#'     - `date_opinion`: the date in which the opinion was stored
#'     - `perc1`:  the 1th percentile elicitated
#'     - `perc25`: the 25th percentile elicitated
#'     - `perc50`: the 50th percentile elicitated
#'     - `perc75`: the 75th percentile elicitated
#'     - `perc99`: the 99th percentile elicitated
#'
#' @export
#' @examples
#' \dontrun{
#'     # On r-ubesp server
#'     psw <- Sys.getenv("USR_PSW")
#'
#'     last_stored_vals("user_a", psw)
#' }
last_stored_vals <- function(usr, psw) {

    assertive::assert_is_a_string(usr)
    assertive::assert_is_a_string(psw)

    usr_id <- get_usr(usr, psw)[["id_users"]] %>%
        as.character()

    if (!length(usr_id)) stop("Incorrect username or password!")

    con <- DBI::dbConnect(RMySQL::MySQL(),
        host = "127.0.0.1",
        port = 3306,
        user = Sys.getenv("USER_TEST"),
        password = Sys.getenv("PSW_TEST"),
        dbname = "elicitator"
    )

    on.exit(DBI::dbDisconnect(con), add = TRUE)

    sql_query <- dbplyr::build_sql(
        "SELECT * ",
        "FROM opinions ",
        "WHERE users_id = '", dbplyr::ident_q(usr_id), "'",
        con = con
    )

    res <- DBI::dbSendQuery(con, sql_query)
    on.exit(DBI::dbClearResult(res), add = TRUE, after = FALSE)

     DBI::dbFetch(res) %>%
        tibble::as_tibble()
}
