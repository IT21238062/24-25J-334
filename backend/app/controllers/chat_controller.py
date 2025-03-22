import json
import os
import uuid
from datetime import datetime

from app.models.api_models.chat import ChatRequest
from app.services.chat_services import get_gemini_response


def get_chat_response_controller(message: ChatRequest) -> str:
    # Get the response from the Gemini API
    response = get_gemini_response(message.message, message.weatherData)

    # Save the response in json
    chats = []
    if os.path.exists("response.json"):
        with open("response.json", "r") as f:
            chats = json.load(f)

    response_generated = {
        "sender": "assistant",
        "message": response,
        "id": str(uuid.uuid4()),
        "createdAt": datetime.now().isoformat(),
    }

    chats.extend([message.model_dump(), response_generated])

    with open("response.json", "w") as f:
        json.dump(chats, f)

    # Return the response
    return response_generated


def chat_history_controller() -> list[dict]:
    if os.path.exists("response.json"):
        with open("response.json", "r") as f:
            return json.load(f)
    else:
        return []


def delete_chat_history_controller() -> str:
    if os.path.exists("response.json"):
        os.remove("response.json")
        return "Chat history deleted"
    else:
        return "Chat history not found"
