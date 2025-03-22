import csv
import os
from datetime import datetime
from typing import Literal

from fastapi import UploadFile

from app.models.api_models.predict_crop import PredictCrop
from app.services.db_services import get_sensor_data
from app.services.ml_services import (
    predict_crop,
    predict_disease,
    predict_plant_growth,
    predict_soil_type,
    predict_water_level,
)


def predict_water_level_controller() -> int:

    # get sensor data from db
    sensor_data: dict[str, int | float] = get_sensor_data()

    print(sensor_data)

    # Extract relevant data
    current_soil_moisture = sensor_data.get("Soil_moisture", 0.04882)  # Already a float
    current_soil_temperature = sensor_data.get(
        "Soil_temperature", 30.6875
    )  # Already a float

    # If `current_soil_moisture` is a percentage (e.g., 0.04882 for 4.882%), convert it
    current_soil_moisture *= 100  # Convert to percentage

    # Get prediction
    return predict_water_level(current_soil_moisture, current_soil_temperature)


def predict_plant_growth_controller() -> bool:

    # get sensor data from db
    sensor_data: dict[str, int | float] = get_sensor_data()

    if not sensor_data:
        sensor_data = {}

    # Extract relevant data
    data_points = {
        "Light_Intensity": sensor_data.get("Light_sense", 0.0),
        "Temperature": sensor_data.get("Temperature", 0.0),
        "Humidity": sensor_data.get("Humidity", 0.0),
        "gas": sensor_data.get("Smoke", 0.0),
    }

    # Get prediction
    prediction = predict_plant_growth(data_points)
    print(prediction)
    return prediction


def predict_crop_controller(cropPredictData: PredictCrop) -> str:
    crop_prediction = predict_crop(cropPredictData)

    # Get current timestamp
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Ensure the directory exists
    os.makedirs("data/predictions", exist_ok=True)
    csv_path = os.path.join("data/predictions", "crop_predictions.csv")

    # Check if file exists to determine if we need to write headers
    file_exists = os.path.isfile(csv_path)

    # Write to CSV with proper columns
    with open(csv_path, "a", newline="") as csvfile:
        fieldnames = [
            "Timestamp",
            "N",
            "P",
            "K",
            "Temperature",
            "Humidity",
            "pH",
            "Rainfall",
            "Predicted_Crop",
        ]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        # Write header only if file doesn't exist
        if not file_exists:
            writer.writeheader()

        # Write data row
        writer.writerow(
            {
                "Timestamp": timestamp,
                "N": cropPredictData.n,
                "P": cropPredictData.p,
                "K": cropPredictData.k,
                "Temperature": cropPredictData.temperature,
                "Humidity": cropPredictData.humidity,
                "pH": cropPredictData.ph,
                "Rainfall": cropPredictData.rainfall,
                "Predicted_Crop": crop_prediction,
            }
        )

    return crop_prediction


async def predict_soil_type_controller(file: UploadFile) -> str:
    file_path = f"uploaded_files/{file.filename}"
    contents = await file.read()
    with open(file_path, "wb") as f:
        f.write(contents)

    predicted_soil_type = predict_soil_type(file_path)
    return predicted_soil_type


async def predict_disease_controller(file: UploadFile) -> str:
    file_path = f"uploaded_files/{file.filename}"
    contents = await file.read()
    with open(file_path, "wb") as f:
        f.write(contents)

    predicted_disease = predict_disease(file_path)
    return predicted_disease
