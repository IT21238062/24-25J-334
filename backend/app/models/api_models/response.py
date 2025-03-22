from pydantic import BaseModel, ConfigDict


class CustomResponse(BaseModel):
    success: bool
    message: str
    data: dict | None = None
    status_code: int = 200

    model_config = ConfigDict(arbitrary_types_allowed=True)

    def to_dict(self):
        return {
            "success": self.success,
            "message": self.message,
            "data": self.data or {},
        }
