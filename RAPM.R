# Load necessary libraries
library(Matrix)

  
# get a list of all players in the 2022-23 season
files_2022_23 <- list.files("games/2022-23", pattern = "\\.csv$")
players <- c('Margin', 'Home_Margin', 'Away_Margin')
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


# initialize stint matrix and response vectors
stints <- Matrix(0,nrow=0,ncol=length(players), sparse=TRUE)
colnames(stints) <- players

for(i in 1:length(files_2022_23)){
  # Read the current file
  game_data <- read.csv(paste0("games/2022-23/", files_2022_23[i]))
  
  # Initialize the start of the stint
  stint_start <- 1
  
  # Initialize the players on the court at the start of the stint
  players_on_court <- c(game_data[1, paste0("Home.", 1:5)], game_data[1, paste0("Away.", 1:5)])
  
  # Check if the isGarbageTime column exists
  has_isGarbageTime <- "isGarbageTime" %in% colnames(game_data)
  
  # Loop over all rows in the example file
  for(i in 2:nrow(game_data)){
    # Get the current row
    row <- game_data[i, ]
    
    # Get the home and away players on the floor
    homeplayerson <- row[paste0("Home.", 1:5)]
    awayplayerson <- row[paste0("Away.", 1:5)]
    current_players_on_court <- c(homeplayerson, awayplayerson)
    
    # Check if a substitution occurred
    if(!all(current_players_on_court %in% players_on_court) || (has_isGarbageTime && row$isGarbageTime)){
      # A substitution occurred, so calculate the point difference per 100 possessions for the stint
      possessions <- game_data[i - 1, ]$Poss_Num - game_data[stint_start, ]$Poss_Num + 1
      if(possessions > 0){
        homepoints_diff <- game_data[i - 1, ]$Home_Score - game_data[stint_start, ]$Home_Score
        awaypoints_diff <- game_data[i - 1, ]$Away_Score - game_data[stint_start, ]$Away_Score
        margin <- 100 * (homepoints_diff - awaypoints_diff) / possessions
        home_margin <- 100 * homepoints_diff / possessions
        away_margin <- -100 * awaypoints_diff / possessions
        #create new row
        new_row <- numeric(length = length(players))
        names(new_row) <- colnames(stints)
        for(p in players){
          if(p %in% homeplayerson){
            new_row[p] <- 1
          } else if(p %in% awayplayerson){
            new_row[p] <- -1
          }
        }
        new_row["Margin"] <- margin
        new_row["Home_Margin"] <- home_margin
        new_row["Away_Margin"] <- away_margin
        #bind the row
        stints <- rbind(stints, Matrix(new_row, nrow = 1, sparse = TRUE))
      }
      
      # Update the start of the stint and the players on the court
      stint_start <- i
      players_on_court <- current_players_on_court
      
      # If garbage time started, end the game
      if(has_isGarbageTime && row$isGarbageTime){
        break
      }
    }
  }
  
  # Calculate the margin for the final stint
  possessions <- game_data[nrow(game_data), ]$Poss_Num - game_data[stint_start, ]$Poss_Num
  if(possessions > 0){
    homepoints_diff <- game_data[nrow(game_data), ]$Home_Score - game_data[stint_start, ]$Home_Score
    awaypoints_diff <- game_data[nrow(game_data), ]$Away_Score - game_data[stint_start, ]$Away_Score
    margin <- 100 * (homepoints_diff - awaypoints_diff) / possessions
    home_margin <- 100 * homepoints_diff / possessions
    away_margin <- -100 * awaypoints_diff / possessions
    new_row <- numeric(length = length(players))
    names(new_row) <- colnames(stints)
    for(p in players){
      if(p %in% homeplayerson){
        new_row[p] <- 1
      } else if(p %in% awayplayerson){
        new_row[p] <- -1
      }
    }
    new_row["Margin"] <- margin
    new_row["Home_Margin"] <- home_margin
    new_row["Away_Margin"] <- away_margin
    stints <- rbind(stints, Matrix(new_row, nrow = 1, sparse = TRUE))
  }
}

saveRDS(stints, "stints.rds")
