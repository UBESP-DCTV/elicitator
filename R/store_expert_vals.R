#' Store expert elicitated values
#'
#' Writes the elicitated values on the **opinions** table of the
#' **elicitator** MySQL database stored on the server.
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
#' @param vals (dbl) numerical vector of length five, containing, in
#' order, the elicitated values for the 1st, 25th, 50th, 75th, 99th
#' percentiles
#'
#' @return invisibly `TRUE`
#'
#' @export
#' @examples
#' \dontrun{
#'     # On r-ubesp server
#'     psw <- Sys.getenv("USR_PSW")
#'
#'     store_expert_vals("user_a", psw, 1:5)
#' }
store_expert_vals <- function(usr, psw, vals) {

    assertive::assert_is_numeric(vals)
    assertive::assert_is_of_length(vals, 5)

    usr_id <- get_usr(usr, psw)[["id_users"]] %>%
        as.character()

    if (!length(usr_id)) stop("Incorrect username or password!")

    now <- Sys.time() %>%
        as.character() %>%
        paste0("'", ., "'")

    con <- DBI::dbConnect(RMySQL::MySQL(),
        host = "127.0.0.1",
        port = 3306,
        user = Sys.getenv("USER_TEST"),
        password = Sys.getenv("PSW_TEST"),
        dbname = "elicitator"
    )

    on.exit(DBI::dbDisconnect(con), add = TRUE)

    key <- Sys.getenv('TBL_KEY')

    vals_c <- as.character(vals)
    sql_query <- dbplyr::build_sql(
        "INSERT ",
        "INTO opinions (",
        "users_id, date_opinion, ",
            "perc1, perc25, perc50, perc75, perc99",
        ") VALUES(",
            dbplyr::ident_q(as.character(usr_id)), ", ",
            dbplyr::ident_q(now), ", ",
            dbplyr::ident_q(vals_c),
        ");",
        con = con
    )
    sql_query
    res <- DBI::dbSendQuery(con, sql_query)
    on.exit(DBI::dbClearResult(res), add = TRUE, after = FALSE)
    invisible(TRUE)
}
