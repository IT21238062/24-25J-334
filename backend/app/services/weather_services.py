import os

import requests

# Replace with your API key
API_KEY = os.getenv("OPENWEATHER_API_KEY")

# API endpoint for current weather
BASE_URL = os.getenv("OPENWEATHER_BASE_URL")


def get_weather_data(city_name: str) -> tuple[float, str, int, float, str]:
    try:
        response = requests.get(
            f"{BASE_URL}?q={city_name}&appid={API_KEY}&units=metric"
        )
        response.raise_for_status()  # Raise an exception for bad status codes
        data = response.json()

        print(data)

        temperature = data["main"]["temp"]
        description = data["weather"][0]["description"]
        humidity = data["main"]["humidity"]
        wind_speed = data["wind"]["speed"]

        if description == "broken clouds" or description == "thunderstorm":
            message = "There is a chance of Raining tomorrow so no need for watering"

        elif description == "shower rain" or description == "rain":
            message = "There is Raining so no need for watering"

        elif (
            description == "clear sky"
            or description == "few clouds"
            or description == "scattered clouds"
        ):
            message = "Sky is clear need to water tomorrow"

        else:
            message = "There is no chance of raining so need to water the plants"

        return temperature, description, humidity, wind_speed, message
    except requests.exceptions.RequestException as e:
        print(f"An error occurred: {e}")
        return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None


if __name__ == "__main__":
    print(get_weather_data("Colombo"))
