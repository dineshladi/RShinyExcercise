
patients_data_tab <- tabPanel("Patients",
                        dataTableOutput("patients_table"),
                        includeMarkdown(system.file("app/patients.Rmd", package = "RShinyExcercise")),
                        tags$h3("Visualize"),
                        fluidRow(column(
                                 width = 3,
                                 selectInput("attribute1",label = "Attribute1",choices = c("SEX","RACE","ACTARMCD","BMRKR2","AGE"),multiple = FALSE),
                                 uiOutput("attribute2_ui"),
                                 actionButton("render_plot","Render")),
                                 column(width = 9, plotOutput("attribute_plot",width = "80%"))
                                 )
                            )


lab_tests_data_tab <- tabPanel("Lab Tests",
                               dataTableOutput("lab_tests_table"),
                               includeMarkdown(system.file("app/lab_tests.Rmd", package = "RShinyExcercise"))
                              )

explore_side_bar_ui <- sidebarPanel(width = 3,
      tags$h5("Select patient to render lab test results"),
      selectInput("patient_id", "Subject ID", choices = patients$USUBJID, selected = patients$USUBJID[[1]], multiple = FALSE, width = '300px'),
      tags$hr(style="border: none; border-bottom: 1px solid black;"),
      tags$h5("Select attribute values to see how patients respond over time in different test groups"),
      selectInput("sex", "Sex", choices = levels(lab_tests_joined$SEX), selected = "F", multiple = TRUE,width = '200px'),
      selectInput("race","Race", choices = levels(lab_tests_joined$RACE), selected = "ASIAN", multiple = TRUE,width = '200px'),
      selectInput("bmrkr2","BMRKR2 ", choices = levels(lab_tests_joined$BMRKR2), selected = "MEDIUM", multiple = TRUE,width = '200px'),
      radioButtons("lbtestcd","LBTESTCD ", choices = levels(lab_tests_joined$LBTESTCD), selected = "IGA",inline = TRUE, width = '200px')
                      )

explore_main_panel_ui <- mainPanel(width = 9,
        tags$h3("Summary of individual patient for all the tests"),
        plotOutput("patient_plot"),
        tags$hr(),
        tags$h3("Summary of patients in different treatment groups for the selected attribute values"),
        plotOutput("time_plot")
                          )


ui <-
  navbarPage(theme = shinytheme("flatly"),
             title = "Lab Tests Trials",
    tabPanel("Data",
             tags$h2("Exploring Patients/Lab Tests Data"),
              tabsetPanel(patients_data_tab,
                          lab_tests_data_tab
                          )
            ),

    tabPanel("Explore",
             sidebarLayout(explore_side_bar_ui,
                           explore_main_panel_ui
                           )
           ),

    tabPanel("About",
             includeMarkdown(system.file("app/about.Rmd", package = "RShinyExcercise"))
            )
  )

