#' @import shiny
#' @importFrom shinythemse shinytheme

app_ui <-
  navbarPage(theme = shinytheme("flatly"),
             title = "Lab Tests Trials",
    tabPanel("Home",
      tags$h2("Exploring Patients/Lab Tests Data"),
      tabsetPanel(
        tabPanel("Patients",
                 dataTableOutput("patients_table"),
                 includeMarkdown("R/patients.md"),
                 fluidRow(column(width = 3,selectInput("attribute",label = "Attribute",choices = c("SEX","RACE","ACTARMCD","AGE"),multiple = FALSE)),
                          column(width = 9, plotOutput("attribute_plot",width = "80%")))
                 ),
        tabPanel("Lab Tests",
                 dataTableOutput("lab_tests_table"),
                 includeMarkdown("R/lab_tests.md"))
      )
      # fluidRow(column(width = 6, dataTableOutput("data_kable")),
      #          column(width = 6, plotOutput("sex_race_plot")))
      ),
    tabPanel("Explore",
      sidebarLayout(
          sidebarPanel(
            tags$h5("Select attribute values to see how patients respond over time in different test groups"),
        selectInput("sex", "Sex", choices = levels(lab_tests_joined$SEX), selected = "F", multiple = TRUE,width = '200px'),
        selectInput("race","Race", choices = levels(lab_tests_joined$RACE), selected = "ASIAN", multiple = TRUE,width = '200px'),
        selectInput("bmrkr2","BMRKR2 ", choices = levels(lab_tests_joined$BMRKR2), selected = "MEDIUM", multiple = TRUE,width = '200px'),
        radioButtons("lbtestcd","LBTESTCD ", choices = levels(lab_tests_joined$LBTESTCD), selected = "IGA",inline = TRUE, width = '200px')
          ,width = 3),
          mainPanel(
            tags$h3("Summary of patients in different test groups for the selected attribute values"),
            plotOutput("plot"), width = 9
          )
      )
    ),
    tabPanel("About",includeMarkdown("R/about.md"))
  )

