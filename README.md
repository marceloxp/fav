# Terminal Favorites Manager

## Overview
The **Terminal Favorites Manager** is a Bash script designed to streamline navigation and management of favorite directories in the terminal. It allows users to save, filter, navigate, and remove directories efficiently through a command-line interface (CLI) with both interactive and non-interactive modes. The script stores favorite directories in `~/.fav_dirs`, ensuring persistence across sessions, and provides a user-friendly way to manage them.

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
   or
   ```bash
   source ~/.zshrc
   ```

## Usage
The `fav` command supports both non-interactive (with options) and interactive modes.

### Non-Interactive Mode
Run `fav` with the following options:

- `-a [directory]`: Add a directory to favorites. If no directory is specified, the current directory is added (if not already in the list). Trailing slashes are automatically removed.
  ```bash
  fav -a /path/to/dir  # Add /path/to/dir
  fav -a              # Add current directory
  ```
- `-f <pattern>`: Filter favorite directories by a case-insensitive pattern and enter interactive mode.
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
- Press `d` to delete a favorite by its ID (only shown if there are favorites to delete).
- Press `q` to quit.

### Features
- **Add Directories**: Add the current or a specified directory to favorites, with automatic duplicate prevention.
- **Filter Favorites**: Filter favorites using a case-insensitive pattern, displaying only matching directories.
- **Remove Directories**: Remove the current directory or a specific favorite by ID.
- **Navigate Easily**: Jump to a favorite directory by selecting its ID in interactive mode.
- **Persistent Storage**: Favorites are stored in `~/.fav_dirs` and persist across sessions.
- **Path Normalization**: Trailing slashes are automatically removed from directory paths to ensure consistency.
- **Alphabetical Sorting**: Favorites are displayed in alphabetical order.
- **No Duplicates**: The script prevents adding duplicate directories.
- **Conditional Delete Option**: The `[d]` option in interactive mode is only shown when there are favorites to delete.

## Example Workflow
1. Add the current directory to favorites:
   ```bash
   fav -a
   ```
   Output: `Added: /path/to/current/dir`
2. Filter favorites containing "apache":
   ```bash
   fav -f apache
   ```
   Output:
   ```
   Filter applied: "apache"

   Terminal Favorites Manager
   ==========================

   ID   Directory
   --------------------------------------------
   1    /etc/apache2/sites-available
   2    /etc/apache2/sites-enabled

   [a] Add current directory (/path/to/current/dir)
   [d] Delete favorite
   [q] Quit

   Choice:
   ```
3. Navigate to a directory by entering `1` in interactive mode.
4. Remove the current directory:
   ```bash
   fav -r
   ```
   Output: `Removed: /path/to/current/dir`
5. Delete a favorite in interactive mode:
   ```bash
   fav
   ```
   Choose `d`, then enter `2` to remove `/etc/apache2/sites-enabled`.
6. View help:
   ```bash
   fav -h
   ```

## Notes
- The favorites file (`~/.fav_dirs`) is created automatically if it doesn't exist.
- Invalid directories or options result in clear error messages.
- The script normalizes directory paths by removing trailing slashes to prevent inconsistencies.
- The `[d]` delete option is only displayed in interactive mode when there are favorites to delete.
- The script is compatible with Bash and Zsh shells.
- Favorites are stored in `~/.fav_dirs` as plain text, one directory per line, and can be edited manually if needed (ensure no trailing slashes).

## Troubleshooting
- **Favorites not listed correctly**: Ensure `~/.fav_dirs` is properly formatted (one directory per line, no trailing slashes). Run `sed -i 's/\/$//' ~/.fav_dirs` to normalize it.
- **Removal not working**: Check `~/.fav_dirs` for trailing slashes or special characters using `cat -e ~/.fav_dirs`.
- **Debugging**: Run `bash -x fav` to trace script execution and identify issues.