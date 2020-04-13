#' @import shiny
#' @import ggplot2
#' @import dplyr

app_server <- function(input, output, session) {

  # grouped <- lab_tests_joined %>%
  #   group_by(SEX,RACE,LBTESTCD, ACTARM, AVISIT) %>%
  #   summarise(AVAL = mean(AVAL)) %>%
  #   ungroup()

  filtered_data <- reactive({

    lab_tests_joined %>%
      filter(SEX %in% input$sex,
             RACE %in% input$race,
             LBTESTCD %in% input$lbtestcd) %>%
      group_by(ACTARM,AVISIT) %>%
      summarise(AVAL = mean(AVAL)) %>%
      ungroup()

  })

  output$plot <- renderPlot({

    ggplot(data = filtered_data(), aes(x = AVISIT, y = AVAL)) +
      geom_line(aes(color = ACTARM, group = ACTARM), size = 1) +
      labs(title = "Value vs Time for different test groups") +
      theme(legend.position="bottom",plot.title = element_text(hjust = 0.5))
      #scale_x_discrete(labels = paste0("T", seq(1,7)))

  })
}
