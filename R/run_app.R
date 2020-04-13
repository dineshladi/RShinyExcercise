#' Launch Shiny App.
#' @return Launches the shiny web app
#' @export
#' @importFrom shiny shinyApp

run_app <- function() {
  shinyApp(ui = app_ui, server = app_server,options = list(launch.browser = TRUE))
}

