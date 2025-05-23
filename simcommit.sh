#!/bin/bash

# Check if repository directory is provided
REPO_DIR=$1
if [ -z "$REPO_DIR" ]; then
    echo "Usage: $0 <repo_directory>"
    exit 1
fi

# Change to the repository directory
cd "$REPO_DIR" || exit 1

# Pull latest changes from the current branch
git pull origin "$(git rev-parse --abbrev-ref HEAD)" --no-rebase

# Generate a random number of commits between 1 and 10
num_commits=$((1 + RANDOM % 10))

# Array of semi-realistic commit messages
messages=("Update readme" "Fix bug" "Refactor code" "Add feature" "Remove deprecated code" "Improve performance" "Write tests" "Update dependencies" "Fix typo" "Enhance UI")
num_messages=${#messages[@]}

# Create the random number of empty commits
for i in $(seq 1 $num_commits); do
    random_index=$((RANDOM % num_messages))
    message="${messages[$random_index]}"
    git commit --allow-empty -m "Auto: $message"
done

# Push the commits to the remote repository
git push
