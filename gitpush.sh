# function to automatically commit and push, with a twist ;)
gitpush ()
{
    DEFAULT_MESSAGE="Auto commit";
    USE_LINUS=false;
    MESSAGE="$DEFAULT_MESSAGE";
    while [ $# -gt 0 ]; do
        case "$1" in
            --linus)
                USE_LINUS=true;
                shift
            ;;
            *)
                MESSAGE="$1";
                shift
            ;;
        esac;
    done;
    git add .;
    if [ "$USE_LINUS" = true ]; then
        CO_AUTHOR="Co-authored-by: Linus Torvalds <torvalds@linux-foundation.org>";
        git commit -m "$MESSAGE" -m "$CO_AUTHOR";
    else
        git commit -m "$MESSAGE";
    fi;
    git push
}
