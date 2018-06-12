library(shiny)
library(tidyverse)
library(lubridate)

users          <- read_csv("data/youdoers.csv")$youdoer
project.codes  <- read_csv("data/project_codes.csv")$project.code
fields         <- c("Date", "Project.Code", "Task", "User", "Time", "Week_start")
fields_default <- c("Project.Code", "User", "Week_start")

ui <- fluidPage(

   titlePanel("Teamtime"),

   sidebarLayout(
      sidebarPanel(
        dateRangeInput("report_date", label = "Date:", start = Sys.Date() - months(2)),
         selectInput("folks",    "YouDoer:",  choices = users,         multiple = TRUE, selected = users),
         selectInput("projects", "Projects:", choices = project.codes, multiple = TRUE),
         selectInput("fields",   "Fields:",   choices = fields,        multiple = TRUE, selected = fields_default)
      ),

      mainPanel(
         dataTableOutput("tss_table"),
         strong("total:"),
         textOutput("total_hours", inline = TRUE)
      )
   )
)
