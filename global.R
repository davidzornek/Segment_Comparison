library(shiny)
library(shinydashboard)
library(rCharts)
library(tidyr)
library(DT)
library(lazyeval)
library(magrittr)
library(plyr)
library(dplyr)



Current_Eval <- as.Date("6/30/2015", format = "%m/%d/%Y")
Prior_Eval <- as.Date("3/31/2015", format = "%m/%d/%Y")

data <- readRDS("data/data_final.rds")

exposures <- read.csv("data/exposures.csv", na.strings = c("#DIV/0","n/a"), stringsAsFactors = FALSE)