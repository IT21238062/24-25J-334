import os

from dotenv import load_dotenv

from app.configs.db import init_db

load_dotenv()

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

from app.routers.chat import router as chat_router
from app.routers.prediction import router as prediction_router
from app.routers.report import router as report_router
from app.routers.weather import router as weather_router

init_db()
os.makedirs("uploaded_files", exist_ok=True)
os.makedirs("reports", exist_ok=True)

fast_api_app = FastAPI()
fast_api_app.include_router(prediction_router)
fast_api_app.include_router(chat_router)
fast_api_app.include_router(weather_router)
fast_api_app.include_router(report_router)

# Mount the reports directory to serve PDF files
fast_api_app.mount("/reports", StaticFiles(directory="reports"), name="reports")
