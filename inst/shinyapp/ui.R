header  <- dashboardHeader(title = "ElicitatoR", uiOutput("savesession"), uiOutput("logoutbtn"))
sidebar <- dashboardSidebar(uiOutput("sidebarpanel"))
body    <- dashboardBody(shinyjs::useShinyjs(), uiOutput("body"))

dashboardPage(header, sidebar, body, skin = "red")
