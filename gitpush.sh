# Function to automatically commit and push, with conflict handling
gitpush() {
    DEFAULT_MESSAGE="Auto commit"
    USE_LINUS=false
    MESSAGE="$DEFAULT_MESSAGE"
    while [ $# -gt 0 ]; do
        case "$1" in
            --linus)
                USE_LINUS=true
                shift
                ;;
            *)
                MESSAGE="$1"
                shift
                ;;
        esac
    done

    # Attempt to pull to ensure we're up to date
    git pull origin "$(git rev-parse --abbrev-ref HEAD)" --no-rebase
    if git status | grep -q "You have unmerged paths"; then
        echo "Merge conflict detected. Resolve with gitresolve? (y/n)"
        read -r response
        if [ "$response" = "y" ]; then
            gitresolve --message "$MESSAGE"
            if [ $? -ne 0 ]; then
                echo "Automatic conflict resolution failed. Resolve manually."
                return 1
            fi
        else
            echo "Aborting push. Resolve conflicts manually."
            return 1
        fi
    fi

    git add .
    if [ "$USE_LINUS" = true ]; then
        CO_AUTHOR="Co-authored-by: Linus Torvalds <torvalds@linux-foundation.org>"
        git commit -m "$MESSAGE" -m "$CO_AUTHOR"
    else
        git commit -m "$MESSAGE"
    fi
    git push
}

# Function to resolve merge conflicts with ours strategy
gitresolve() {
    DEFAULT_MESSAGE="Resolved conflicts with ours strategy"
    MESSAGE="$DEFAULT_MESSAGE"
    BRANCH="master"

    while [ $# -gt 0 ]; do
        case "$1" in
            --branch)
                BRANCH="$2"
                shift 2
                ;;
            --message)
                MESSAGE="$2"
                shift 2
                ;;
            *)
                echo "Usage: gitresolve [--branch <branch>] [--message <message>]"
                return 1
                ;;
        esac
    done

    if git status | grep -q "You have unmerged paths"; then
        echo "Merge conflict detected. Aborting existing merge."
        git merge --abort
    fi

    git fetch origin
    git merge -s ours "origin/$BRANCH" -m "$MESSAGE"
    if [ $? -eq 0 ]; then
        echo "Merge completed with ours strategy."
        git push --force
    else
        echo "Merge failed. Check your branch or resolve conflicts manually."
        return 1
    fi
}