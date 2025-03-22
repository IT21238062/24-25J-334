from fastapi import APIRouter

from app.controllers.chat_controller import (
    chat_history_controller,
    delete_chat_history_controller,
    get_chat_response_controller,
)
from app.models.api_models.chat import ChatRequest

router = APIRouter()


@router.post("/chat")
async def chat_endpoint(request: ChatRequest):
    print(request.message)
    response_generated = get_chat_response_controller(request)

    return {
        "success": True,
        "message": "Message received",
        "data": response_generated,
        "status_code": 200,
    }


@router.get("/chat/history")
async def get_chat_history():
    chats = chat_history_controller()
    return {
        "success": True,
        "message": "Chat history retrieved",
        "data": {
            "chats": chats,
        },
        "status_code": 200,
    }


@router.delete("/chat/history")
async def delete_chat_history():
    message = delete_chat_history_controller()
    return {
        "success": True,
        "message": message,
        "status_code": 200,
    }
