from fastapi import APIRouter, HTTPException, status

from app.controllers.weather_controller import get_weather_data_controller
from app.models.api_models.response import CustomResponse

router = APIRouter()


@router.get(
    "/weather",
    tags=["weather"],
    status_code=200,
    response_model=CustomResponse,
)
def plant_growth(city_name: str) -> CustomResponse:
    """ """
    try:

        weather_data = get_weather_data_controller(city_name)
        print(weather_data)

        return CustomResponse(
            success=True,
            message="Predicted successfully",
            data={
                "weather_data": weather_data,
            },
            status_code=status.HTTP_200_OK,
        )

    except Exception as e:
        if len(e.args) == 2:
            raise HTTPException(status_code=e.args[0], detail=e.args[1])
        else:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e)
            )
