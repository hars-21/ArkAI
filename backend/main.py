import json
import os

import dotenv
from langchain.agents import create_agent
from langchain_core.messages import HumanMessage, SystemMessage
from langchain_groq import ChatGroq
from pydantic import BaseModel, SecretStr

from toolchain.amazon import amazon_url, amazon_url_resolver
from toolchain.flipkart import flipkart_url

dotenv.load_dotenv()


class Score(BaseModel):
    title: str
    price: str
    about: str
    budget_score: int
    planet_score: int
    health_score: int
    life_score: int


model = ChatGroq(
        model="openai/gpt-oss-120b",
        temperature=0.1,
        api_key=SecretStr(os.getenv("GROQ", ""))
        )



system_prompt = """
You are a helpful assistant for fetching price & about sections of a product
from Amazon and Flipkart.

You can use the available tools to fetch product data.

After fetching data analyze it and produce these scores:

Budget Score:
Compare the price to market averages and evaluate price-to-feature ratio.
Score 0–10 (0 = very expensive, 10 = very affordable)

Planet Score:
Check materials, eco friendliness, certifications, in case of saree or cloth give 7 to 9 guess accordingly on unefficient data.
Score 0–10

Health Score:
Check chemicals, safety certifications, ergonomic design.
Score 0–10

Life Score:
Evaluate durability, warranty, longevity.
Score 0–10


RESPONSE FORMAT:
{
    "title": "Product Title",
    "price": "Product Price",
    "about": "Product Description",
    "budget_score": 0-10,
    "planet_score": 0-10,
    "health_score": 0-10,
    "life_score": 0-10
}
"""


agent = create_agent(
        model=model,
        tools=[amazon_url, flipkart_url],
        system_prompt=SystemMessage(content=system_prompt),
        )


def call_agent(url: str):
    response = agent.invoke({
        "messages": [
            HumanMessage(
                content=url
            )
        ]
    })

    return json.loads(response["messages"][-1].content)


# response = agent.invoke({
#     "messages": [
#         HumanMessage(
#             content="https://www.amazon.in/Ripped-Up-Nutrition-Protein-Original/dp/B07R5V293N/"
#         )
#     ]
# })

# json.loads(response["messages"][-1].content)


if __name__ == "__main__":
    print(amazon_url_resolver("https://www.amazon.in/Ripped-Up-Nutrition-Protein-Hazelnut/dp/B08CXY8WH2/"))
