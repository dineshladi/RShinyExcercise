#' @import shiny

app_ui <- fluidPage(
  selectInput("sex", "Sex", choices = levels(lab_tests_joined$SEX), selected = "M", multiple = TRUE),
  selectInput("race","RACE", choices = levels(lab_tests_joined$RACE), selected = "WHITE", multiple = TRUE),
  selectInput("lbtestcd","LBTESTCD ", choices = levels(lab_tests_joined$LBTESTCD), selected = "IGA", multiple = TRUE),
  plotOutput("plot")
)
