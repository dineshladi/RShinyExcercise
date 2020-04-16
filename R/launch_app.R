#' Launch Shiny App.
#' @return Launches the shiny web app
#' @export
#'
#' @import shiny
#' @import ggplot2
#' @import dplyr
#' @importFrom DT datatable formatRound renderDataTable dataTableOutput
#' @importFrom reshape2 melt
#' @importFrom knitr kable
#' @importFrom kableExtra kable_styling
#' @importFrom shinythemes shinytheme


launch_app <- function() {
  appDir <- system.file("app", package = "RShinyExcercise")
  if (appDir == "") {
    stop("Could not find myapp. Try re-installing RShinyExcercise", call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal",launch.browser = T)
}

# run_app <- function() {
#   shinyApp(ui = app_ui, server = app_server,options = list(launch.browser = TRUE))
# }

