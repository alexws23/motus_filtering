# Goal: Replicate RunLength and MOTUS Filter from raw Kennekuk data

library(tidyverse)

#Load in dataset
data <- read.csv("~/Library/CloudStorage/Box-Box/Kennekuk Sigma 8 Data/fall_individual_birds/261 .csv"
  #"C:/Users/awsmilor/Box/Kennekuk Sigma 8 Data/fall_individual_birds/261 .csv"
  )

#Definitions
#Run = A collections of consecutive hits. Up to 60 bursts can be missed (not detected) before a new run starts.
#Run Length = The number of detections in the run

run_gap <- 60*7.098899841

# Arrange by Date
data <- data %>% 
  group_by(port) %>% 
  arrange(Datetime) %>% 
  mutate(run_id = 1:n(),
         gap_start = as_datetime(lag(Datetime)),
         gap_end = as_datetime(Datetime),
         Datetime = as_datetime(Datetime),
         diff = difftime(gap_end, gap_start),
         run_id = ifelse(diff < run_gap, lag(run_id), run_id)
         )
 
