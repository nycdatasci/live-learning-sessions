#
# This is a R Shiny App for "A/B Testing with Permutation Test"
# You can run this application by clicking the 'Run App' button above.
# Find out more about Shiny at http://shiny.rstudio.com/
#

library(shiny)

source("functions.R")

# Define UI
ui = fluidPage(
    titlePanel("A/B Testing with Permutation Test"),
    sidebarLayout(
        sidebarPanel(
            numericInput("a_all", "Total count in A:", 
                         min = 1, max = 1000, value = 100),
            numericInput("a_yes", "Yes count in A:", 
                         min = 1, max = 1000, value = 30),
            numericInput("b_all", "Total count in B:", 
                         min = 1, max = 1000, value = 100),
            numericInput("b_yes", "Yes count in B:", 
                         min = 1, max = 1000, value = 20),
            numericInput("n_p", "Number of permutations", 
                         min = 1, max = 1000, value = 100)
        ),
        mainPanel(
            h4("A/B Test Observed Results"),
            tableOutput("res"),
            h4("Permutation Test Result"),
            plotOutput("densityPlot")
        )
    )
)

# Define server logic
server = function(input, output) {
    output$densityPlot = renderPlot({
        set.seed(1) # for reproducible results
        ab_permutation_test(input$a_all, input$b_all, 
                            input$a_yes, input$b_yes, input$n_p)
    })
    output$res = renderTable(
        {ab_test_results_df(input$a_all, input$b_all, 
                            input$a_yes, input$b_yes)},
        include.rownames = TRUE
    )
}

# Run the application 
shinyApp(ui = ui, server = server)
