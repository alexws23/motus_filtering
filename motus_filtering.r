# Goal: Replicate RunLength and MOTUS Filter from raw Kennekuk data

library(tidyverse)

#Load in dataset
data <- read.csv(#"~/Library/CloudStorage/Box-Box/Kennekuk Sigma 8 Data/fall_individual_birds/261 .csv"
  "C:/Users/awsmilor/Box/Kennekuk Sigma 8 Data/kenn_data_fall2025.csv"
  #"R:/Rails_NEW/band_exports/SORA_139234672_2021/SORA_139234672_2021_unfiltered.csv"
  )

data$tower <- gsub("Tower ", "", data$tower)

tags <- read.csv("C:/Users/awsmilor/Box/935_tag_database.csv")

#Definitions
#Run = A collections of consecutive hits. Up to 60 bursts can be missed (not detected) before a new run starts.
#Run Length = The number of detections in the run

mfgIDs <- unique(data$mfgID) # Create a list of all mfgIDs that were detected

list_of_dfs <- list() # Create a placeholder list

# For-loop to create a MOTUS filter 
for (i in mfgIDs) {
  
  t <- tags %>% 
    filter(id == i)
  
  bi <- t$bi
  
  run_gap <- 13*bi
  
  df <- data %>%
    filter(mfgID == i) %>% 
    group_by(port) %>%
    arrange(Datetime) %>%
    mutate(
      Datetime = as_datetime(Datetime),
      diff = as.numeric(difftime(Datetime, lag(Datetime), units = "secs")),
      new_run = is.na(diff) | diff >= run_gap,
      runID = cumsum(new_run)
    ) %>% 
    mutate(runID = paste(tower,port,runID,sep = "")) %>% 
    ungroup
  
  data_filtered <- df %>% 
    group_by(runID) %>% 
    summarise(runLen = n()) %>% 
    mutate(motusFilter = ifelse(runLen <= 3, 0, 1)) %>% 
    ungroup()
  
  tmp <-  df %>% 
    left_join(data_filtered, by = join_by(runID))
  
  list_of_dfs[[paste0("df_", i)]] <- tmp
}

data_final <- bind_rows(list_of_dfs) %>% 
  select(-c(new_run, diff))

write.csv(data_final, "fall_birds_2025_filter.csv")
