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
        # Read and normalize the favorites, ensuring root is properly handled
        mapfile -t dirs < <(cat "$FAV_FILE" | while read -r line; do
            if [ -z "$line" ]; then
                echo "/"
            else
                echo "$line" | sed 's/\/$//'
            fi
        done | sort)
        
        # Ensure the last line is included even without trailing newline
        if [ -s "$FAV_FILE" ] && [ -n "$(tail -c 1 "$FAV_FILE")" ]; then
            last_line=$(tail -n 1 "$FAV_FILE")
            if [ -z "$last_line" ]; then
                last_line="/"
            else
                last_line=$(echo "$last_line" | sed 's/\/$//')
            fi
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
            # Ensure root directory is displayed as "/" not empty
            if [ -z "${dirs[$i]}" ]; then
                printf "%-4s %s\n" "$((i+1))" "/"
            else
                printf "%-4s %s\n" "$((i+1))" "${dirs[$i]}"
            fi
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
    
    # Check if current directory is in favorites (handle root specially)
    in_favorites=0
    for fav_dir in "${dirs[@]}"; do
        if [ "$fav_dir" = "/" ] && [ "$current_dir" = "/" ]; then
            in_favorites=1
            break
        elif [ "$fav_dir" = "$current_dir" ]; then
            in_favorites=1
            break
        fi
    done
    
    if [ $in_favorites -eq 0 ]; then
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
                target_dir="${dirs[$idx]}"
                if [ -z "$target_dir" ]; then
                    target_dir="/"
                fi
                cd "$target_dir" || echo "Failed to enter $target_dir"
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
            
            # Check if already in favorites
            already_exists=0
            while IFS= read -r line; do
                normalized_line=$(echo "$line" | sed 's/\/$//')
                if [ -z "$normalized_line" ]; then
                    normalized_line="/"
                fi
                if [ "$normalized_line" = "$cwd" ]; then
                    already_exists=1
                    break
                fi
            done < "$FAV_FILE"
            
            if [ $already_exists -eq 0 ]; then
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
                    target_dir="${dirs[$idx]}"
                    if [ -z "$target_dir" ]; then
                        target_dir="/"
                    fi
                    
                    # Remove from file
                    escaped_dir=$(printf '%s\n' "$target_dir" | sed 's/[[\.*^$/]/\\&/g')
                    sed -i "\|^${escaped_dir}$|d" "$FAV_FILE"
                    
                    # Also remove empty lines that represent root
                    if [ "$target_dir" = "/" ]; then
                        sed -i '/^$/d' "$FAV_FILE"
                    fi
                    
                    echo "Removed: $target_dir"
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