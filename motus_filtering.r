# Goal: Replicate RunLength and MOTUS Filter from raw Kennekuk data

library(tidyverse)

#Load in dataset
data <- read.csv("C:/Users/awsmilor/Box/Kennekuk Sigma 8 Data/fall_individual_birds/261 .csv")

#Definitions
#Run = A collections of consecutive hits. Up to 60 bursts can be missed (not detected) before a new run starts.
#Run Length = The number of detections in the run

run_gap <- 60*7.098899841

# Arrange by Date
data <- data %>% 
  arrange(Datetime)
