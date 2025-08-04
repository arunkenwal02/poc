#!/bin/bash

# Extract branch name from arguments
BRANCH=""
for arg in "$@"; do
  if [[ "$arg" != "origin" && "$arg" != "git" && "$arg" != "push" ]]; then
    BRANCH="$arg"
  fi
done

if [ -z "$BRANCH" ]; then
  echo "❌ Please provide branch name: e.g., git-push-with-log.sh origin main"
  exit 1
fi

# Get old HEAD of remote branch
OLD_COMMIT=$(git rev-parse origin/$BRANCH 2>/dev/null)

# Push normally
git push origin $BRANCH

# Get new HEAD after push
NEW_COMMIT=$(git rev-parse HEAD)

# Get commit details between old and new (if any)
COMMITS_JSON="[]"
if [ "$OLD_COMMIT" != "$NEW_COMMIT" ]; then
  COMMITS_JSON="["
  while read -r sha; do
    author=$(git show -s --format='%an' "$sha")
    message=$(git show -s --format='%s' "$sha")
    timestamp=$(git show -s --format='%cd' "$sha")
    diff=$(git show "$sha" --no-color | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')

    COMMITS_JSON+="
    {
      \"sha\": \"$sha\",
      \"author\": \"$author\",
      \"message\": \"$message\",
      \"timestamp\": \"$timestamp\",
      \"diff\": \"$diff\"
    },"
  done < <(git rev-list $OLD_COMMIT..$NEW_COMMIT)
  COMMITS_JSON="${COMMITS_JSON%,}
  ]"
fi

# Create push entry
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S)
PUSH_ID="push_$(date +%Y%m%d_%H%M%S)"

LOG_ENTRY="{
  \"push_id\": \"$PUSH_ID\",
  \"branch\": \"$BRANCH\",
  \"timestamp\": \"$TIMESTAMP\",
  \"commits\": $COMMITS_JSON
},"

# Append to push_log.json (ensure it's a valid JSON array)
if [ ! -f push_log.json ]; then
  echo "[$LOG_ENTRY]" > push_log.json
else
  TMP_FILE=$(mktemp)
  jq ". += [$LOG_ENTRY]" push_log.json > "$TMP_FILE" && mv "$TMP_FILE" push_log.json
fi

echo "✅ Push and log (with diffs) recorded successfully."
