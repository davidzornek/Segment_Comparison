dashboardPage(dashboardHeader(title = "Mini Dashboard"),
              dashboardSidebar(
                withTags({
                  div(h5("This app demonstrates a small sample of exhibits used in an insurance claim data dashboard. The filters below will affect the data flowing through to the entire dashboard, across both modules.", align = "center"),
                      br()
                  )
                }),
                
                selectizeInput(
                  'Benefit_State_Filter', 'Select States to View:',
                  choices = c("Alabama"="AL", "Alaska"="AK", "Arizona"="AZ", "Arkansas"="AR", "California"="CA",
                              "Colorado"="CO", "Connecticut"="CT", "Delaware"="DE", "District of Columbia"="DC", "Florida"="FL",
                              "Georgia"="GA", "Hawaii"="HI", "Idaho"="ID", "Illinois"="IL", "Indiana"="IN", "Iowa"="IA", "Kansas"="KS", 
                              "Kentucky"="KY", "Louisiana"="LA", "Maine"="ME", "Maryland"="MD", "Massachusetts"="MA", "Michigan"="MI", 
                              "Minnesota"="MN", "Mississippi"="MS", "Missouri"="MO", "Montana"="MT", "Nebraska"="NE", "Nevada"="NV", 
                              "New Hampshire"="NH", "New Jersey"="NJ", "New Mexico"="NM", "New York"="NY", "North Carolina"="NC", 
                              "North Dakota"="ND", "Ohio"="OH", "Oklahoma"="OK", "Oregon"="OR", "Pennsylvania"="PA", 
                              "Rhode Island"="RI", "South Carolina"="SC", "South Dakota"="SD", "Tennessee"="TN", "Texas"="TX", 
                              "Utah"="UT", "Vermont"="VT", "Virginia"="VA", "Washington"="WA", "West Virginia"="WV", "Wisconsin"="WI", 
                              "Wyoming"="WY"),
                  selected = NULL,
                  multiple = TRUE
                ),
                selectInput("Policy_Year_Filter", label = "Filter by Policy Year beginning 4/1",
                            choices = sort(unique(data$Policy_Year)), selected = NULL, selectize = TRUE, multiple = TRUE),
                selectInput("LOB_Parent_Filter", label = "Filter by LOB Parent",
                            choices = sort(unique(data$LOB_Parent)), selected = NULL, selectize = TRUE, multiple = TRUE),
                selectInput("LOB_Filter", label = "Filter by LOB",
                            choices = sort(unique(data$LOB)), selected = NULL, selectize = TRUE, multiple = TRUE)
              ),
              dashboardBody(
                tabsetPanel(
                  tabPanel("Settlement Rate",
                           br(),
                           column(4,
                                  uiOutput("Settlement_Rate_LOB")),
                           column(8,
                                  br(),
                                  div("This module allows the user to compare time series for a statistic across multiple segments. In this example, the user can compare claim closure rate over time across business units. When no business units are selected, the overall claim closure rate is shown; an alternate version retains the overall claim closure rate even when business units are selected. The icon in the upper right hand corner of the plot allows the user to export the plot in various file formats for use in other applications. The business units available to select are dynamically dependent on the filters input in the sidebar."),
                                  br()),
                           br(),
                           showOutput("Settlement_Rate_Graph", "highcharts")
                  ),
                  tabPanel("2D Tables",
                           column(4,
                             selectInput("Row_2D", "Row Selection",
                                         choices = c("Report Lag"="Report_Lag_Band",
                                                     "Close Lag" = "Close_Lag_Band",
                                                     "Body Part" = "Body_Part",
                                                     "Cause" = "Cause",
                                                     "Cause Detail" = "Cause_Detail",
                                                     "Nature of Injury" = "Injury",
                                                     "Age" = "Age_Band",
                                                     "Tenure" = "Tenure_Band"
                                                     ),
                                         selected = "Report_Lag_Band", multiple = FALSE),
                             selectInput("Column_2D", "Column Selection",
                                         choices = c("Report Lag"="Report_Lag_Band",
                                                     "Close Lag" = "Close_Lag_Band",
                                                     "Body Part" = "Body_Part",
                                                     "Cause" = "Cause",
                                                     "Cause Detail" = "Cause_Detail",
                                                     "Nature of Injury" = "Injury",
                                                     "Age" = "Age_Band",
                                                     "Tenure" = "Tenure_Band"
                                         ),
                                       selected = "Report_Lag_Band", multiple = FALSE)
                           ),
                           column(8,
                                  br(),br(),br(),
                                  div("The 2D Table module allows users to investigate segmented statistics with two-variable segmentation. In this example, users can view insurance claim counts and average claim amounts. If the browser window is too narrow to display the entire table, a local scrollbar appears on the table.")
                                  ),
                           column(12,
                           div(h3("Reported Count"),
                           dataTableOutput("Reported_Count_2D")),
                           br(),
                           div(h3("Incurred Severity")),
                           dataTableOutput("Incurred_Severity_2D")
                           
                  ))
                )
                
                
              )
)