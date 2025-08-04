from fastapi import FastAPI, Query
import requests
from urllib.parse import urlparse
import re

app = FastAPI(
    title='Code validator POC', 
    summary= 'To validate the code'
)


@app.post("/fetchpushhistory")
def get_latest_push_events(repo_url: str = Query(...)):
    match = re.match(r"https://github.com/([^/]+)/([^/]+)(?:\.git)?", repo_url)
    if match:
        owner, repo_name_candidate = match.groups()
        repo_name = repo_name_candidate[:-4] if repo_name_candidate.endswith('.git') else repo_name_candidate
    else:
        return {"error": "Invalid GitHub repository URL format"}

    api_url = f"https://api.github.com/repos/{owner}/{repo_name}/events"

    response = requests.get(api_url)

    response.raise_for_status()
    return response.json()


    events = response.json()
    return events[:2]

#### heelll


##### hellllllloooo