# Load libraries
library(glmnet)
library(caret)
library(caretEnsemble)
library(randomForest)

# Load data
stints <- readRDS("dense_stints.rds")
player_mins <- read.csv("player_mins.csv")

# Filter low-minute players and columns
low_mins_players <- subset(player_mins, mins < 150)$players
columns_to_remove <- which(colnames(stints) %in% c(low_mins_players, "Home_Margin", "Away_Margin"))
stints <- stints[, -columns_to_remove, drop = FALSE]

# Set seed for reproducibility
set.seed(123)

# Split data into training and test sets
sample_index <- sample(seq_len(nrow(stints)), size = 0.8 * nrow(stints))
train_data <- stints[sample_index, ]
test_data <- stints[-sample_index, ]

# Define response variable and predictors
margin_col_index <- which(colnames(stints) == "Margin")
y_train <- train_data[, margin_col_index]
x_train <- train_data[, -c(margin_col_index), drop = FALSE]
y_test <- test_data[, margin_col_index]
x_test <- test_data[, -c(margin_col_index), drop = FALSE]

# Naive model test
# Fit the naive model (using mean of training data)
naive_predictions <- rep(mean(y_train), length(y_test))

# Calculate Mean Squared Error (MSE) for the naive model
naive_mse <- mean((y_test - naive_predictions)^2)
cat("Naive Model MSE:", naive_mse, "\n")

# Create a dummy dataframe for the Naive Model
naive_rapm_df <- data.frame(Player = NA, RAPM = mean(y_train))
naive_rapm_df <- naive_rapm_df[naive_rapm_df$Player != "(Intercept)", ]

# Write rapm_df to a CSV file for the Naive Model
write.csv(naive_rapm_df, "rapm_naive.csv", row.names = FALSE)

# Fit the ridge regression model with hyperparameter tuning
ridge_model <- cv.glmnet(x_train, y_train, alpha = 0, family = "gaussian")

# Get the best lambda
best_lambda <- ridge_model$lambda.min

# Predict using the model with the best lambda
predictions <- predict(ridge_model, s = best_lambda, newx = x_test)

# Calculate Mean Squared Error (MSE) for the ridge_model
ridge_mse <- mean((y_test - predictions)^2)
cat("Ridge Model MSE:", ridge_mse, "\n")

# Get coefficients from the model for the best lambda value
coefficients <- coef(ridge_model, s = best_lambda)

# Convert the sparse matrix to a regular vector
coeff_vector <- as.numeric(coefficients)

# Get the names (i.e., player names) from the coefficients
player_names <- rownames(coefficients)

# Combine names and values into a data frame for Ridge Model
ridge_rapm_df <- data.frame(Player = player_names, RAPM = coeff_vector)
ridge_rapm_df <- ridge_rapm_df[ridge_rapm_df$Player != "(Intercept)", ]

# Write rapm_df to a CSV file for Ridge Model
write.csv(ridge_rapm_df, "rapm_ridge.csv", row.names = FALSE)

# Fit a random forest model (you can adjust hyperparameters as needed)
rf_model <- train(x = x_train, y = y_train, method = "rf")

# Combine models using caretEnsemble
ensemble_model <- caretEnsemble(models = list(ridge = ridge_model, rf = rf_model))

# Predict using the ensemble model
ensemble_predictions <- predict(ensemble_model, newdata = x_test)

# Calculate MSE for the ensemble model
ensemble_mse <- mean((y_test - ensemble_predictions)^2)
cat("Ensemble Model MSE:", ensemble_mse, "\n")

# Get coefficients from the model for the ensemble
ensemble_coefficients <- coef(ensemble_model$finalModel$ridge, s = best_lambda)

# Convert the sparse matrix to a regular vector
ensemble_coeff_vector <- as.numeric(ensemble_coefficients)

# Get the names (i.e., player names) from the coefficients
ensemble_player_names <- rownames(ensemble_coefficients)

# Combine names and values into a data frame for Ensemble Model
ensemble_rapm_df <- data.frame(Player = ensemble_player_names, RAPM = ensemble_coeff_vector)
ensemble_rapm_df <- ensemble_rapm_df[ensemble_rapm_df$Player != "(Intercept)", ]

# Write rapm_df to a CSV file for Ensemble Model
write.csv(ensemble_rapm_df, "rapm_ensemble.csv", row.names = FALSE)


cat("Naive Model MSE:", naive_mse, "\n")
cat("Ridge Model MSE:", ridge_mse, "\n")
cat("Ensemble Model MSE:", ensemble_mse, "\n")