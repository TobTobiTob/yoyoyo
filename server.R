# server.R
library(shiny)
library(quantmod)

shinyServer(function(input, output, session) {
  
  # Reactive: Fetch the selected company's data from Yahoo Finance
  companyData <- reactive({
    req(input$company, input$dates)
    getSymbols(input$company,
               src = "yahoo",
               from = input$dates[1],
               to   = input$dates[2],
               auto.assign = FALSE)
  })
  
  # Reactive: Fetch the Nifty index data from Yahoo Finance
  niftyData <- reactive({
    req(input$dates)
    getSymbols("^NSEI",
               src = "yahoo",
               from = input$dates[1],
               to   = input$dates[2],
               auto.assign = FALSE)
  })
  
  # Tab 1: Company Chart - Displays a candlestick chart for the selected company
  output$companyChart <- renderPlot({
    chartSeries(companyData(),
                name  = input$company,
                theme = chartTheme("white"))
  })
  
  # Tab 2: Comparison - Shows normalized performance for both the company and Nifty index
  output$comparisonPlot <- renderPlot({
    comp  <- companyData()
    nifty <- niftyData()
    
    # Extract Adjusted Close prices
    compClose  <- Ad(comp)
    niftyClose <- Ad(nifty)
    
    # Normalize function: sets the first available price to 100
    normalize <- function(x) {
      x / as.numeric(first(x)) * 100
    }
    
    compNorm  <- normalize(compClose)
    niftyNorm <- normalize(niftyClose)
    
    # Merge the normalized series
    combined <- merge(compNorm, niftyNorm, all = FALSE)
    colnames(combined) <- c("Company", "Nifty")
    
    # Plot the normalized series on the same chart
    plot.zoo(combined,
             plot.type = "single",
             col       = c("blue", "red"),
             xlab      = "Date",
             ylab      = "Normalized Price",
             main      = "Normalized Performance")
    legend("topleft",
           legend = c("Company", "Nifty"),
           col    = c("blue", "red"),
           lty    = 1, bty = "n")
  })
  
  # Tab 3: Stock vs Nifty - Displays two line plots with dual Y-axes:
  # Left axis (red) for the Nifty index and right axis (blue) for the company stock.
  output$stockVsNifty <- renderPlot({
    comp  <- companyData()
    nifty <- niftyData()
    
    # Extract Adjusted Close prices
    compClose  <- Ad(comp)
    niftyClose <- Ad(nifty)
    
    # Check if data is available
    if (length(compClose) == 0 || length(niftyClose) == 0) return()
    
    # Plot Nifty data on left axis in red
    plot(index(niftyClose),
         as.numeric(niftyClose),
         type = "l",
         col  = "red",
         xlab = "Date",
         ylab = "Nifty Price",
         main = "Stock vs Nifty (Dual Axis)")
    
    # Overlay company stock data on the right axis in blue
    par(new = TRUE)
    plot(index(compClose),
         as.numeric(compClose),
         type  = "l",
         col   = "blue",
         axes  = FALSE,
         xlab  = "",
         ylab  = "")
    axis(side = 4, col.axis = "blue", col = "blue")
    mtext("Stock Price", side = 4, line = 3, col = "blue")
    
    # Add legend
    legend("topleft",
           legend = c("Nifty", "Stock"),
           col    = c("red", "blue"),
           lty    = 1, bty = "n")
  })
})
