from fastapi import FastAPI
from pydantic import BaseModel

from main import call_agent

app = FastAPI()


class Data(BaseModel):
    url: str


@app.post("/analyze")
async def analyze(data: Data):
    return call_agent(data.url)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
