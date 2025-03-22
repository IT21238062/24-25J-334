from typing import List

from app.services.weather_services import get_weather_data


def get_weather_data_controller(city_name: str) -> List:
    return list(get_weather_data(city_name))
