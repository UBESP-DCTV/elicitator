library(shiny)
library(shinyjs)
library(shinydashboard)

library(elicitator)

library(DT)
library(SHELF)


no_match <- function() {
    shinyjs::toggle("nomatch", anim = TRUE, animType = "fade", time = 1)

    shinyjs::delay(3000, shinyjs::toggle("nomatch",
        anim = TRUE, animType = "fade", time = 1
    ))
}
