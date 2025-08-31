# Terminal Favorites Manager

## Overview
The **Terminal Favorites Manager** (`fav`) is a lightweight Bash script that simplifies navigation and management of frequently used directories in the terminal. It provides both interactive and command-line interfaces to save, filter, navigate, and remove directory favorites. Your favorites are stored in `~/.fav_dirs` and persist across sessions.

## Quick Install

```bash
# Download and run the installer
curl -L -o install_fav.sh https://github.com/marceloxp/fav/releases/download/v1.0.0/install.sh
chmod +x install_fav.sh
./install_fav.sh
rm install_fav.sh

# Reload your shell configuration
source ~/.bashrc  # or source ~/.zshrc, or restart your shell

# Verify installation
fav -h
```

**What the installer does:**
- Downloads `fav.sh` from GitHub releases
- Verifies SHA-256 checksum for security
- Installs to `~/.local/bin/fav` (or `/usr/local/bin/fav` for root)
- Creates `~/.local/bin` directory if needed
- Adds `~/.local/bin` to your PATH in shell configuration
- Sources the script in your shell configuration

**Security Note**: The installer automatically verifies the SHA-256 checksum using the `SHA256SUMS` file from the release. For extra security, you can confirm the checksum on the [GitHub release page](https://github.com/marceloxp/fav/releases/tag/v1.0.0).

**SHA-256 for v1.0.0**: `3e735a441b21f346adbacf69f54c056728abe8cc022e3d43ace45c2eac1dcaf7`

If `fav` is not found after installation, ensure `~/.local/bin` is in your PATH:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Manual Installation

If you prefer manual installation:

```bash
# Download the script
curl -L -o ~/.local/bin/fav https://github.com/marceloxp/fav/releases/download/v1.0.0/fav.sh

# Make it executable
chmod +x ~/.local/bin/fav

# Add to your shell configuration
echo 'source ~/.local/bin/fav' >> ~/.bashrc  # or ~/.zshrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Reload your shell
source ~/.bashrc
```

## Testing in Docker

Test `fav` in an isolated Docker environment:

```bash
# Build the test image (uses minimal Alpine Linux)
docker build -f Dockerfile.test -t fav-test .

# Run with interactive shell
docker run -it --rm fav-test

# Test the fav command inside the container
fav -h
```

The test image is very lightweight (~5MB) and includes only essential dependencies.

## Usage

### Command-Line Options

```bash
# Add current directory to favorites
fav -a

# Add specific directory
fav -a /path/to/directory

# Filter favorites by pattern
fav -f project

# Remove current directory from favorites
fav -r

# Show help
fav -h
```

### Interactive Mode

Run `fav` without arguments to enter interactive mode:

```bash
fav
```

In interactive mode, you can:
- Type a number to navigate to that directory
- Press `a` to add current directory (if not already added)
- Press `d` to delete a favorite by ID
- Press `q` to quit

Example output:
```
Terminal Favorites Manager
==========================

ID   Directory
--------------------------------------------
1    /home/user/projects/website
2    /home/user/documents/work
3    /etc/apache2

[a] Add current directory (/tmp)
[d] Delete favorite
[q] Quit

Choice:
```

## Features

- **Add Directories**: Save current or specified directories to favorites
- **Filter Favorites**: Search favorites using case-insensitive patterns
- **Remove Directories**: Delete favorites from the list
- **Interactive Navigation**: Quickly jump to any favorite directory
- **Persistent Storage**: Favorites saved in `~/.fav_dirs` file
- **No Duplicates**: Prevents adding the same directory multiple times
- **Path Normalization**: Automatically removes trailing slashes
- **Alphabetical Sorting**: Favorites are always displayed in order

## Example Workflow

1. **Add directories to favorites**:
   ```bash
   cd /important/project
   fav -a
   cd /etc/nginx/sites-available
   fav -a
   ```

2. **List and navigate to favorites**:
   ```bash
   fav
   # Type '1' to go to /important/project
   # Type '2' to go to /etc/nginx/sites-available
   ```

3. **Filter favorites**:
   ```bash
   fav -f nginx
   # Shows only directories containing "nginx"
   ```

4. **Remove favorites**:
   ```bash
   fav -r  # Remove current directory
   # Or use interactive mode and press 'd'
   ```

## Integration with Docker

You can include `fav` in your Docker images. Here's the recommended method:

```dockerfile
# Install Terminal Favorites Manager with embedded checksum verification
RUN curl -L -o fav.sh https://github.com/marceloxp/fav/releases/download/v1.0.0/fav.sh \
    && echo "3e735a441b21f346adbacf69f54c056728abe8cc022e3d43ace45c2eac1dcaf7  fav.sh" | sha256sum -c \
    && mv fav.sh /usr/local/bin/fav \
    && chmod +x /usr/local/bin/fav
```

This approach:
- ✅ Verifies script integrity with embedded checksum
- ✅ Doesn't require external dependencies
- ✅ Keaks the image minimal and secure

## Troubleshooting

**Favorites not showing correctly?**
```bash
# Normalize the favorites file (remove trailing slashes)
sed -i 's/\/$//' ~/.fav_dirs
```

**Installation issues?**
- Check that `~/.local/bin` is in your PATH
- Verify the script is executable: `chmod +x ~/.local/bin/fav`
- Reload your shell configuration: `source ~/.bashrc`

**Debugging:**
```bash
# Run with tracing
bash -x $(which fav)

# Check the favorites file
cat ~/.fav_dirs

# Check if fav is in PATH
which fav
```

**Permission issues in Docker?**
Ensure the container user has write access to their home directory for the `~/.fav_dirs` file.

## Files Modified

The installer creates/modifies:
- `~/.local/bin/fav` (or `/usr/local/bin/fav` for root)
- `~/.local/bin` directory (if it doesn't exist)
- `~/.bashrc` and/or `~/.zshrc` (adds to PATH and sources the script)
- `~/.fav_dirs` (created when first adding a favorite)

## Notes

- Favorites are stored one per line in `~/.fav_dirs`
- You can manually edit this file if needed
- The script works with both Bash and Zsh
- Trailing slashes are automatically removed from paths
- The delete option (`d`) only appears when favorites exist

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Verify the SHA-256 checksum matches the release
3. Ensure your system has Bash and standard utilities

The script is designed to work on most Unix-like systems with minimal dependencies.

---

**Enjoy easier terminal navigation with `fav`!**