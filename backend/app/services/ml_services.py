import pickle

import h5py
import joblib  # type: ignore
import numpy as np
import pandas as pd
import torch
import xgboost as xgb
from PIL import Image
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image
from torchvision import transforms

from app.models.api_models.ml.type import Type
from app.models.api_models.predict_crop import PredictCrop

# Load the model
wl_classifier = joblib.load("models/water_level_predictor copy.joblib")
cp_classifier = joblib.load("models/crop_predictor.joblib")

# # Save the models as pickle files
# with open("plant_growth_model1.pkl", "rb") as f:
#     pg_model1: xgb.Booster = pickle.load(f)
# with open("plant_growth_model2.pkl", "rb") as f:
#     pg_model2: xgb.Booster = pickle.load(f)

# model1 = xgb.Booster()
# model2 = xgb.Booster()

# with open("plant_growth_model1.pkl", "rb") as f:
#     model1 = pickle.load(f)
# with open("plant_growth_model2.pkl", "rb") as f:
#     pickle.loads(f, model2)


def load_xgboost_h5(filename):
    """
    Load XGBoost model from .h5 format.
    """
    with h5py.File(filename, "r") as h5file:
        model_json = h5file["xgboost_model"][()].decode("utf-8")  # Read as JSON
    model = xgb.Booster()
    model.load_model(model_json)  # Load model from JSON format
    return model


# Load models
# loaded_model1 = load_xgboost_h5("models/model1.h5")
# loaded_model2 = load_xgboost_h5("models/model2.h5")

model1 = joblib.load("models/plant_growth_model1.joblib")
model2 = joblib.load("models/plant_growth_model2.joblib")

loaded_model = Type(input=16 * 3 * 3, output=5)

# Load the saved state dictionary
loaded_model.load_state_dict(torch.load("models/model.pth"))

# Set the model to evaluation mode
loaded_model.eval()
print("Model loaded successfully and ready for predictions.")

# Load the entire model back
disease_model = load_model("models/plant_leaf_model.h5")
print("Model loaded successfully.")


cp_encoding = [
    "Brinjal",
    "Ladyfinger",
    "Tomatoes",
    "kidneybeans",
    "pigeonpeas",
    "mothbeans",
    "mungbean",
    "blackgram",
    "lentil",
    "pomegranate",
    "banana",
    "mango",
    "grapes",
    "watermelon",
    "muskmelon",
    "apple",
    "orange",
    "papaya",
    "coconut",
    "cotton",
    "jute",
    "coffee",
]

all_labels = ["Potato-Early_blight", "Corn-Common_rust", "Tomato-Bacterial_spot"]

human_readable_labels = {
    "Potato-Early_blight": "Potato Early Blight",
    "Corn-Common_rust": "Corn Common Rust",
    "Tomato-Bacterial_spot": "Tomato Bacterial Spot",
}


# Function to predict water level
def predict_water_level(soil_moisture_value, soil_temperature_value) -> int:
    """
    Predict water level based on soil moisture and temperature.
    """
    # Prepare data for prediction
    input_data = np.array([[soil_moisture_value, soil_temperature_value]])

    # Predict water level
    predicted_level = wl_classifier.predict(input_data)
    return int(predicted_level[0])


# Function to predict a single data point
def predict_single_datapoint(
    model: xgb.Booster, single_data: dict[str, float], features: list[str]
) -> float:
    df = pd.DataFrame([single_data])
    df = df[features]

    d_single = xgb.DMatrix(df)
    print(d_single)
    return model.predict(d_single)[0]


def predict_plant_growth(data_points: dict[str, float]) -> bool:
    # Make predictions using both models

    print(data_points)
    prob_prediction1 = predict_single_datapoint(
        model1, data_points, ["Light_Intensity", "gas"]
    )
    print(prob_prediction1)
    prob_prediction2 = predict_single_datapoint(
        model2, data_points, ["Temperature", "Humidity"]
    )
    print(prob_prediction2)
    # Combine the predictions
    combined_prob = (prob_prediction1 + prob_prediction2) / 2
    print(combined_prob)
    return combined_prob > 0.5
    # return True


def predict_crop(cropData: PredictCrop) -> str:
    prediction = cp_classifier.predict(np.array([cropData.to_list()]))

    result = np.argmax(prediction)

    return cp_encoding[result]


def predict_soil_type(image_path: str) -> str:

    image = Image.open(image_path)

    # Same transformation as used during training
    transform = transforms.Compose(
        [
            transforms.Resize((28, 28)),
            transforms.ToTensor(),
        ]
    )

    # Preprocess the image and prepare it for the model
    image_tensor = transform(image).unsqueeze(0)  # Add batch dimension

    # Predict using the loaded model
    with torch.no_grad():
        output = loaded_model(image_tensor)
        _, predicted_class = torch.max(output, 1)
        predicted_soil_type = {
            0: "Black Soil",
            1: "Cinder Soil",
            2: "Laterite Soil",
            3: "Peat Soil",
            4: "Yellow Soil",
        }[predicted_class.item()]

    return predicted_soil_type


def load_and_prepare_image(file_path):
    img = image.load_img(
        file_path, target_size=(256, 256)
    )  # Ensure the input shape is the same as the model's input
    img_array = image.img_to_array(img)  # Convert the image to an array
    img_array = np.expand_dims(img_array, axis=0)  # Add a batch dimension
    return img_array


def predict_disease(image_path: str) -> str:

    # Example usage
    prepared_image = load_and_prepare_image(image_path)

    # Predict using the loaded model
    predictions = disease_model.predict(prepared_image)
    predicted_class = np.argmax(
        predictions[0]
    )  # Get the index of the highest probability class
    predicted_disease = human_readable_labels[all_labels[predicted_class]]

    return predicted_disease


if __name__ == "__main__":
    print(predict_water_level(0.04882, 25))

    print(
        predict_crop(
            {
                "n": 10,
                "p": 10,
                "k": 10,
                "temperature": 10,
                "humidity": 10,
                "ph": 10,
                "rainfall": 10,
            }
        )
    )
