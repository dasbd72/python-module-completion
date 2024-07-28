# man page for "complete": https://manpages.ubuntu.com/manpages/noble/en/man7/bash-builtins.7.html
_python_target() {
    local cur prev opts

    # Retrieving the current typed argument
    cur="${COMP_WORDS[COMP_CWORD]}"
    # Retrieving the previous typed argument ("-m" for example)
    prev="${COMP_WORDS[COMP_CWORD - 1]}"

    # Preparing an array to store available list for completions
    # COMREPLY will be checked to suggest the list
    COMPREPLY=()

    # Here, we only handle the case of "-m"
    # we want to leave the autocomplete of the standard usage to the default,
    # so COMREPLY stays an empty array and we fallback through "-o default"
    if [[ "$prev" != "-m" ]]; then
        return 0
    fi

    # Ensure package exists
    # PACKAGE_PATH=replace_this_by_your_package_path
    PACKAGE_PATH=.
    if [[ ! -e "$PACKAGE_PATH" ]]; then
        echo "$PACKAGE_PATH does not exist on your computer ?"
        return 0
    fi

    # Otherwise, first we retrieve all paths of folder and .py files inside the <your_package> package,
    # we keep only the package related section, remove the .py extension and convert their separators into dots
    # opts="$(find $PACKAGE_PATH/your_package -type d -o -regex ".*py" | sed "s|$PACKAGE_PATH||" | sed "s|\.py||" | sed -e 's+/+.+g' -e 's/^\.//')"
    opts="$(find $PACKAGE_PATH -type d -o -regex ".*py" | sed "s|$PACKAGE_PATH||" | sed "s|\.py||" | sed -e 's+/+.+g' -e 's/^\.//')"

    # Then we store the whole list by invoking "compgen" and filling COMREPLY with its output content.
    # To mimick standard bash autocompletions we truncate autocomplete to the next folder (identified by dots)
    COMPREPLY=($(compgen -W "$opts" -- "$cur" | sed "s|\($cur.[^.]*\).*|\1|" | uniq))
}

complete -F _python_target -o nospace -o bashdefault -o default python
# nospace disables printing of a space at the end of autocomplete,
# it allows to chain the autocomplete but:
# - removes the indication on end of chain that only one match was found.
# - removes the addition of the trailing / for standard python completion on folders