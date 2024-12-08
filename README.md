# 24-25J-334
# Smart Vertical and Urban Farming System

The Smart Vertical and Urban Farming System is an advanced solution for modern agriculture, particularly designed for urban and vertical farming environments. It integrates IoT, machine learning, and cloud-based technologies to optimize water usage, monitor environmental conditions, and provide soil nutrition recommendations for sustainable farming practices.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Data Details](#data-details)
- [Technologies Used](#technologies-used)
- [Installation](#installation)
- [Usage](#usage)
  - [Water Control System](#water-control-system)
  - [Environmental Monitoring System](#environmental-monitoring-system)
  - [Soil Nutrition Control System](#soil-nutrition-control-system)
- [Project Structure](#project-structure)
- [Repository](#repository)
- [Contributing](#contributing)
- [License](#license)

## Overview

This project provides an automated and data-driven approach to farming with three core modules:
1. **Water Control System**: Predicts water levels and automates irrigation based on soil moisture data.
2. **Environmental Monitoring System**: Monitors conditions such as temperature, humidity, and light intensity.
3. **Soil Nutrition Control System**: Recommends suitable crops and fertilizers based on soil nutrient data.

## Features

- **Water Level Prediction and Control**:
  - Predicts water requirements using machine learning models.
  - Automates irrigation using IoT-based control systems.
- **Environmental Monitoring**:
  - Tracks key environmental parameters in real-time.
  - Alerts users of critical changes.
- **Soil Nutrition and Crop Recommendation**:
  - Recommends suitable crops and fertilizers based on soil data.
  - Supports sustainable farming practices.
- **Real-time Data Integration**:
  - Uses Firebase for live data synchronization and storage.

## Data Details

The project utilizes datasets for soil, environmental conditions, and plant growth analysis. Additional data can be found in the following [Google Drive folder](https://drive.google.com/drive/folders/1OpD7bPpXCqFIzFna7T40azRU2hrHf6hx?usp=drive_link).

## Technologies Used

- **Programming Languages**: Python
- **Machine Learning**: Scikit-learn, Joblib
- **IoT and Automation**: Arduino/ESP-based systems
- **Cloud Storage**: Firebase, Kaggle
- **Data Analysis**: CSV datasets for soil and environmental conditions
- **Notebook Environment**: Jupyter Notebooks
- **APIs and Credentials**:
  - Firebase credentials: `agro-farming-5ca96-firebase-adminsdk.json`
  - Kaggle integration: `kaggle.json`

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/IT21238062/24-25J-334.git
   cd 24-25J-334
   
## Usage

1.Water Control System
Upload soil moisture data (soil_readings.csv) for analysis.
Run the Watercontroll_system.ipynb notebook.
Use the trained water level predictor (water_level_predictor.joblib) to automate irrigation control.

2.Environmental Monitoring System
Use the environmental_condition1.ipynb notebook to analyze environmental parameters.
Monitor temperature, humidity, and light intensity for real-time insights.

3.Soil Nutrition Control System
Use the Copy_of_soil_crop_recommendation.ipynb notebook for crop recommendations.
Data inputs include soil nutrient levels and environmental conditions.
Access additional insights using Modified_Crop_recommendation1.csv.

## Project Structure

smart-vertical-urban-farming-system/
│
├── agro-farming-5ca96-firebase-adminsdk.json   # Firebase credentials
├── kaggle.json                                # Kaggle credentials
├── soil_readings.csv                          # Soil moisture data
├── cleaned_plant_growth.csv                   # Cleaned plant growth data
├── Modified_Crop_recommendation1.csv          # Crop recommendation data
├── Watercontroll_system.ipynb                 # Water control notebook
├── environmental_condition1.ipynb             # Environmental condition analysis
├── Copy_of_soil_crop_recommendation.ipynb     # Soil and crop recommendation
├── water_level_predictor.joblib               # Pre-trained water level model
├── README.md                                  # Project documentation
└── requirements.txt                           # Python dependencies


