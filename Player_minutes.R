library(bigballR)

files_2022_23 <- list.files("games/2022-23", pattern = "\\.csv$")
players <- c()
for(i in 1:length(files_2022_23)){
  # Read the game data
  game_data <- read.csv(paste0("games/2022-23/", files_2022_23[i]))
  
  # Extract the player names from the relevant columns
  home_players <- unlist(game_data[, paste0("Home.", 1:5)])
  away_players <- unlist(game_data[, paste0("Away.", 1:5)])
  
  # Combine the home and away players
  game_players <- c(home_players, away_players)
  
  # Remove any NA values
  game_players <- game_players[!is.na(game_players) & game_players != ".NA"]
  
  # Add any new player names to the players vector
  players <- union(players, game_players)
}
players <- players[players != "TEAM"]

# Create the dataframe
player_mins <- data.frame(players = players, mins = rep(0, length(players)))

# Loop over all rows in the all_games data frame
for(i in 1:length(files_2022_23)){
  # Read the current file
  game_data <- read.csv(paste0("games/2022-23/", files_2022_23[i]))
  
  # Check if 'isTransition' exists in game_data, if not add a dummy column
  if (!"isTransition" %in% names(game_data)) {
    game_data$isTransition <- 0  # or NA, depending on how it's used
  }
  # Use tryCatch to handle potential errors in processing each file
  tryCatch({
    player_stats = get_player_stats(game_data)
    for(j in 1:nrow(player_stats)) {  # Change the inner loop iterator to 'j'
      player <- player_stats$Player[j]
      mins <- player_stats$MINS[j]
      idx <- which(player_mins$players == player)
      player_mins$mins[idx] <- player_mins$mins[idx] + mins
    }
  }, 
  error = function(e) {
    message("Error processing file: ", files_2022_23[i])
    message("Error details: ", e$message)
  })
}

write.csv(player_mins, file = "player_mins.csv", row.names = FALSE)
