#!/bin/bash

FAV_FILE="$HOME/.fav_dirs"

fav() {
    [ ! -f "$FAV_FILE" ] && touch "$FAV_FILE"

    # Normalize the favorites file by removing trailing slashes, except for root
    sed -i 's/\/$//' "$FAV_FILE"
    # Handle special case for root directory - ensure it's represented as "/"
    sed -i 's/^$/\//' "$FAV_FILE"

    local arg="${1:-}"
    local next_arg="${2:-}"
    local filtered=0

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
                # Normalize directory by removing trailing slash, except for root
                if [ "$dir_to_add" = "/" ]; then
                    dir_to_add="/"
                else
                    dir_to_add=$(echo "$dir_to_add" | sed 's/\/$//')
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
                # Apply filter, normalize paths, and sort alphabetically
                # Handle root directory specially
                mapfile -t dirs < <(cat "$FAV_FILE" | sed 's/^$/\//' | sed 's/\/$//' | grep -i -- "$next_arg" | sort)
                echo "Filter applied: \"$next_arg\""
                filtered=1
                ;;
            -r)
                cwd=$(pwd)
                # Handle root directory specially
                if [ "$cwd" = "/" ]; then
                    cwd="/"
                else
                    cwd=$(echo "$cwd" | sed 's/\/$//')
                fi
                if grep -Fxq "$cwd" "$FAV_FILE"; then
                    sed -i "\|^${cwd}$|d" "$FAV_FILE"
                    echo "Removed: $cwd"
                else
                    echo "Current directory is not in favorites."
                fi
                return
                ;;
            -h)
                echo "Terminal Favorites Manager"
                echo "Usage: fav [option] [argument]"
                echo "Options:"
                echo "  -a [directory]  Add a directory to favorites (default: current directory)"
                echo "  -f <pattern>    Filter favorite directories by a pattern"
                echo "  -r              Remove current directory from favorites (if present)"
                echo "  -h              Show this help message"
                echo "Interactive mode (no arguments or -f):"
                echo "  [number]  Navigate to the directory with the given ID"
                echo "  [a]       Add current directory (if not already added)"
                echo "  [d]       Delete a favorite by ID (available if favorites exist)"
                echo "  [q]       Quit"
                return
                ;;
            *)
                echo "Invalid option: $arg. Use -h for help."
                return 1
                ;;
        esac
    fi

    # Load favorites only if not filtered, normalizing paths and sorting alphabetically
    if [ $filtered -eq 0 ]; then
        mapfile -t dirs < <(cat "$FAV_FILE" | sed 's/^$/\//' | sed 's/\/$//' | sort)
        # Ensure the last line is included even without trailing newline
        if [ -s "$FAV_FILE" ] && [ -n "$(tail -n 1 "$FAV_FILE")" ]; then
            last_line=$(tail -n 1 "$FAV_FILE" | sed 's/^$/\//' | sed 's/\/$//')
            if ! printf '%s\n' "${dirs[@]}" | grep -Fxq "$last_line"; then
                dirs+=("$last_line")
                # Re-sort the array to maintain alphabetical order
                mapfile -t dirs < <(printf '%s\n' "${dirs[@]}" | sort)
            fi
        fi
    fi

    # Show list
    echo
    echo "Terminal Favorites Manager"
    echo "=========================="

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
    # Show options conditionally
    current_dir=$(pwd)
    if [ "$current_dir" = "/" ]; then
        current_dir="/"
    else
        current_dir=$(echo "$current_dir" | sed 's/\/$//')
    fi
    
    if ! grep -Fxq "$current_dir" "$FAV_FILE"; then
        echo "[a] Add current directory ($current_dir)"
    fi
    if [ ${#dirs[@]} -gt 0 ]; then
        echo "[d] Delete favorite"
    fi
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
            if [ "$cwd" = "/" ]; then
                cwd="/"
            else
                cwd=$(echo "$cwd" | sed 's/\/$//')
            fi
            if ! grep -Fxq "$cwd" "$FAV_FILE"; then
                echo "$cwd" >> "$FAV_FILE"
                echo "Added: $cwd"
            else
                echo "Current directory is already in favorites."
            fi
            ;;
        # delete (respecting current filter)
        d|D)
            if [ ${#dirs[@]} -eq 0 ]; then
                echo "No favorites to delete."
            else
                read -rp "Number to remove: " idx
                idx=$((idx-1))
                if [ $idx -ge 0 ] && [ $idx -lt ${#dirs[@]} ]; then
                    # Escape special characters in the directory path for sed
                    escaped_dir=$(printf '%s\n' "${dirs[$idx]}" | sed 's/[[\.*^$/]/\\&/g')
                    # Debug: Show what we are trying to remove
                    # echo "Debug: Attempting to remove: ${dirs[$idx]}" >&2
                    if grep -Fx "${dirs[$idx]}" "$FAV_FILE"; then
                        sed -i "\|^${escaped_dir}$|d" "$FAV_FILE"
                        echo "Removed: ${dirs[$idx]}"
                    else
                        echo "Error: Directory not found in favorites: ${dirs[$idx]}"
                    fi
                else
                    echo "Invalid index."
                fi
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