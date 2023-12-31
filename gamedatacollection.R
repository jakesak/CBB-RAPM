# Load necessary libraries
library(bigballR)
library(tidyverse)
library(purrr)
library(dplyr)
library(readr)
library(stringr)

# Define all_teams and all_seasons
teams_df = teamids
all_teams = unique(teams_df$Team)
all_seasons = unique(teams_df$Season)

# Initialize an empty data frame
all_games <- data.frame()

# Loop over all seasons and teams
for(season in all_seasons){
  for(team in all_teams){
    # Use tryCatch to handle potential errors
    result <- tryCatch({
      # Get team schedule
      schedule <- get_team_schedule(season = season, team.name = team)
      # Select necessary columns and add season column
      schedule <- schedule %>%
        select(Home, Away, Game_ID) %>%
        mutate(season = season)
      # If successful, append to all_games data frame
      all_games <- rbind(all_games, schedule)
    }, error = function(e) {
      # If there's an error, print a message and continue
      print(paste("Error with team", team, "in season", season, ": ", e$message))
    })
  }
}

unique_games <- unique(all_games[, c("Home", "Away", "Game_ID", "season")])
unique_games <- unique_games %>%
  filter(!is.na(Game_ID))
write.csv(unique_games, "all_games.csv", row.names = FALSE)


if (!dir.exists("games")) 
  dir.create("games")

# Loop over all rows in the all_games data frame
for(i in 1:nrow(unique_games)){
  # Use tryCatch to handle potential errors
  result <- tryCatch({
    # Get the game data
    game_data <- scrape_game(game_id = unique_games$Game_ID[i])
    
    # Get the date from the game data
    date <- game_data$Date[1] 
    date <- gsub("/", ".", date)
    
    # Create the file name
    file_name <- paste(unique_games$Game_ID[i], unique_games$season[i], date, 
                       unique_games$Home[i], unique_games$Away[i], "game", sep = "_")
    
    # Check if the file already exists
    if (!file.exists(paste0("games/", file_name, ".csv"))) {
      # If the file doesn't exist, write the game data to a CSV file in the "games" directory
      write.csv(game_data, paste0("games/", file_name, ".csv"), row.names = FALSE)
    }
  }, error = function(e) {
    # If there's an error, print a message and continue
    print(paste("Error with game", unique_games$game_id[i], ": ", e$message))
  })
}


# Get a list of all CSV files in the "games" directory
csv_files <- list.files("games", pattern = "\\.csv$")

# Extract the game IDs from the file names
file_game_ids <- str_extract(csv_files, "^[^_]*")

# Get a list of all game IDs in the all_games data frame
all_game_ids <- unique_games$Game_ID

# Find which game IDs in all_games don't have a matching file
missing_game_ids <- setdiff(all_game_ids, file_game_ids)
print(missing_game_ids)
missing_games <- unique_games %>%
  filter(Game_ID %in% missing_game_ids, !is.na(Game_ID))
print(missing_games)

# Try all rows missing originally
for(i in 1:nrow(missing_games)){
  # Use tryCatch to handle potential errors
  result <- tryCatch({
    # Get the game data
    game_data <- scrape_game(game_id = missing_games$Game_ID[i])
    
    # Get the date from the game data
    date <- game_data$Date[1] 
    date <- gsub("/", ".", date)
    
    # Create the file name
    file_name <- paste(missing_games$Game_ID[i], missing_games$season[i], date, 
                       missing_games$Home[i], missing_games$Away[i], "game", sep = "_")
    
    # Check if the file already exists
    if (!file.exists(paste0("games/", file_name, ".csv"))) {
      # If the file doesn't exist, write the game data to a CSV file in the "games" directory
      write.csv(game_data, paste0("games/", file_name, ".csv"), row.names = FALSE)
    }
  }, error = function(e) {
    # If there's an error, print a message and continue
    print(paste("Error with game", missing_games$game_id[i], ": ", e$message))
  })
}

# Organize by season
# Get a list of all CSV files in the "games" directory
csv_files <- list.files("games", pattern = "\\.csv$")

# Loop over all files
for(file in csv_files){
  # Extract the season from the file name
  season <- str_extract(file, "(?<=_)[^_]*(?=_)")
  
  # Create a new directory for the season if it doesn't exist
  if (!dir.exists(paste0("games/", season))) {
    dir.create(paste0("games/", season))
  }
  
  # Move the file to the new directory
  file.rename(paste0("games/", file), paste0("games/", season, "/", file))
}


# Get the path of your working directory
wd_path <- getwd()

# Get the path of the 2022-23 games folder
folder_path <- file.path(wd_path, "games", "2022-23")

# Get a list of all files in the folder
files <- list.files(folder_path, full.names = TRUE)

# Get file info for all files
file_info <- file.info(files)

# Find duplicate files based on size
duplicates <- duplicated(file_info$size)

# Get the names of the duplicate files
duplicate_files <- files[duplicates]

# Delete the duplicate files
file.remove(duplicate_files)
