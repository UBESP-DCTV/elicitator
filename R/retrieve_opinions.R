#' Read all the experts elicitated stored values
#'
#' Read all the last stored elicitated values on the **opinions** table
#' of the **elicitator** MySQL database stored on the server.
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
#'     retrieve_opinion("user_a", psw)
#' }
retrieve_opinions <- function(usr, psw) {

    assertive::assert_is_a_string(usr)
    assertive::assert_is_a_string(psw)

    usr_role <- get_usr(usr, psw)[["role"]]

    if (!length(usr_role)) stop("Incorrect username or password!")
    if (usr_role != 2) stop("Only admins can use this function, sorry.")

    con <- DBI::dbConnect(RMySQL::MySQL(),
        host = "127.0.0.1",
        port = 3306,
        user = Sys.getenv("USER_TEST"),
        password = Sys.getenv("PSW_TEST"),
        dbname = "elicitator"
    )

    on.exit(DBI::dbDisconnect(con), add = TRUE)

    dplyr::tbl(con, "opinions") %>%
        dplyr::collect() %>%
        dplyr::group_by(users_id) %>%
        dplyr::filter(id_opinions == max(id_opinions)) %>%
        dplyr::left_join(
            dplyr::collect(dplyr::tbl(con, "users")),
            by = c("users_id" = "id_users")
        ) %>%
        dplyr::select(-"password")
}
