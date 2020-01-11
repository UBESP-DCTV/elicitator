server <- function(input, output, session) {
  
  
  login_page <- div(
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
      checkboxInput("restore", "Restore last saved session"),
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
        br(),
        br(),
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
        ))
      )
      )
    )
  
  plot_page <- tabItem(tabName = "dashboard",
                       fluidRow(
                         column(width = 6,
                                renderText("Histogram"),
                                plotOutput("plot1")
                         ),
                         column(width = 6,
                                renderText("Best fit density"),
                                plotOutput("plot2")
                         )
                       )
  )
  
  tab_page <- tabItem(tabName = "admin_dashboard",
                      column(width = 12,
                             renderText("Data collected"),
                             dataTableOutput("opinions")
                      ),
                      column(width = 12,
                             renderText("Experts pooling density"),
                             plotOutput("plot3"),
                             downloadButton("report", "Generate elicitation report")
                             
                      )
  )
  
  help_page <- tabItem(tabName = "widgets",
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
  
  
  usr  <- reactiveValues(
    login = FALSE,
    type = "user"
  )
  
  observe({
    req(!usr$login) # Not yet logged in
    req(input$login) # clicked sign in
    
    usr_info  <- isolate(get_usr(input$usr, input$psw))
    usr_role  <- usr_info[["role"]]
    if (usr_role == 2) {
      usr$type <- "admin"
    }
    
    # Wrong log in credentials
    if (!nrow(usr_info)) {
      no_match()
    } else {
      usr$login <- TRUE
      observe(
        updateTabItems(session, "tabs", selected = "dashboard")
      )
    }
  })
  
  
  observe({
    req(usr$login)
    req(input$restore)
    
    
    isolate({
      old_values <- last_stored_vals(input$usr, input$psw)
      old_values <- old_values[
        old_values$id_opinions == max(old_values$id_opinions),
        c("perc1", "perc25", "perc50", "perc75", "perc99")
        ]
    })
    
    updateSliderInput(session, "slider1", value = old_values[[1]])
    updateSliderInput(session, "slider2", value = old_values[[2]])
    updateSliderInput(session, "slider3", value = old_values[[3]])
    updateSliderInput(session, "slider4", value = old_values[[4]])
    updateSliderInput(session, "slider5", value = old_values[[5]])
    
  })
  
  
  
  output$logoutbtn <- renderUI({
    req(usr$login)
    tags$li(
      a(icon("fa fa-sign-out"), "Logout",
        href = "javascript:window.location.reload(true)"
      ),
      class = "dropdown",
      style = "
      background-color: #eee !important;
      border: 0;
      font-weight: bold;
      margin:5px;
      padding: 10px;
      "
    )
  })
  
  output$savesession <- renderUI({
    req(usr$login)
    actionButton("save", label = "Save/Submit")
    
  })
  
  observeEvent(input$save, {
    store_expert_vals(input$usr, input$psw,
                      c(
                        input$slider1, input$slider2, input$slider3,
                        input$slider4, input$slider5
                      )
    )
    session$sendCustomMessage(type = 'testmessage',
                              message = 'Session saved.'
    )
  })
  
  
  output$sidebarpanel <- renderUI({
    req(usr$login)
    
    dashboardSidebar(
      sidebarMenu(id = "tabs",
                  menuItem("Fit Expert Distribution",
                           tabName = "dashboard",
                           icon = icon("dashboard")
                  ),
                  if (usr$type == "admin") {
                    menuItem("Admin dashboard",
                             tabName = "admin_dashboard",
                             icon = icon("dashboard")
                    )
                  },
                  menuItem("Help?",
                           tabName = "widgets",
                           icon = icon("dashboard")
                  ),
                  
                  #on the dashboard section the numeric imput panel has been also provided
                  fluidPage(title = "Percentiles",
                            status = "warning", "", br(), "",
                            
                            radioButtons("Cond",
                                         label = "Bounded distribution?",
                                         choices = c("No" = "no", "Yes" = "yes")
                            ),
                            
                            
                            conditionalPanel(
                              condition = "input.Cond == 'yes'",
                              
                              h4("Bounds:"),
                              
                              numericInput("lower",
                                           "Lower Limit",  value = 2),
                              numericInput("upper",
                                           "Upper Limit",  value = 100)
                            ),
                            
                            
                            h4("Percentiles:"),
                            sliderInput("slider1",
                                        label = "Suggest a value x such that you are 1 % sure that X will be less than",
                                        min = 0,
                                        max = 100,
                                        value = 10
                            ),
                            sliderInput("slider2",
                                        label = "Suggest a value x such that you are 25 % sure that X will be less than",
                                        min = 0,
                                        max = 100,
                                        value = 30
                            ),
                            sliderInput("slider3",
                                        label = "Suggest a value x such that you are 50 % sure that X will be less than",
                                        min = 0,
                                        max = 100,
                                        value = 40
                            ),
                            sliderInput("slider4",
                                        label = "Suggest a value x such that you are 75 % sure that X will be less than",
                                        min = 0,
                                        max = 100,
                                        value = 50
                            ),
                            sliderInput("slider5",
                                        label = "Suggest a value x such that you are 99 % sure that X will be less than",
                                        min = 0,
                                        max = 100,
                                        value = 80
                            )
                            
                  )
                  
      ))
  })
  
  
  
  
  output$body <- renderUI({
    
    if (usr$login && (usr$type == "user")) {
      dashboardBody(tabItems(plot_page, help_page))
    } else if (usr$login && (usr$type == "admin")) {
      dashboardBody(tabItems(plot_page, tab_page, help_page))
    } else if (!usr$login) {
      login_page
    }
    
  })
  
  
  
  probs <- c(0.01, 0.25, 0.5, 0.75, 0.99)
  
  output$plot1 <- renderPlot({
    
    vals <- matrix(c(
      input$slider1,
      input$slider2,
      input$slider3,
      input$slider4,
      input$slider5
    ))
    
    fit <- SHELF::fitdist(vals, probs,
                          lower = ifelse(input$Cond != 'yes', -Inf, input$lower),
                          upper = ifelse(input$Cond != 'yes', Inf, input$upper)
    )
    
    SHELF::plotfit(fit, d = "hist", ql = 0.05, qu = 0.95, ex = 2)
  })
  
  
  output$plot2 <- renderPlot({
    
    vals <- matrix(c(
      input$slider1,
      input$slider2,
      input$slider3,
      input$slider4,
      input$slider5
    ))
    
    fit <- SHELF::fitdist(vals, probs,
                          lower = ifelse(input$Cond != 'yes', -Inf, input$lower),
                          upper = ifelse(input$Cond != 'yes', Inf, input$upper)
    )
    SHELF::plotfit(fit, d = "best", ql = 0.05, qu = 0.95, ex = 2)
  })
  
  
  output$opinions <- DT::renderDT(
    retrieve_opinions(input$usr, input$psw)
  )
  
  output$plot3 <- renderPlot({
    opinion.db<-retrieve_opinions(input$usr, input$psw)
    opinion.db<-as.matrix(t(opinion.db[,c("perc1",
                                          "perc25",
                                          "perc50",
                                          "perc75",
                                          "perc99")]))
    
    poolfit <- SHELF::fitdist(vals = opinion.db, probs,
                              lower = ifelse(input$Cond != 'yes', -Inf, input$lower),
                              upper = ifelse(input$Cond != 'yes', Inf, input$upper))
    SHELF::plotfit(fit, d = "best", ql = 0.05, qu = 0.95,lp = TRUE)
  })
  
  output$report <- downloadHandler(
    
    filename = "report.html",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("report.Rmd", tempReport, overwrite = TRUE)
      
      # Set up parameters to pass to Rmd document
      params <- poolfit
      
      
      rmarkdown::render(tempReport, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
    }
  )
  
  }
