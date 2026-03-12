from ddgs import DDGS


def find_product(title):
    query = f"{title} site:amazon.in OR site:flipkart.com"

    with DDGS() as ddgs:
        results = list(ddgs.text(query, max_results=10))

    for r in results:
        url = r["href"]

        if "amazon.in" in url or "flipkart.com" in url:
            return url

    return None


print(find_product("Ripped Up Nutrition Protein Pancake Mix 500g"))
