import time

from fastapi import APIRouter, File, HTTPException, UploadFile, status
from h11 import Request

from app.controllers.prediction_controller import (
    predict_crop_controller,
    predict_disease_controller,
    predict_plant_growth_controller,
    predict_soil_type_controller,
    predict_water_level_controller,
)
from app.models.api_models.predict_crop import PredictCrop
from app.models.api_models.response import CustomResponse

router = APIRouter()


@router.get(
    "/predict/water-level",
    tags=["prediction"],
    status_code=200,
    response_model=CustomResponse,
)
def water_level() -> CustomResponse:
    """ """
   # try:

    water_level = predict_water_level_controller()

    return CustomResponse(
        success=True,
        message="Predicted successfully",
        data={
            "water_level": water_level,
        },
        status_code=status.HTTP_200_OK,
    )

    # except Exception as e:
    #     print(e)
    #     if len(e.args) == 2:
    #         raise HTTPException(status_code=e.args[0], detail=e.args[1])
    #     else:
    #         raise HTTPException(
    #             status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e)
    #         )


@router.get(
    "/predict/plant-growth",
    tags=["prediction"],
    status_code=200,
    response_model=CustomResponse,
)
def plant_growth() -> CustomResponse:
    """ """
    try:

        growth_reached = bool(predict_plant_growth_controller())

        return CustomResponse(
            success=True,
            message="Predicted successfully",
            data={
                "growth_reached": growth_reached,
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


@router.post(
    "/predict/crop",
    tags=["prediction"],
    status_code=200,
    response_model=CustomResponse,
)
def crop(request: PredictCrop) -> CustomResponse:
    """ """
    try:
        print(request)
        predicted_crop = predict_crop_controller(request)

        return CustomResponse(
            success=True,
            message="Crop Predicted successfully",
            data={
                "predicted_crop": predicted_crop,
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


@router.post(
    "/predict/disease",
    status_code=200,
    response_model=CustomResponse,
)
async def upload_file(file: UploadFile = File(...)):
    try:
        predicted_disease = await predict_disease_controller(file)

        return CustomResponse(
            success=True,
            message="Disease Predicted successfully",
            data={
                "predicted_disease": predicted_disease,
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


@router.post(
    "/predict/soil-type",
    status_code=200,
    response_model=CustomResponse,
)
async def upload_file(file: UploadFile = File(...)):
    try:
        predicted_soil_type = await predict_soil_type_controller(file)
        return CustomResponse(
            success=True,
            message="Soil Type Predicted successfully",
            data={
                "predicted_soil_type": predicted_soil_type,
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
