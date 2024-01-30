# College Basketball Player Performance Analysis in R

## Project Overview

This project is focused on conducting a comprehensive analysis of college basketball games using the BigBallR package in R. The primary goal is to parse, clean, and effectively organize play-by-play data from college basketball games. The analysis involves segmenting the data into stints where the same 10 players are on the court and calculating point per possession averages for these periods. This project culminates in a detailed dataframe that includes player-specific stints and their performance differentials. Additionally, it filters out players who have played less than 100 minutes and applies three types of regression analysis: a basic naive model for comparison as well as a ridge regression model and an ensemble model.

## Features

- **Data Parsing and Cleaning:** Leverages the BigBallR package to parse and clean play-by-play data from college basketball games.
- **Stint Analysis:** Segments the game data into stints based on the same 10 players being on the court.
- **Performance Metrics:** Calculates and analyzes point per possession differentials for each stint.
- **Dataframe Construction:** Integrates stint-specific data into a comprehensive dataframe for detailed analysis.
- **Player Filtering:** Focuses on players with more than 100 minutes of game time for more meaningful insights.
- **Regression Analysis:** Implements a basic naive model and advanced ridge regression and ensemble models for thorough analysis.

## Installation

Before starting, ensure R and RStudio are installed on your system. Then, follow these steps:

1. Clone this repository: git clone https://github.com/jakesak/CBB-RAPM.git
2. Open RStudio and set your working directory to the cloned repository
3. Install the required R packages (if not already installed)

## Usage

To run the analysis, open the main R script and execute it in RStudio. The script will process the data according to the project's methodology and output the results.

## Contributing

Interested in contributing? Here's how you can help:

1. Fork the repository.
2. Create a new branch for your feature (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a pull request.

## License

This project is distributed under the MIT License. See `LICENSE` for more information.

## Contact

Jacob Sak - [jsak@wisc.edu](mailto:jsak@wisc.edu)

Project Link: [https://github.com/jakesak/CBB-RAPM](https://github.com/jakesak/CBB-RAPM)




