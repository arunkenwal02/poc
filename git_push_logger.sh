#!/bin/bash

branch="main"  # or change to current branch dynamically if needed

echo "🔁 Pushing changes to remote..."
git push origin "$branch"

# Check if push was successful
if [ $? -ne 0 ]; then
    echo "❌ Git push failed."
    exit 1
fi

# Get latest commit SHA
commit_sha=$(git rev-parse HEAD)

# Get commit details and diff
commit_date=$(git show -s --format=%ad --date=iso "$commit_sha")
commit_author=$(git show -s --format=%an "$commit_sha")
commit_message=$(git show -s --format=%s "$commit_sha")
commit_diff=$(git show "$commit_sha" --pretty=format:'')

# Escape the diff for JSON (escape double quotes, backslashes, and newlines)
escaped_diff=$(echo "$commit_diff" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')

# Create JSON entry
json_entry=$(cat <<EOF
{
  "push_id": "$commit_sha",
  "date": "$commit_date",
  "author": "$commit_author",
  "message": "$commit_message",
  "code_diff": $escaped_diff
}
EOF
)

log_file="git_push_log.json"

# If file doesn't exist, initialize with opening bracket
if [ ! -f "$log_file" ]; then
    echo "[" > "$log_file"
else
    # Remove closing bracket to append new entry
    sed -i '' '$ d' "$log_file"
    echo "," >> "$log_file"
fi

# Add the entry and close the array
echo "  $json_entry" >> "$log_file"
echo "]" >> "$log_file"

echo "✅ Commit logged to $log_file"
