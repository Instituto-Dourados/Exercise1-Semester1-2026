#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(bslib)

source("../src/simulate_ode.R")
source("../src/solve_ode.R")



# Define UI for application that draws a plot
ui <- fluidPage(

  # Application title
  titlePanel("Exploring outcomes in mobility reduction"),

  ## Inputs 
  #
  # Recovery rate, rho
  sidebarLayout(
    
    # **** SIDEBAR ****
    sidebarPanel(
        h4("Intervention mixing parameters"),

          numericInput("c_JagBor",
                      "Jaguapiru-Bororó intergroup contact rate",
                      min = 0.000005,
                      max = 0.2,
                      value = 0.0001,
                      step = 0.00005),

          numericInput("gamma_Jag",
                      "Jaguapiru city infection rate",
                      min = 0.005,
                      max = 0.5,
                      value = 0.01,
                      step = 0.005),

        h4("Endogenous-only mixing parameters"),

          numericInput("c_Jag",
                      "Within-Jaguapiru contact rate:",
                      min = 0.005,
                      max = 0.5,
                      value = 0.075,
                      step = 0.005),

          numericInput("c_Bor",
                      "Within-Bororó contact rate",
                      min = 0.005,
                      max = 0.5,
                      value = 0.075,
                      step = 0.005),

          numericInput("gamma_Bor",
                      "Bororó city infection rate",
                      min = 0.005,
                      max = 0.5,
                      value = 0.075,
                      step = 0.005),

        h4("Epidemiological parameters"),

          numericInput("tau",
                      "Transmission rate:",
                      min = 0.005,
                      max = 0.5,
                      value = 0.075,
                      step = 0.005),

          numericInput("rho",
                      "Recovery rate:",
                      min = 0.005,
                      max = 0.9,
                      value = 0.1,
                      step = 0.005),

          numericInput("r",
                      "Reinfection rate:",
                      min = 0.005,
                      max = 0.5,
                      value = 0.0,
                      step = 0.005),

        h4("Population parameters"),
          numericInput("N_Jag" ,
                       "Jaguapiru Population",
                       min = 100, max = 20000, value = 9386, step = 150),
          numericInput("N_Bor",
                       "Bororó population",
                       min = 100, max = 20000, value = 8341, step = 150)
    ),
    
    # **** MAIN PANEL WITH CARDS ****
    mainPanel(
      # Show a plot of the generated distribution
      card(
        card_header("Explicit difference model"),
        # textOutput("rho_setting")
        plotOutput("explicit_plot"),
        fill = FALSE
      ),
      
      card(
        card_header("ODE model"),
        "*** TODO ***"
      )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) { 
  
  output$rho_setting <- renderText(input$rho)
  
  output$explicit_plot <- renderPlot({
    retdf <- simulate_two_group_sirs_noetnia_det(
      c_22 = input$c_Bor, gamma_1 = input$gamma_Jag, gamma_2 = input$gamma_Bor, 
      c_12 = input$c_JagBor, c_11 = input$c_Jag, 
      rho=input$rho, tau = input$tau,
      r = 0.0, nsteps = 500, N_1 = input$N_Jag, N_2 = input$N_Bor
    )
    
    plot_two_groups(retdf)
  })
}

  # retdf <- simulate_two_group_sirs_noetnia_det(
  #   c_22 = 0.0075, gamma_1 = 0.01, gamma_2 = 0.0, c_12 = 0.0001, 
  #   c_11 = 0.00025, tau = 0.002, rho=input$rho, r = 0.0, nsteps = 500)
  # 
  # output$dynamicsPlot <- renderPlot({
  #   plot_two_groups(retdf)
  # })
    
    # output$dynamicsPlot <- renderPlot({
    #     # generate bins based on input$bins from ui.R
    #     x    <- faithful[, 2]
    #     bins <- seq(min(x), max(x), length.out = input$bins + 1)
    # 
    #     # draw the histogram with the specified number of bins
    #     hist(x, breaks = bins, col = 'darkgray', border = 'white',
    #          xlab = 'Waiting time to next eruption (in mins)',
    #          main = 'Histogram of waiting times')
    # })
# }

# Run the application 
shinyApp(ui = ui, server = server)
