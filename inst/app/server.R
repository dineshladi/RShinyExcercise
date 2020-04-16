server <- function(input, output, session) {

  ### render patients sample data
  output$patients_table <- renderDataTable({
   datatable(patients,rownames = FALSE, caption = "Sample Patients Data",
             options = list(scrollX=TRUE,
                            columnDefs = list(list(className = 'dt-center', targets = "_all")),
                            class = "compact"))
  })

  ### render lab tests sample data
  output$lab_tests_table <- renderDataTable({
    datatable(head(lab_tests,200), rownames = FALSE, caption = "Sample Lab Tests Data",
              options = list(scrollX=TRUE,
                             columnDefs = list(list(className = 'dt-center', targets = "_all")),
                             class = "compact")) %>%
      formatRound(columns = c("BMRKR1","AVAL"),3)
  })

  ### UI for dropdown list of columns for distribution plot
  output$attribute_plot <- renderPlot({
    selected_var <- input$attribute
    req(selected_var)

    if (selected_var == 'AGE'){
      p <- ggplot(data = patients, aes(x = !!sym(selected_var))) +
              geom_histogram(stat = "bin", binwidth = 5, fill = "maroon")
    }
    else if (selected_var == 'BMRKR1'){
      p <- ggplot(data = distinct(select(lab_tests,c("USUBJID","BMRKR1"))), aes(x = !!sym(selected_var))) +
              geom_histogram(stat = "bin", binwidth = 2, fill = "maroon")
    }
    else if(selected_var == 'BMRKR2') {
      p <- ggplot(data = distinct(select(lab_tests,c("USUBJID","BMRKR2"))), aes(x = !!sym(selected_var))) +
              geom_bar(stat = "count", fill = "maroon")
    }

    else {
     p <- ggplot(data = patients, aes(x = !!sym(selected_var))) +
             geom_bar(stat = "count", fill = "maroon") +
             scale_x_discrete(breaks = levels(patients[[selected_var]]),
                              labels = addline_format(levels(patients[[selected_var]])))
    }

    p + labs(title = paste0("Distribution of Patients vs ",selected_var)) +
        theme(plot.title = element_text(hjust = 0.5),
              title = element_text(face = "bold"),
              axis.text.x = element_text(size  = 10))

    })

  ### patient details
  output$patient_details <- function(){
    patient_id <- input$patient_id
    req(patient_id)

    patient_lab_tests <- filter(lab_tests_joined, USUBJID==patient_id) %>%
                         select(c("BMRKR1","BMRKR2","AGE","SEX","RACE","ACTARM")) %>%
                         distinct() %>%
                         mutate(BMRKR1 = round(BMRKR1,4))


    melt(patient_lab_tests,
      measure.vars = c("AGE","SEX","RACE","BMRKR1","BMRKR2","ACTARM"),
      variable.name = "Attribute", value.name = "Value") %>%
      kable() %>%
      kable_styling(bootstrap_options = "striped", full_width = F, position = "left") %>%
      pack_rows("Demographic",1,3) %>%
      pack_rows("Medical",4,6)

  }


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
    req(input$bmrkr1)
    req(input$bmrkr2)

    bmrkr1_vals <- input$bmrkr1

    grouped <- lab_tests_joined %>%
      filter(SEX %in% input$sex,
             RACE %in% input$race,
             LBTESTCD %in% input$lbtestcd,
             BMRKR1 >= bmrkr1_vals[1],
             BMRKR1 < bmrkr1_vals[2],
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

