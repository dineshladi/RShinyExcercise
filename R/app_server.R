#' @import shiny
#' @import ggplot2
#' @import dplyr
#' @import DT datatable formatRound

app_server <- function(input, output, session) {

  output$sex_race_plot <- renderPlot({
    ggplot(data = patients,aes(x = RACE)) +
      geom_bar(stat = "count", aes(fill = SEX))
  })

  output$patients_table <- renderDataTable({
   datatable(head(patients),options = list(scrollX=TRUE), caption = "Sample Patients Data",class = "compact")
  })
  output$lab_tests_table <- renderDataTable({
    datatable(head(lab_tests),options = list(scrollX=TRUE), caption = "Sample Lab Tests Data",class = "compact") %>%
      formatRound(columns = c("BMRKR1","AVAL"),3)
  })

  output$attribute_plot <- renderPlot({
    col <- input$attribute
    req(col)

    if(col != 'AGE'){
     p <- ggplot(data = patients, aes(x = !!sym(col))) +
        geom_bar(stat = "count",fill = "maroon")
    }
    else{
     p <- ggplot(data = patients, aes(x = !!sym(col))) +
        geom_histogram(stat = "bin", binwidth = 5, fill = "maroon")
    }

    p + labs(title = paste0("Distribution of Patients vs ",col)) +
        theme(plot.title = element_text(hjust = 0.5),
              title = element_text(face = "bold"))
  })

  filtered_data <- reactive({

    req(input$sex)
    req(input$race)
    req(input$lbtestcd)
    req(input$bmrkr2)


    lab_tests_joined %>%
      filter(SEX %in% input$sex,
             RACE %in% input$race,
             LBTESTCD %in% input$lbtestcd,
             BMRKR2 %in%  input$bmrkr2) %>%
      group_by(ACTARM,AVISIT,AVALU,LBTEST) %>%
      summarise(AVAL = mean(AVAL)) %>%
      ungroup()
  })

  output$plot <- renderPlot({
    print(colnames(filtered_data()))
    test_unit <- filtered_data() %>% pull(AVALU) %>% head(1)
    test_name <- filtered_data() %>% pull(LBTEST) %>% head(1)
    ggplot(data = filtered_data(), aes(x = AVISIT, y = AVAL)) +
      geom_line(aes(color = ACTARM, group = ACTARM), size = 1) +
      labs(y = paste0("Measurement Value (",test_unit,")"),
           title = paste0(test_name," Value vs Time for different test groups")) +
      theme(legend.position="bottom",
            plot.title = element_text(hjust = 0.5),
            title = element_text(face = "bold"),
            legend.title = element_text(size=12),
            legend.text = element_text(size=12))
  })
}
