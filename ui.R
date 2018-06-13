library(shiny)
library(tidyverse)
library(lubridate)

users           <- read_csv("data/youdoers.csv")$youdoer
project.codes   <- read_csv("data/project_codes.csv")$project.code
fields_optional <- c("Date", "Task", "Time")

ui <- fluidPage(

  titlePanel("Teamtime"),

  sidebarLayout(
    sidebarPanel(
      dateRangeInput("report_date", label = "Date:", start = Sys.Date() - months(1)),
      selectInput("folks",    "YouDoer:",  choices = users,           multiple = TRUE),
      selectInput("projects", "Projects:", choices = project.codes,   multiple = TRUE),
      selectInput("fields",   "Fields:",   choices = fields_optional, multiple = TRUE)
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("List",
          dataTableOutput("tss_table"),
          strong("total:"),
          textOutput("total_hours", inline = TRUE)
        ),
        tabPanel("Table",
          dataTableOutput("tss_by_week")
        )
      )
    )
  )
)
