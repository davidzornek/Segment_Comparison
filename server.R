shinyServer(function(input, output) {

# Filter Data According to User Input
    
  Top_Filter <- reactive({
    data %>%
      filter(if(!is.null(input$Benefit_State_Filter)){Benefit_State %in% input$Benefit_State_Filter} else {1==1},
             if(!is.null(input$Policy_Year_Filter)){Policy_Year %in% input$Policy_Year_Filter} else {1==1},
             if(!is.null(input$LOB_Parent_Filter)){LOB_Parent %in% input$LOB_Parent_Filter} else {1==1},
             if(!is.null(input$LOB_Filter)){LOB %in% input$LOB_Filter} else {1==1}
      )
  })
  
  Exposure_Filter <- reactive({
    exposures %>% 
      filter(if(!is.null(input$Benefit_State_Filter)){Benefit_State %in% input$Benefit_State_Filter} else {1==1},
             if(!is.null(input$Policy_Year_Filter)){Policy_Year %in% input$Policy_Year_Filter} else {1==1},
             if(!is.null(input$LOB_Parent_Filter)){LOB_Parent %in% input$LOB_Parent_Filter} else {1==1},
             if(!is.null(input$LOB_Filter)){LOB %in% input$LOB_Filter} else {1==1}
      )
  })
  
  ###############################################################################################################
  ## Settlement Rate
  ###############################################################################################################
  output$Settlement_Rate_LOB <- renderUI({
    selectizeInput("Settlement_Rate_LOB_Selection", "Select LOBs to compare",
                   choices = c(unique(Top_Filter()$LOB)),
                   selected = NULL, multiple = TRUE)
  })
  
  Settlement_Rate_Data <- reactive({
    
    d <- as.POSIXlt(Current_Eval)
    d$year <- d$year - 5
    Oldest_Date = as.Date(d)
    
    Dates <- seq(from = Oldest_Date, to = Current_Eval, by = "year")
    
    if(!is.null(input$Settlement_Rate_LOB_Selection)){
      temp <- Top_Filter() %>% 
        filter(LOB %in% input$Settlement_Rate_LOB_Selection) %>% 
        group_by(Evaluation_Date,LOB) %>% 
        summarise(Cumulative_Closed_Count = sum(Claim_Status == 'C'),
                  Cumulative_Reported_Count = sum(Claim_Status %in% c('C','O')),
                  Open_Count = sum(Claim_Status %in% c('C','O')) - sum(Claim_Status == 'C')
        ) %>% 
        mutate(LOB = ifelse(is.na(LOB),"Unkown",LOB))
      
      temp2 <- data.frame(LOB = unique(temp$LOB))
      
      Period_1 <- left_join(temp2, filter(temp, Evaluation_Date == Dates[1]))
      Period_2 <- left_join(temp2, filter(temp, Evaluation_Date == Dates[2]))
      Period_3 <- left_join(temp2, filter(temp, Evaluation_Date == Dates[3]))
      Period_4 <- left_join(temp2, filter(temp, Evaluation_Date == Dates[4]))
      Period_5 <- left_join(temp2, filter(temp, Evaluation_Date == Dates[5]))
      Period_6 <- left_join(temp2, filter(temp, Evaluation_Date == Dates[6]))
      
      temp3 <- data.frame(matrix(nrow = nrow(temp2), ncol = 5))
      names(temp3) <- Dates[2:6]
      rownames(temp3) <- temp2$LOB
      
      temp3[1] <- round((Period_2[,3] - Period_1[,3])/(Period_1[,5] + Period_2[,4] - Period_1[,4]), digits = 2)
      temp3[2] <- round((Period_3[,3] - Period_2[,3])/(Period_2[,5] + Period_3[,4] - Period_2[,4]), digits = 2)
      temp3[3] <- round((Period_4[,3] - Period_3[,3])/(Period_3[,5] + Period_4[,4] - Period_3[,4]), digits = 2)
      temp3[4] <- round((Period_5[,3] - Period_4[,3])/(Period_4[,5] + Period_5[,4] - Period_4[,4]), digits = 2)
      temp3[5] <- round((Period_6[,3] - Period_5[,3])/(Period_5[,5] + Period_6[,4] - Period_5[,4]), digits = 2)
      
      as.data.frame(t(temp3))
    } else {
      temp <- Top_Filter() %>% 
        group_by(Evaluation_Date) %>% 
        summarise(Cumulative_Closed_Count = sum(Claim_Status == 'C'),
                  Cumulative_Reported_Count = sum(Claim_Status %in% c('C','O')),
                  Open_Count = sum(Claim_Status %in% c('C','O')) - sum(Claim_Status == 'C')
        )
      
      Period_1 <- filter(temp, Evaluation_Date == Dates[1])
      Period_2 <- filter(temp, Evaluation_Date == Dates[2])
      Period_3 <- filter(temp, Evaluation_Date == Dates[3])
      Period_4 <- filter(temp, Evaluation_Date == Dates[4])
      Period_5 <- filter(temp, Evaluation_Date == Dates[5])
      Period_6 <- filter(temp, Evaluation_Date == Dates[6])
      
      temp3 <- data.frame(matrix(nrow = 1, ncol = 5))
      names(temp3) <- Dates[2:6]
      rownames(temp3) <- "Overall Settlement Rate"
      
      temp3[1] <- round((Period_2[,2] - Period_1[,2])/(Period_1[,4] + Period_2[,3] - Period_1[,3]), digits = 2)
      temp3[2] <- round((Period_3[,2] - Period_2[,2])/(Period_2[,4] + Period_3[,3] - Period_2[,3]), digits = 2)
      temp3[3] <- round((Period_4[,2] - Period_3[,2])/(Period_3[,4] + Period_4[,3] - Period_3[,3]), digits = 2)
      temp3[4] <- round((Period_5[,2] - Period_4[,2])/(Period_4[,4] + Period_5[,3] - Period_4[,3]), digits = 2)
      temp3[5] <- round((Period_6[,2] - Period_5[,2])/(Period_5[,4] + Period_6[,3] - Period_5[,3]), digits = 2)
      
      as.data.frame(t(temp3))
    }
  })
  
  output$Settlement_Rate_Graph <- renderChart2({
    
    d <- as.POSIXlt(Current_Eval)
    d$year <- d$year - 5
    Oldest_Date = as.Date(d)
    
    Dates <- seq(from = Oldest_Date, to = Current_Eval, by = "year")
    
    s <- Highcharts$new()
    
    s$exporting(enabled = TRUE)
    
    s$xAxis(title = list(text = "Date", style = list(fontWeight = "bold")), categories = as.list(as.character(Dates)))
    
    s$yAxis(title = list(text = "Claim Closure Rate", style = list(fontWeight = "bold")))
    
    for(i in 1:ncol(Settlement_Rate_Data())){
      s$series(name = names(Settlement_Rate_Data())[i], type = 'spline', data = as.list(Settlement_Rate_Data()[,i]))
    }
    
    return(s)
    
  })
  
  ###############################################################################################################
  ## 2D Tables
  ###############################################################################################################
  
  Segmented_Count <- reactive({
    
    Filter_Criteria <- interp(~ !is.na(which_column), which_column = as.name(input$Column_2D))
    
    temp <- data %>% 
      mutate(Closed_Count = ifelse(Claim_Status == 'C', 1, 0),
             Reported_Count = ifelse(Claim_Status %in% c('C','O'), 1, 0)
      ) %>% 
     select_(input$Row_2D, input$Column_2D, "Reported_Count") %>% 
      group_by_(input$Row_2D, input$Column_2D) %>% 
      summarise(Reported_Count = sum(Reported_Count, na.rm = TRUE)) %>% 
      filter_(Filter_Criteria) %>% 
      spread_(input$Column_2D, "Reported_Count")
  })
  
  output$Reported_Count_2D <- DT::renderDataTable({
    datatable(Segmented_Count(), rownames = FALSE, options = list(scrollX = TRUE))
  })
  
  Segmented_Severity <- reactive({
    
    Filter_Criteria <- interp(~ !is.na(which_column), which_column = as.name(input$Column_2D))
    
    temp <- data %>% 
      mutate(Closed_Count = ifelse(Claim_Status == 'C', 1, 0),
             Reported_Count = ifelse(Claim_Status %in% c('C','O'), 1, 0)
      ) %>% 
      group_by_(input$Row_2D, input$Column_2D) %>% 
      summarise(Reported_Count = sum(Reported_Count, na.rm = TRUE),
                Incurred_Severity = sum(Net_Incurred, na.rm = TRUE)) %>%
      mutate(Incurred_Severity = round(Incurred_Severity/Reported_Count), digits = 2) %>% 
      select_(input$Row_2D, input$Column_2D, "Incurred_Severity") %>% 
      filter_(Filter_Criteria) %>% 
      spread_(input$Column_2D, "Incurred_Severity")
  })
  
  output$Incurred_Severity_2D <- DT::renderDataTable({
    datatable(Segmented_Severity(), rownames = FALSE, options = list(scrollX = TRUE))
  })
  
})