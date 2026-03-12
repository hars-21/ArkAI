from ddgs import DDGS


def find_product(title, amazon: bool = True):
    if amazon:
        query = f"{title} insite:amazon.in"
        search = "amazon"
    else:
        query = f"{title} insite:flipkart.in"
        search = "flipkart"

    with DDGS() as ddgs:
        results = list(ddgs.text(query, max_results=10))

    for r in results:
        url = r["href"]
        print(url)

        if search in url:
            return url

    return None
