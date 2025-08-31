# Terminal Favorites Manager

## Overview
The **Terminal Favorites Manager** is a Bash script that simplifies navigation and management of favorite directories in the terminal. It allows users to save, filter, navigate, and remove directories efficiently using a command-line interface (CLI) with both interactive and non-interactive modes.

The script stores favorite directories in a file (`~/.fav_dirs`) and provides commands to add, remove, filter, and navigate to these directories. It is designed to be lightweight, user-friendly, and integrated into your shell environment (e.g., `~/.bashrc` or `~/.zshrc`).

## Installation
1. Copy the `fav.sh` script to a suitable location, e.g., `~/.local/bin/fav.sh`.
2. Make it executable:
   ```bash
   chmod +x ~/.local/bin/fav.sh
   ```
3. Source the script in your shell configuration file (e.g., `~/.bashrc` or `~/.zshrc`):
   ```bash
   source ~/.local/bin/fav.sh
   ```
4. Reload your shell configuration:
   ```bash
   source ~/.bashrc
   ```

## Usage
The `fav` command supports both non-interactive (with options) and interactive modes.

### Non-Interactive Mode
Run `fav` with the following options:

- `-a [directory]`: Add a directory to favorites. If no directory is specified, the current directory is added (if not already in the list).
  ```bash
  fav -a /path/to/dir  # Add /path/to/dir
  fav -a              # Add current directory
  ```
- `-f <pattern>`: Filter favorite directories by a pattern (case-insensitive) and enter interactive mode.
  ```bash
  fav -f project  # Show directories containing "project"
  ```
- `-r`: Remove the current directory from favorites (if present).
  ```bash
  fav -r  # Remove current directory
  ```
- `-h`: Display the help message with available options and usage.
  ```bash
  fav -h
  ```

### Interactive Mode
Run `fav` without arguments or with `-f <pattern>` to enter interactive mode:
```bash
fav          # List all favorites
fav -f proj  # List favorites filtered by "proj"
```

In interactive mode, you can:
- Enter a number (e.g., `1`) to navigate to the corresponding directory.
- Press `a` to add the current directory (only shown if not already in favorites).
- Press `d` to delete a favorite by its ID.
- Press `q` to quit.

### Features
- **Add Directories**: Add the current directory or a specified directory to favorites, with duplicate prevention.
- **Filter Favorites**: Filter the list of favorites using a case-insensitive pattern.
- **Remove Directories**: Remove the current directory or a specific favorite by ID.
- **Navigate Easily**: Jump to a favorite directory by selecting its ID in interactive mode.
- **Persistent Storage**: Favorites are stored in `~/.fav_dirs` and persist across sessions.
- **No Duplicates**: The script ensures directories are not added multiple times.
- **Sorted List**: Favorites are displayed in a sorted, duplicate-free list.

## Example Workflow
1. Add the current directory to favorites:
   ```bash
   fav -a
   ```
2. Filter favorites containing "work":
   ```bash
   fav -f work
   ```
3. In interactive mode, type `1` to navigate to the first directory in the filtered list.
4. Remove the current directory:
   ```bash
   fav -r
   ```
5. View help:
   ```bash
   fav -h
   ```

## Notes
- The favorites file (`~/.fav_dirs`) is created automatically if it doesn't exist.
- Invalid directories or options result in clear error messages.
- The script is compatible with Bash and Zsh shells.
