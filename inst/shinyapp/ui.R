header  <- dashboardHeader(title = "ElicitatoR", uiOutput("savesubmit"))
sidebar <- dashboardSidebar(uiOutput("sidebarpanel"))
body    <- dashboardBody(shinyjs::useShinyjs(), uiOutput("body"))

dashboardPage(header, sidebar, body, skin = "red")
