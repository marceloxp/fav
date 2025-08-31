#!/bin/bash

FAV_FILE="$HOME/.fav_dirs"

fav() {
    [ ! -f "$FAV_FILE" ] && touch "$FAV_FILE"

    local arg="${1:-}"
    local next_arg="${2:-}"

    # Handle command-line options
    if [ -n "$arg" ]; then
        case "$arg" in
            -a)
                local dir_to_add
                if [ -z "$next_arg" ]; then
                    dir_to_add=$(pwd)
                else
                    dir_to_add="$next_arg"
                fi
                if [ -d "$dir_to_add" ]; then
                    if ! grep -Fxq "$dir_to_add" "$FAV_FILE"; then
                        echo "$dir_to_add" >> "$FAV_FILE"
                        echo "Added: $dir_to_add"
                    else
                        echo "Directory is already in favorites."
                    fi
                else
                    echo "Error: '$dir_to_add' is not a valid directory."
                fi
                return
                ;;
            -f)
                if [ -z "$next_arg" ]; then
                    echo "Error: Filter pattern required for -f."
                    return 1
                fi
                # Apply filter and enter interactive mode
                mapfile -t dirs < <(sort -u "$FAV_FILE" | grep -i -- "$next_arg")
                echo "Filter applied: \"$next_arg\""
                ;;
            -r)
                cwd=$(pwd)
                if grep -Fxq "$cwd" "$FAV_FILE"; then
                    sed -i "\|^${cwd}$|d" "$FAV_FILE"
                    echo "Removed: $cwd"
                else
                    echo "Current directory is not in favorites."
                fi
                return
                ;;
            -h)
                echo "Favorites Manager"
                echo "Usage: fav [option] [argument]"
                echo "Options:"
                echo "  -a [directory]  Add a directory to favorites (default: current directory)"
                echo "  -f <pattern>    Filter favorite directories by a pattern"
                echo "  -r              Remove current directory from favorites (if present)"
                echo "  -h              Show this help message"
                echo "Interactive mode (no arguments or -f):"
                echo "  [number]  Navigate to the directory with the given ID"
                echo "  [a]       Add current directory (if not already added)"
                echo "  [d]       Delete a favorite by ID"
                echo "  [q]       Quit"
                return
                ;;
            *)
                echo "Invalid option: $arg. Use -h for help."
                return 1
                ;;
        esac
    fi

    # Load favorites (sorted, no duplicates) if not already filtered
    if [ -z "${dirs+x}" ]; then
        mapfile -t dirs < <(sort -u "$FAV_FILE")
    fi

    # Show list
    echo
    echo "Favorites Manager"
    echo "========================"

    if [ ${#dirs[@]} -eq 0 ]; then
        echo "No favorites found."
    else
        printf "\n%-4s %s\n" "ID" "Directory"
        echo "--------------------------------------------"
        for i in "${!dirs[@]}"; do
            printf "%-4s %s\n" "$((i+1))" "${dirs[$i]}"
        done
    fi

    echo
    # Check if current directory is already in favorites
    cwd=$(pwd)
    if ! grep -Fxq "$cwd" "$FAV_FILE"; then
        echo "[a] Add current directory ($cwd)"
    fi
    echo "[d] Delete favorite"
    echo "[q] Quit"
    echo

    read -rp "Choice: " choice

    case "$choice" in
        # number → navigate
        [0-9]*)
            idx=$((choice-1))
            if [ $idx -ge 0 ] && [ $idx -lt ${#dirs[@]} ]; then
                cd "${dirs[$idx]}" || echo "Failed to enter ${dirs[$idx]}"
            else
                echo "Invalid index."
            fi
            ;;
        # add current directory
        a|A)
            cwd=$(pwd)
            if ! grep -Fxq "$cwd" "$FAV_FILE"; then
                echo "$cwd" >> "$FAV_FILE"
                echo "Added: $cwd"
            else
                echo "Current directory is already in favorites."
            fi
            ;;
        # delete (respecting current filter)
        d|D)
            read -rp "Number to remove: " idx
            idx=$((idx-1))
            if [ $idx -ge 0 ] && [ $idx -lt ${#dirs[@]} ]; then
                sed -i "\|^${dirs[$idx]}$|d" "$FAV_FILE"
                echo "Removed: ${dirs[$idx]}"
            else
                echo "Invalid index."
            fi
            ;;
        q|Q)
            echo "Exiting."
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}