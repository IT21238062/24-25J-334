from pydantic import BaseModel


class PredictCrop(BaseModel):
    n: int
    p: int
    k: int
    temperature: float
    humidity: float
    ph: float
    rainfall: float

    def to_list(self):
        return [
            self.n,
            self.p,
            self.k,
            self.temperature,
            self.humidity,
            self.ph,
            self.rainfall,
        ]
