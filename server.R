library(shiny)
library(stringr)


shinyServer(function(input, output) {
  
  
  dataInput <- reactive({
    withProgress(message = 'Loading...', value = 0, {
      f = file(input$dataset$datapath, "rb")
      version = readBin(f, integer(), size = 1)
      nchar = readBin(f, integer(), size = 2)
      infoTextTemp = readChar(f, nchar)
      ret = str_split(infoTextTemp, ";")[[1]]
      nBits = readBin(f, integer(), size = 1)
      nBytes = readBin(f, integer(), size = 1)
      polarity = readBin(f, integer(), size = 1)
      userData = readBin(f, numeric(), 6, size = 4)
      sampRate = readBin(f, integer(), size = 4)
      ADrange = readBin(f, numeric(), size = 4)
      nPts = readBin(f, integer())
      eodwave = readBin(f, integer(), nPts, size = 2)
      close(f)
      return (
        list(
        temp = ret[4],
        specimen = ret[2],
        date = ret[1],
        species = ret[3],
        comment = ret[5],
        eodwave = eodwave,
        nPts = nPts,
        sampRate = sampRate,
        ADRange = ADrange
        )
      )
    })
  })
  
  
  output$startTimer <- renderUI({
    if(is.null(input$dataset)) {
      return()
    }
    
    datatable<-dataInput()
    sliderInput("startTime", "Start", min=0, max=datatable$nPts/datatable$sampRate, value = 0)
  })
  
  
  output$endTimer <- renderUI({
    if(is.null(input$dataset)) {
      return()
    }

    datatable<-dataInput()
    sliderInput("endTime", "End", min=0, max=datatable$nPts/datatable$sampRate, value = datatable$nPts/datatable$sampRate)
  })
  
  
  output$ADrage <- renderUI({
    if(is.null(input$dataset)) {
      return()
    }
    
    datatable<-dataInput()
  })
  
  output$distPlot <- renderPlot({
    if(is.null(input$dataset)) {
      return()
    }
    datatable<-dataInput()
    x = 1:datatable$nPts/datatable$sampRate
    y = datatable$eodwave
    if(!is.null(input$startTime)) {
      r=x>input$startTime
      x = x[r]
      y = y[r]
    }
    if(!is.null(input$endTime)) {
      r=x<input$endTime
      x = x[r]
      y = y[r]
    }
    plot(x, y, type='l', ylab='Volts', xlab='Time')
  })
  


})
