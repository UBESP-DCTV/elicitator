library(dplyr)

library(shiny)
library(shinyjs)
library(shinydashboard)

library(DT)
library(sodium)
library(SHELF)

# Main login screen
loginpage <- div(
    id    = "loginpage",
    style = "
        width: 500px;
        max-width: 100%;
        margin: 0 auto;
        padding: 20px;
    ",
    wellPanel(
        tags$h2("LOG IN",
          class = "text-center",
          style = "
              padding-top: 0;
              color:#333;
              font-weight:600;
          "
        ),
        textInput("usr",
          placeholder = "Username",
          label = tagList(icon("user"), "Username")
        ),
        passwordInput("psw",
          placeholder = "Password",
          label = tagList(icon("unlock-alt"), "Password")
        ),
        br(),
        div(
            style = "text-align: center;",
            actionButton("login",
                label = "SIGN IN",
                style = "
                    color: white;
                    background-color:#3c8dbc;
                    padding: 10px 15px;
                    width: 150px;
                    cursor: pointer;
                    font-size: 18px;
                    font-weight: 600;
                "
            ),
            hidden(div(
                id = "nomatch",
                style = "
                    color: red;
                    font-weight: 600;
                    padding-top: 5px;
                    font-size:16px;
                ",
                tags$p("Incorrect username or password!",
                    class = "text-center"
                )
            )),
            br(),
            br()
        )
    )
)


# users <- data.frame(
#     username = c("local", "local1"),
#     passod   = sapply(c("mypass", "mypass1"),password_store),
#     permission  = c("basic", "advanced"),
#     stringsAsFactors = FALSE
# )

header  <- dashboardHeader(title = "ElicitatoR", uiOutput("logoutbtn"))
sidebar <- dashboardSidebar(uiOutput("sidebarpanel"))
body    <- dashboardBody(shinyjs::useShinyjs(), uiOutput("body"))
ui      <- dashboardPage(header, sidebar, body, skin = "red")




# Server ----------------------------------------------------------

server <- function(input, output, session) {


  login <- FALSE
  USER <- reactiveValues(login = login)




  observe({
    if (!USER$login) {
      if (!is.null(input$login)) {
        if (input$login > 0) {
          Username <- isolate(input$usr)
          Password <- isolate(input$psw)
          if(length(which(users$username==Username))==1) {
            pasmatch  <- users["passod"][which(users$username==Username),]
            pasverify <- password_verify(pasmatch, Password)
            if(pasverify) {
              USER$login <- TRUE
              observe({
                updateTabItems(session, "tabs",selected = "dashboard")
              })
            } else {
              shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade")
              shinyjs::delay(3000, shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade"))
            }
          } else {
            shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade")
            shinyjs::delay(3000, shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade"))
          }
        }
      }
    }
  })

  output$logoutbtn <- renderUI({
    req(USER$login)
    tags$li(a(icon("fa fa-sign-out"), "Logout",
              href="javascript:window.location.reload(true)"),
            class = "dropdown",
            style = "background-color: #eee !important; border: 0;
            font-weight: bold; margin:5px; padding: 10px;")
  })

  output$sidebarpanel <- renderUI({
    if (USER$login == TRUE ){

      dashboardSidebar(
        sidebarMenu(id = "tabs",
          menuItem("Fit Expert Distribution", tabName = "dashboard", icon = icon("dashboard")
          ),
          menuItem("Help?", tabName = "widgets", icon = icon("dashboard")),
          #on the dashboard section the numeric imput panel has been also provided
          fluidPage(
            title = "Percentiles", status = "warning",
            "", br(), "",

            radioButtons(
              "Cond", "Bounded distribution?",
              c("No", "Yes" = "yes")
            ),


            conditionalPanel(
              condition = "input.Cond == 'yes'",
              h4("Bounds:"),
              numericInput("lower", "Lower Limit",  value = 2),
              numericInput("upper", "Upper Limit",  value = 100)

            ),
            h4("Percentiles:"),
            numericInput("slider", "Suggest a value x such that you are 1 % sure that X will be less than", value=10),
            numericInput("slider1", "Suggest a value x such that you are 25 % sure that X will be less than", value=30),
            numericInput("slider2", "Suggest a value x such that you are 50 % sure that X will be less than", value=40),
            numericInput("slider3", "Suggest a value x such that you are 75 % sure that X will be less than", value=50),
            numericInput("slider4", "Suggest a value x such that you are 99 % sure that X will be less than", value=80)

          )

        ))
    }
  })

  output$body <- renderUI({
    if (USER$login == TRUE ) {


      dashboardBody(
        tabItems(
          # First tab content
          tabItem(tabName = "dashboard",
                  fluidRow(
                    box(title = "Histogram", status = "primary", plotOutput("plot1", height = 350)),
                    box(title = "Best fit density", status = "primary", plotOutput("plot2", height = 350))


                  )
          ),

          # Second tab Help content
          tabItem(tabName = "widgets",
                  h2("Expert elicitation"),
                  h4("Eliciting a probability distribution is the process of extracting an expert’s beliefs about some unknown quantity of interest,
                     and representing his/her beliefs with a probability distribution. The challenges are, firstly, to help the expert consider uncertainty carefully,
                     without being excessively overconfident or underconfident, and secondly,
                     to find a way of constructing a full probability distribution based on a small number of simple probability judgements from the expert.
                     Elicitation can be used to construct prior distributions in Bayesian inference."),
                  h4(""),
                  h4("The function takes elicited probabilities corresponding to 1st, 25th, 50th, 75th and 99th percentiles as inputs,
                     and fits parametric distributions using least squares on the cumulative distribution function."),
                  h4(""),
                  h4("Computations have been performed using the SHELF[1] package in R[2] (version 3.6.2)."),
                  h2("References"),
                  h4("1. Gosling, J. P. (2018). SHELF: the Sheffield elicitation framework. In Elicitation (pp. 61-93). Springer, Cham."),
                  h4("2. Team, R. C. (2015). R Foundation for Statistical Computing; Vienna, Austria: 2014. R: A language and environment for statistical computing, 2013.")

                  )
          )
        )

    }
    else {
      loginpage
    }
  })

  p <- c(0.01, 0.25, 0.5, 0.75, 0.99)



  output$plot1 <- renderPlot({
    #set values corresponding to wuantiles defined in the input section
    v <- matrix(c(input$slider,input$slider1, input$slider2, input$slider3,input$slider4))
    #Fit the distribution

    myfit <- fitdist(vals = v, probs = p, lower =ifelse(input$Cond != 'yes',-Inf,input$lower),
                     upper =ifelse(input$Cond != 'yes',Inf,input$upper))
    # Plot a fitted Histogram distribution for expert and show 5th and 95th percentiles
    plotfit(myfit, d = "hist", ql = 0.05, qu = 0.95, ex = 2)
  })

  output$plot2 <- renderPlot({
    #set values corresponding to wuantiles defined in the input section

    v <- matrix(c(input$slider,input$slider1, input$slider2, input$slider3,input$slider4))
    #Fit the distribution


    myfit <- fitdist(vals = v, probs = p, lower =ifelse(input$Cond != 'yes',-Inf,input$lower),
                                          upper =ifelse(input$Cond != 'yes',Inf,input$upper))
    #
    # Plot a fitted Histogram distribution for expert and show 5th and 95th percentiles

    plotfit(myfit, d = "best", ql = 0.05, qu = 0.95, ex = 2)
  })


}


shinyApp(ui, server)
