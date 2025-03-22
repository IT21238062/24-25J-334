from pydantic import BaseModel


class ChatRequest(BaseModel):
    message: str
    sender: str
    createdAt: str
    id: str
    weatherData: dict
