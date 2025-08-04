# git_push_logger.py
import sys
from datetime import datetime
import json

branch = sys.argv[1]
timestamp = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
push_id = f"push_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

log_entry = {
    "push_id": push_id,
    "branch": branch,
    "timestamp": timestamp,
    "commits": []  # You can enhance this to include commits if needed
}

try:
    with open("push_log.json", "r+") as f:
        logs = json.load(f)
        logs.append(log_entry)
        f.seek(0)
        json.dump(logs, f, indent=2)
except FileNotFoundError:
    with open("push_log.json", "w") as f:
        json.dump([log_entry], f, indent=2)
