import dspy
import os
from typing import List
from playwright.sync_api import sync_playwright
from bs4 import BeautifulSoup
from langchain_community.utilities import SearxSearchWrapper

lm=dspy.LM("openai/inkling-2-mini", api_base="http://dietpi:9931/v1", api_key="", model_type='chat', cache=False)
dspy.settings.configure(lm=lm, track_usage=True)

number_of_search_results = 1

class QuerySignature(dspy.Signature):
    query : str = dspy.InputField(desc="User query")
    summaries : List[str] = dspy.InputField(desc="A list of markdowns based generated from websites")
    answer : str = dspy.OutputField(desc="Answer to the user query based on the summaries provided.")


query = input("Query: ")
search_module = SearxSearchWrapper(searx_host="http://localhost:8888/")
results = search_module.results(query=query, num_results=number_of_search_results)

answer_query = dspy.ChainOfThought(QuerySignature)

with sync_playwright() as pw:
    browser = pw.firefox.launch(headless=True)
    context = browser.new_context()
    summaries = []

    for r in results:
        link = r['link']
        answer = input(f"Pull data from [{link}]?")
        if answer.lower() in ["y","yes"]:
            page = context.new_page()
            page.goto(link)
            soup = BeautifulSoup(page.content(), 'html.parser')
            summaries.append(html_to_markdown.convert(soup, strip=["svg"]))

    results = answer_query(query=query, summaries=summaries)
    print(f"reasoning={results.answer}")
    print("answer=")
    print(results.answer)
    cost = sum([x['cost'] for x in lm.history if x['cost'] is not None])
    print(f"\ncost={cost}$")
