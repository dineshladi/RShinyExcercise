server <- function(input, output, session) {

  ### render patients sample data
  output$patients_table <- renderDataTable({
   datatable(head(patients),rownames = FALSE, caption = "Sample Patients Data",
             options = list(scrollX=TRUE,
                            columnDefs = list(list(className = 'dt-center', targets = "_all")),
                            class = "compact"))
  })

  ### render lab tests sample data
  output$lab_tests_table <- renderDataTable({
    datatable(head(lab_tests), rownames = FALSE, caption = "Sample Lab Tests Data",
              options = list(scrollX=TRUE,
                             columnDefs = list(list(className = 'dt-center', targets = "_all")),
                             class = "compact")) %>%
      formatRound(columns = c("BMRKR1","AVAL"),3)
  })

  ### UI for dropdown list of columns for distribution plot
  output$attribute_plot <- renderPlot({
    col1 <- input$attribute1
    #col2 <- input$attribute2
    req(col1)

    if (col1 == 'AGE'){
      p <- ggplot(data = patients, aes(x = !!sym(col1))) +
        geom_histogram(stat = "bin", binwidth = 5, fill = "maroon")
    }
    else if(col1 == 'BMRKR2') {
      p <- ggplot(data = lab_tests %>% group_by(USUBJID,BMRKR1,BMRKR2) %>% count(),
                  aes(x = !!sym(col1))) +
        geom_bar(stat = "count", fill = "maroon") +
        coord_flip()
    }

    else {
     p <- ggplot(data = patients, aes(x = !!sym(col1))) +
        geom_bar(stat = "count", fill = "maroon") +
        coord_flip()
    }

    p + labs(title = paste0("Distribution of Patients vs ",col1)) +
        theme(plot.title = element_text(hjust = 0.5),
              title = element_text(face = "bold"))
    })


  ### patient level plot
  output$patient_plot <- renderPlot({
    patient_id <- input$patient_id
    req(patient_id)

    patient_lab_tests <- lab_tests_joined %>%
      filter(USUBJID==patient_id) %>%
      mutate(LBTEST = paste0(LBTEST," (",AVALU,")"))

    ggplot(patient_lab_tests,
           aes(x = AVISIT, y = AVAL,group = 1)) +
      geom_line() +
      facet_wrap(~LBTEST,ncol = 1,scales = "free_y") +
      labs(y = "Measurement Value",
          title = paste0("Laboratory Measurements across visits of different tests for subject: ", patient_id)) +
      theme(plot.title = element_text(hjust = 0.5),
            title = element_text(face = "bold"),
            legend.title = element_text(size=12),
            legend.text = element_text(size=12))

  })


  ### filter joined data based on attributes filters from the user
  filtered_data <- reactive({

    req(input$sex)
    req(input$race)
    req(input$lbtestcd)
    req(input$bmrkr2)


    grouped <- lab_tests_joined %>%
      filter(SEX %in% input$sex,
             RACE %in% input$race,
             LBTESTCD %in% input$lbtestcd,
             BMRKR2 %in%  input$bmrkr2) %>%
      group_by(ACTARM,AVISIT,AVALU,LBTEST) %>%
      summarise(AVAL_SD = sd(AVAL),
                AVAL = mean(AVAL)) %>%
      ungroup()

    ### change the order of visit
    grouped$AVISIT <- factor(grouped$AVISIT, levels = c("SCREENING","BASELINE","WEEK 1 DAY 8","WEEK 2 DAY 15","WEEK 3 DAY 22","WEEK 4 DAY 29","WEEK 5 DAY 36"))

    grouped
  })

  ### render summary plot of how subject perform over time
  output$time_plot <- renderPlot({
    test_unit <- filtered_data() %>% pull(AVALU) %>% head(1)
    test_name <- filtered_data() %>% pull(LBTEST) %>% head(1)
    ggplot(data = filtered_data(), aes(x = AVISIT, y = AVAL)) +
      geom_line(aes(color = ACTARM, group = ACTARM), size = 1) +
      labs(y = paste0("Average Measurement Value (",test_unit,")"),
           title = paste0("Average ",test_name," Value vs Time for different test groups")) +
      theme(legend.position="bottom",
            plot.title = element_text(hjust = 0.5),
            title = element_text(face = "bold"),
            legend.title = element_text(size=12),
            legend.text = element_text(size=12))
  })
}

