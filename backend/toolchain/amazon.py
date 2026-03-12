import requests
from langchain.tools import tool
from selectolax.parser import HTMLParser


def amazon_url_resolver(url: str):
    print("Amazon tool called")
    response = requests.get(url, headers={"User-Agent": "Mozilla/4.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/120.0"})
    tree = HTMLParser(response.text)
    title = tree.css_first("#title").text()
    price = tree.css_first("span.a-price:nth-child(3) > span:nth-child(2) > span:nth-child(2)").text()
    about_node = tree.css_first("#prodDetails")
    # offer_node = tree.css_first(".a-carousel-transition-a-carousel-moveOneBox")
    about = ""
    # offer = ""
    if about_node:
        for tag in about_node.css("script, style, noscript, comments"):
            tag.decompose()
        sections = about_node.css(".a-section")
        if sections:
            sections[3].decompose()
            about = about_node.text(separator=" ", strip=True).replace('\u200e','')
    # if offer_node:
    #     for tag in offer_node.css("script, style, noscript, comments"):
    #         tag.decompose()

#         offer = offer_node.text(separator=" ", strip=True).replace('\u200e','')

    return {
            "title": title.strip(),
            "price": price.strip(),
            "about": about.strip().replace('  ', ' ').replace("   ", ' '),
            }


@tool("amazon_get_by_url", description="fetches price, about sections from given amazon product url")
def amazon_url(url: str):
    return amazon_url_resolver(url)


# @tool("amazon_get_by_title", description="fetches price, about sections from given amazon product title")
# def amazon_name(title: str):
#     url = find_product(title)
#     if url:
#         return amazon_url_resolver(url)
