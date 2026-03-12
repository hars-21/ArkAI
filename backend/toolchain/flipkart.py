import requests
from langchain.tools import tool
from selectolax.parser import HTMLParser

# from util import find_product


def flipkart_url_resolver(url: str):
    print("Flipkart tool called")
    while True:
        print("flipkart got issues reruning")
        try:
            response = requests.get(url, headers={"User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0"})
            tree = HTMLParser(response.text)
            price = tree.css_first("div.v1zwn20:nth-child(1)").text()
            title = tree.css_first("div.fWi7J_:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(3) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1)").text()
            about_node = tree.css_first("div.fWi7J_:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(12) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1)")
            if about_node: break
        except Exception:
            continue
    about = ""
    if about_node:
        for tag in about_node.css("script, style, noscript, comments"):
            tag.decompose()
        about = about_node.text(separator=" ", strip=True).replace('\u200e','')
    print("flipkart completed")

    return {
            "title": title,
            "price": price,
            "about": about,
            }


@tool("flipkart_get_by_url", description="fetches price, about sections from given flipkart product url")
def flipkart_url(url: str):
    return flipkart_url_resolver(url)


# # @tool("flipkart_get_by_title", description="fetches price, about sections from given flipkart product title")
# def flipkart_name(title: str):
#     url = find_product(title, amazon=False)
#     if url:
#         print("Flipkart url", url)
#         return flipkart_url_resolver(url)
