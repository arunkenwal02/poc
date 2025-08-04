#!/bin/bash

# Detect upstream branch
REMOTE_BRANCH=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ -z "$REMOTE_BRANCH" ]; then
  echo "❌ No upstream branch found. Run: git push -u origin $CURRENT_BRANCH"
  exit 1
fi

# Get old SHA (last known on remote)
OLD_SHA=$(git rev-parse "$REMOTE_BRANCH" 2>/dev/null)
NEW_SHA=$(git rev-parse HEAD)

# Create a unique push ID and timestamp
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S)
PUSH_ID="push_$(date +%Y%m%d_%H%M%S)"

# Push changes
git push "$@"
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "❌ Push failed. No log created."
  exit $EXIT_CODE
fi

# Log to push_log.txt
echo "==== $PUSH_ID | Branch: $CURRENT_BRANCH | Time: $TIMESTAMP ====" >> push_log.txt
git log $OLD_SHA..$NEW_SHA --pretty=format:"%h | %an | %s | %cd" >> push_log.txt
echo -e "\n" >> push_log.txt

# Create JSON structure
COMMITS_JSON=$(git log $OLD_SHA..$NEW_SHA --pretty=format:'{"sha":"%H","author":"%an","message":"%s","timestamp":"%cd"},')
COMMITS_JSON="[${COMMITS_JSON%,}]"  # remove trailing comma

cat <<EOF >> push_log.json
{
  "push_id": "$PUSH_ID",
  "branch": "$CURRENT_BRANCH",
  "timestamp": "$TIMESTAMP",
  "commits": $COMMITS_JSON
},
EOF

echo "✅ Push logged under $PUSH_ID in push_log.txt and push_log.json"
