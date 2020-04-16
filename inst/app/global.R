library(shiny)
library(shinyWidgets)
library(dplyr)
library(ggplot2)
library(DT)
library(shinythemes)
library(reshape2)
library(knitr)
library(kableExtra)

### helper functions
addline_format <- function(x){
  gsub(' OR ','\nOR\n', x)
}
