# load in the packages
library(dplyr)
library(tidyr)
library(rgdal)
library(shiny)
library(shinythemes)
library(leaflet)
library(ggplot2)
library(treemap)
library(gridBase)
library(RColorBrewer)
library(plotly)
library(tm)
library(igraph)
library(networkD3)
library(tidytext)
library(stringr)
library(lubridate)
library(wordcloud2)
library(ggrepel)
library(stopwords)
library(quanteda)
library(ggthemes)
library(dygraphs)
library(googleVis)
library(zoo)
library(plotly)



# read in the clean dataset
mapdata <- readRDS(file = "mapdata.RDS")



# Prepare for the first tab: Geographic Insight

## read in the shape file
us_map <- readOGR("cb_2017_us_state_500k/.","cb_2017_us_state_500k")

## subset the state included in the complaints dataframe
us_map@data$STUSPS <- as.character(us_map@data$STUSPS)
us_map <- subset(us_map, !(STUSPS %in% c("AK", "AS", "GU", "HI", "MP", "PR", "VI")))

## function to cut the quantile
quantile_labels <- function (vec, n)
{
    qs <- round(quantile(vec, seq(0, 1, 1/n), na.rm = TRUE),
    1)
    len <- length(qs) - 1
    qlabs <- c()
    for (i in 1:len) {
        j <- i + 1
        v <- paste0(as.character(qs[i]), "-", as.character(qs[j]))
        qlabs <- c(qlabs, v)
    }
    final_labs <- c(qlabs, "Data unavailable")
    final_labs
}


# Prepare for the second tab: Product Insight

## load in the data
treemap1 <- readRDS(file = "treemap1.RDS")

## Handle cliks on a treemap
tmLocate <-
function(coor, tmSave) {
    tm <- tmSave$tm
    
    # retrieve selected rectangle
    rectInd <- which(tm$x0 < coor[1] &
    (tm$x0 + tm$w) > coor[1] &
    tm$y0 < coor[2] &
    (tm$y0 + tm$h) > coor[2])
    
    return(tm[rectInd[1], ])
    
}


# Prepare for the third tab: Company Insight

## load in the data
treemap2 <- readRDS(file = "treemap2.RDS")


# Prepare for the fourth tab: Complaints Narrative Analysis

## load in the data
data_text <- readRDS(file = "data_text.RDS")

## define color scheme
my_colors <- c("#E69F00", "#56B4E9", "#009E73", "#CC79A7", "#D55E00", "#D65E00")

## define the product list
productlist <- c("Credit reporting","Student loan")

## define stopwords
undesirable_words <- c("xxx", "xxxx", "xxxxxxxx", "la", "da", "uh", "ah", "oh", "im", "ooh")


## clean text function
clean_text <- function(subtime){
    
    data_bigrams <- subtime %>%
    unnest_tokens(bigram, narrative, token = "ngrams", n = 2)
    
    bigrams_separated <- data_bigrams %>%
    separate(bigram, c("word1", "word2"), sep = " ")
    
    undesirable_words <- c("xxx", "xxxx", "xxxxxxxx", "la", "da", "uh", "ah", "oh", "im", "ooh")
    
    bigrams_filtered <- bigrams_separated %>%
    filter(!word1 %in% stop_words$word) %>%
    filter(!word2 %in% stop_words$word) %>%
    filter(!word1 %in% undesirable_words) %>%
    filter(!word2 %in% undesirable_words)
    
    bigrams <- bigrams_filtered %>%
    filter(word1 != word2) %>%
    unite(bigram, word1, word2, sep = " ") %>%
    select(X1, date, product, company, bigram) %>%
    count(bigram, product, sort = TRUE) %>%
    group_by(product) %>%
    ungroup() %>%
    arrange(product, -n)
    
    bigram <- bigrams %>%
    select(bigram, n) %>%
    top_n(200)
    bigram
}


## modify the data
nodes <- c("EQUIFAX, INC.", "Experian Information Solutions Inc.", "TRANSUNION INTERMEDIATE HOLDINGS, INC.", "CAPITAL ONE FINANCIAL CORPORATION", "CITIBANK, N.A.", "SYNCHRONY FINANCIAL", "JPMORGAN CHASE & CO.", "WELLS FARGO & COMPANY", "BANK OF AMERICA, NATIONAL ASSOCIATION", "LEXISNEXIS", "Credit reporting")
nodes <- data.frame(node = c(0:10),
target = nodes)
colnames(nodes) <- c("node", "name")
network_color <- 'd3.scaleOrdinal() .domain(["EQUIFAX, INC.", "Experian Information Solutions Inc.", "TRANSUNION INTERMEDIATE HOLDINGS, INC.", "CAPITAL ONE FINANCIAL CORPORATION", "CITIBANK, N.A.", "SYNCHRONY FINANCIAL", "JPMORGAN CHASE & CO.", "WELLS FARGO & COMPANY", "BANK OF AMERICA, NATIONAL ASSOCIATION", "LEXISNEXIS", "Credit reporting"]) .range(["#E69F00", "#56B4E9", "#009E73", "#CC79A7", "#D55E00", "#D65E00"])'



# Prepare for the fifth tab: Case Study I

## load in the data
reshaped_timely_response <- readRDS("reshaped_timely_response.rds")
reshaped_number_complaint <- readRDS("reshaped_number_complaint.rds")
issue <- reshaped_number_complaint[,-1]
issue_name <- c("Confusing or misleading advertising or marketing", "Credit monitoring or identity theft protection services", "Fraud or scam", "Identity theft protection or other monitoring services", "Improper use of your report", "Incorrect information on your report", "Problem with customer service", "Problem with fraud alerts or security freezes", "Unable to get your credit report or credit score")

## load in the data
credit_edglist <- readRDS("credit_edglist.RDS")



# Prepare for the sixth tab: Case Study II

nodes_1 <- c("Navient Solutions, LLC.", "AES/PHEAA", "NELNET, INC.", "SLM CORPORATION", "GREAT LAKES", "ACS Education Services", "WELLS FARGO & COMPANY", "DISCOVER BANK", "TRANSWORLD SYSTEMS INC", "HEARTLAND PAYMENT SYSTEMS INC", "MOHELA", "ECMC Group, Inc.", "Equitable Acceptance Corporation", "CITIBANK, N.A.", "JPMORGAN CHASE & CO.", "Utah System of Higher Education", "Ameritech Financial", "EdFinancial Services", "First Associates Loan Servicing LLC","Social Finance, Inc.", "Student loan")
grid.col_1 = c("Navient Solutions, LLC" = my_colors[1], "AES/PHEAA" = my_colors[1],"NELNET, INC." = my_colors[2], "SLM CORPORATION" = my_colors[2],"GREAT LAKES" = my_colors[3], "ACS Education Services" = my_colors[3], "WELLS FARGO & COMPANY" = my_colors[4], "DISCOVER BANK" = my_colors[4],"TRANSWORLD SYSTEMS INC" = my_colors[5], "HEARTLAND PAYMENT SYSTEMS INC" = my_colors[1], "MOHELA" = my_colors[5], "ECMC Group, Inc." = my_colors[1],"Equitable Acceptance Corporation" = my_colors[2], "CITIBANK, N.A." = my_colors[2],"JPMORGAN CHASE & CO." = my_colors[3], "Utah System of Higher Education" = my_colors[3], "Ameritech Financial" = my_colors[4], "EdFinancial Services" = my_colors[5], "First Associates Loan Servicing LLC" = my_colors[1],"Social Finance, Inc." = my_colors[2], "Student loan" = my_colors[5])

network_color_1 <- 'd3.scaleOrdinal() .domain(["Navient Solutions, LLC.", "AES/PHEAA", "NELNET, INC.", "SLM CORPORATION", "GREAT LAKES", "ACS Education Services", "WELLS FARGO & COMPANY", "DISCOVER BANK", "TRANSWORLD SYSTEMS INC", "HEARTLAND PAYMENT SYSTEMS INC", "MOHELA", "ECMC Group, Inc.", "Equitable Acceptance Corporation", "CITIBANK, N.A.", "JPMORGAN CHASE & CO.", "Utah System of Higher Education", "Ameritech Financial", "EdFinancial Services", "First Associates Loan Servicing LLC","Social Finance, Inc.", "Student loan"]) .range(["#E69F00", "#56B4E9", "#009E73", "#CC79A7", "#D55E00", "#D65E00"])'

nodes_1 <- data.frame(node = c(0:20),
target = nodes_1)
colnames(nodes_1) <- c("node", "name")

## import the datasets - student loan
reshaped_timely_response_loan <- readRDS("reshaped_timely_response_loan.rds")
reshaped_number_complaint_loan <- readRDS("reshaped_number_complaint_loan.rds")
issue_name_loan <- c("Credit monitoring or identity theft protection services", "Dealing with your lender or servicer", "Getting a loan", "Incorrect information on your report", "Struggling to repay your loan")


## load in the data
student_edglist <- readRDS("student_edglist.RDS")
