# ui.R
library(shiny)

shinyUI(fluidPage(
  titlePanel("Nifty 50 Stock Data Viewer"),
  sidebarLayout(
    sidebarPanel(
      selectInput("company", "Select Company:",
                  choices = c("Reliance" = "RELIANCE.NS", 
                              "TCS"      = "TCS.NS",
                              "Infosys"  = "INFY.NS")),
      dateRangeInput("dates", "Select Date Range:",
                     start = Sys.Date() - 30,
                     end   = Sys.Date())
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Company Chart", plotOutput("companyChart")),
        tabPanel("Comparison", plotOutput("comparisonPlot")),
        tabPanel("Stock vs Nifty", plotOutput("stockVsNifty"))
      )
    )
  )
))
