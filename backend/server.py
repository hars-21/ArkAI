from asyncio import sleep

from fastapi import FastAPI
from pydantic import BaseModel

from main import call_agent

app = FastAPI()


class Data(BaseModel):
    url: str


@app.post("/analyze")
async def analyze(data: Data):
    try:
        response = call_agent(data.url)
        print(response)
        return response
    except:
        await sleep(5)
        print("error ")
        return {
            "title": "Product Title",
            "price": "Product Price",
            "about": "Product Description",
            "budget_score": 0,
            "planet_score": 0,
            "health_score": 0,
            "life_score": 0
                }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
