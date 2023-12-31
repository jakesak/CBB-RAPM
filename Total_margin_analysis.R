library(glmnet)
library(biglm)
library(caret)
library(caretEnsemble)

stints <- readRDS("stints.rds")
player_mins <- read.csv("player_mins.csv")

low_mins_players <- subset(player_mins, mins < 100)$players
columns_to_remove <- which(colnames(stints) %in% c(low_mins_players, "Home_Margin", "Away_Margin"))
stints <- stints[, -columns_to_remove, drop = FALSE]

set.seed(123)  # Setting a seed for reproducibility
sample_index <- sample(seq_len(nrow(stints)), size = 0.8 * nrow(stints))

train_data <- stints[sample_index, ]
test_data <- stints[-sample_index, ]

# Get the column index for "Margin" (and other columns if needed)
margin_col_index <- which(colnames(stints) == "Margin")

# Set the response variable
y_train <- train_data[, margin_col_index]
x_train <- train_data[, -c(margin_col_index), drop = FALSE]

y_test <- test_data[, margin_col_index]
x_test <- test_data[, -c(margin_col_index), drop = FALSE]

# Fit the ridge regression model
ridge_model <- glmnet(x_train, y_train, alpha = 0, family = "gaussian")

# Use cross-validation to determine the best lambda
cv_ridge <- cv.glmnet(x_train, y_train, alpha = 0, family = "gaussian")
best_lambda <- cv_ridge$lambda.min

# Predicting using the model with the best lambda
predictions <- predict(ridge_model, s = best_lambda, newx = x_test)

# Get coefficients from the model for the best lambda value
coefficients <- coef(ridge_model, s = best_lambda)

# Convert the sparse matrix to a regular vector
coeff_vector <- as.numeric(coefficients)

# Get the names (i.e., player names) from the coefficients
player_names <- rownames(coefficients)

# Combine names and values into a data frame
rapm_df <- data.frame(Player = player_names, RAPM = coeff_vector)
rapm_df <- rapm_df[rapm_df$Player != "(Intercept)", ]
rapm_df <- rapm_df[order(rapm_df$RAPM, decreasing = TRUE), ]

# Write rapm_df to a CSV file
write.csv(rapm_df, "total_rapm.csv", row.names = FALSE)

# Evaluation
mse <- mean((y_test - predictions)^2)
cat("Mean Squared Error:", mse, "\n")



#Naive model test
# Fit the naive model (using mean of training data)
naive_predictions <- rep(mean(y_train), length(y_test))

# Calculate Mean Squared Error (MSE) for the naive model
naive_mse <- mean((y_test - naive_predictions)^2)
cat("Naive Model MSE:", naive_mse, "\n")
