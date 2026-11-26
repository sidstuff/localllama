import dspy
import os
from typing import List
from playwright.sync_api import sync_playwright
from bs4 import BeautifulSoup
from langchain_community.utilities import SearxSearchWrapper
from html_to_markdown import convert_to_markdown

os.environ["OPENAI_API_KEY"] = ""
lm=dspy.LM("openai/gpt-4o-mini")
dspy.settings.configure(lm=lm, track_usage=True)

number_of_search_results = 1

class MD_Signature(dspy.Signature):
    """
    Generate a detailed summary of the input markdown. Follow these instructions:
        1. Filter out unecessary information
        2. Summary must be in markdown format
    """
    markdown: str = dspy.InputField(desc="Markdown version of a web page")
    summary: str = dspy.OutputField(desc="A detailed summary of the input. Must be in markdown form")

class QuerySignature(dspy.Signature):
    query : str = dspy.InputField(desc="User query")
    summaries : List[str] = dspy.InputField(desc="A list of markdowns based generated from websites")
    answer : str = dspy.OutputField(desc="Answer to the user query based on the summaries provided.")


query = input("Query: ")
search_module = SearxSearchWrapper(searx_host="http://localhost:8888/")
results = search_module.results(query=query, num_results=number_of_search_results)

markdown_summarizer = dspy.ChainOfThought(MD_Signature)
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
            md = convert_to_markdown(soup, strip=["svg"])
            results = markdown_summarizer(markdown=md)
            summaries.append(results.summary)

    results = answer_query(query=query, summaries=summaries)
    print(f"reasoning={results.answer}")
    print("answer=")
    print(results.answer)
    cost = sum([x['cost'] for x in lm.history if x['cost'] is not None])
    print(f"\ncost={cost}$")
