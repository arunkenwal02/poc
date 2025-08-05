import re
import json
import requests
from fastapi import FastAPI, Query, HTTPException

app = FastAPI()

@app.post("/fetchpushhistory")
def get_latest_push_events(repo_url: str = Query(...)):
    # Parse GitHub repo URL
    match = re.match(r"https://github.com/([^/]+)/([^/]+)(?:\.git)?", repo_url)
    if not match:
        raise HTTPException(status_code=400, detail="❌ Invalid GitHub repository URL format.")

    owner, repo_name_candidate = match.groups()
    repo_name = repo_name_candidate[:-4] if repo_name_candidate.endswith('.git') else repo_name_candidate

    # Fetch latest events from GitHub API
    api_url = f"https://api.github.com/repos/{owner}/{repo_name}/events"
    response = requests.get(api_url)
    events = response.json()
    return events

    # if response.status_code != 200:
    #     raise HTTPException(status_code=response.status_code, detail="❌ GitHub API error.")


    # Load local push_log.json
    # try:
    #     with open("git_push_log.json", "r") as f:
    #         lines = f.read().strip().rstrip(',')
    #         logs = json.loads(f"[{lines}]")
    #         print(logs[0])
    # except Exception as e:
    #     raise HTTPException(status_code=500, detail=f"❌ Failed to read push_log.json: {str(e)}")

    # return logs





