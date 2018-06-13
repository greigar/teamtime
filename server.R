library(shiny)
library(tidyverse)
library(lubridate)

path     <- "~/Downloads/"
filename <- dir(path, pattern = "timesheet")[1]
filename <- paste0(path, filename)

fields_default <- c("Week_start", "User", "Project.Code")

read_ts <- function() {
  ts_data            <- read_csv(filename)
  names(ts_data)     <- make.names(names(ts_data))

  ts_data            <- ts_data %>%
                          dplyr::filter(is.na(X1)) %>%
                          select(Date, Project.Code, Task, User, Time)

  ts_data$Week_start <- cut(ts_data$Date, breaks = "week", start.on.monday = 2)

  ts_data <- ts_data %>%
               mutate(Week_start = as.Date(
                                     ifelse(Project.Code == 'DRMS',
                                       ifelse(weekdays(Date) == 'Monday',
                                                as.Date(Week_start) - days(6),
                                                as.Date(Week_start) + days(1)),
                                       as.Date(Week_start)),
                                     origin = "1970-01-01"))
  ts_data
}

ts_data <- read_ts()

tss <- function(fields, folks, projects, start_date, end_date) {

  t <- ts_data %>% filter(Date >= as.Date(start_date) & Date <= as.Date(end_date)) %>%
                   select(c(fields, "Time")) %>%
                   group_by_at(fields) %>%
                   summarise(Total_hours = sum(Time)) %>%
                   arrange_(fields)

  if (length(folks) > 0) {
    t <- t %>% filter(User %in% folks)
  }
  if (length(projects) > 0) {
    t <- t %>% filter(Project.Code %in% projects)
  }

  t
}

tss_by_week <- function(data) {
  data %>% group_by(User, Project.Code, Week_start) %>%
           summarise(week_hours = sum(Total_hours)) %>%
           spread(Week_start, week_hours)
}

server <- function(input, output) {

   results <- reactive({ tss(c(input$fields, fields_default),
                             input$folks,
                             input$projects,
                             input$report_date[1],
                             input$report_date[2]) })

   output$total_hours <- renderText({ sum(results()$Total_hours) })
   output$tss_table   <- renderDataTable({ results() }, options = list(pageLength = 100))
   output$tss_by_week <- renderDataTable({ results() %>% tss_by_week })
}
