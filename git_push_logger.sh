#!/bin/bash

# Usage: ./git_push_with_log.sh origin main

# Extract branch name from arguments
BRANCH=""
REMOTE=""

for arg in "$@"; do
  if [[ "$arg" == "origin" || "$arg" == "upstream" ]]; then
    REMOTE="$arg"
  elif [[ "$arg" != "git" && "$arg" != "push" ]]; then
    BRANCH="$arg"
  fi
done

if [ -z "$REMOTE" ] || [ -z "$BRANCH" ]; then
  echo "❌ Please provide remote and branch name: e.g., ./git_push_with_log.sh origin main"
  exit 1
fi

# Fetch latest remote data
git fetch "$REMOTE" "$BRANCH"

# Get old commit from remote tracking branch
OLD_COMMIT=$(git rev-parse "$REMOTE/$BRANCH")

# Get new commit (local HEAD)
NEW_COMMIT=$(git rev-parse HEAD)

# Push normally
echo "🔁 Pushing changes to $REMOTE/$BRANCH..."
git push "$REMOTE" "$BRANCH"

# Recalculate new HEAD (in case of fast-forward merge etc.)
NEW_COMMIT=$(git rev-parse HEAD)

# Get all commits between old and new
if [ "$OLD_COMMIT" != "$NEW_COMMIT" ]; then
  COMMITS=$(git log "$OLD_COMMIT".."$NEW_COMMIT" --pretty=format:'{"sha":"%H","author":"%an","message":"%s","timestamp":"%cd"}' | jq -s .)
else
  COMMITS="[]"
fi

# Prepare final JSON entry
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S)
PUSH_ID="push_$(date +%Y%m%d_%H%M%S)"

PUSH_LOG_ENTRY=$(jq -n \
  --arg push_id "$PUSH_ID" \
  --arg branch "$BRANCH" \
  --arg timestamp "$TIMESTAMP" \
  --argjson commits "$COMMITS" \
  '{push_id: $push_id, branch: $branch, timestamp: $timestamp, commits: $commits}'
)

# Append to log file
LOG_FILE="git_push_log.json"
if [ ! -f "$LOG_FILE" ]; then
  echo "[]" > "$LOG_FILE"
fi

jq ". + [$PUSH_LOG_ENTRY]" "$LOG_FILE" > tmp_log && mv tmp_log "$LOG_FILE"

echo "✅ Push and commits logged in $LOG_FILE"
