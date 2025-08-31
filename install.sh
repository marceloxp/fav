#!/bin/bash

# Terminal Favorites Manager Installer
# Downloads fav.sh and SHA256SUMS from GitHub release, verifies SHA-256 checksum, and installs to /usr/local/bin or ~/.local/bin
# Usage: ./install_fav.sh

# Exit on error and show error messages
set -e
trap 'echo "Error: Installation failed at line $LINENO"; exit 1' ERR

# Configuration
VERSION="1.0.0"
GITHUB_REPO="marceloxp/fav"
FAV_URL="https://github.com/marceloxp/fav/releases/download/v${VERSION}/fav.sh"
CHECKSUM_URL="https://github.com/marceloxp/fav/releases/download/v${VERSION}/SHA256SUMS"
INSTALL_DIR_ROOT="/usr/local/bin"
INSTALL_DIR_USER="${HOME}/.local/bin"

echo "Installing Terminal Favorites Manager v${VERSION}..."

# Temp files
TEMP_DIR=$(mktemp -d)
echo "Creating temporary directory: ${TEMP_DIR}"
FAV_FILE="${TEMP_DIR}/fav.sh"
CHECKSUM_FILE="${TEMP_DIR}/SHA256SUMS"

# Download fav.sh
echo "Downloading fav.sh from ${FAV_URL}..."
if ! curl -sS -L -o "${FAV_FILE}" "${FAV_URL}"; then
    echo "Error: Failed to download fav.sh from ${FAV_URL}"
    rm -rf "${TEMP_DIR}"
    exit 1
fi

# Download SHA256SUMS
echo "Downloading SHA256SUMS from ${CHECKSUM_URL}..."
if ! curl -sS -L -o "${CHECKSUM_FILE}" "${CHECKSUM_URL}"; then
    echo "Error: Failed to download SHA256SUMS from ${CHECKSUM_URL}"
    rm -rf "${TEMP_DIR}"
    exit 1
fi

# Extract expected checksum from SHA256SUMS
EXPECTED_SHA256=$(grep "fav.sh" "${CHECKSUM_FILE}" | cut -d' ' -f1)
if [ -z "${EXPECTED_SHA256}" ]; then
    echo "Error: Could not find SHA-256 checksum for fav.sh in SHA256SUMS"
    rm -rf "${TEMP_DIR}"
    exit 1
fi

# Validate checksum format (64 chars for SHA-256)
if ! echo "${EXPECTED_SHA256}" | grep -Eq '^[0-9a-fA-F]{64}$'; then
    echo "Error: Invalid SHA-256 checksum format in SHA256SUMS. Must be 64 hexadecimal characters."
    rm -rf "${TEMP_DIR}"
    exit 1
fi

# Verify checksum
echo "Verifying SHA-256 checksum..."
computed_sha256=$(sha256sum "${FAV_FILE}" | cut -d' ' -f1)
if [ "${computed_sha256}" != "${EXPECTED_SHA256}" ]; then
    echo "Error: Checksum mismatch! Expected: ${EXPECTED_SHA256}, Got: ${computed_sha256}"
    echo "Download may be corrupted. Aborting."
    rm -rf "${TEMP_DIR}"
    exit 1
fi
echo "Checksum verified OK!"

# Determine install location
if [ "$EUID" -eq 0 ]; then
    INSTALL_DIR="${INSTALL_DIR_ROOT}"
else
    INSTALL_DIR="${INSTALL_DIR_USER}"
    # Ensure dir exists
    if [ ! -d "${INSTALL_DIR}" ]; then
        echo "Creating directory: ${INSTALL_DIR}"
        mkdir -p "${INSTALL_DIR}"
    fi
fi

# Install
echo "Installing fav to ${INSTALL_DIR}/fav..."
mv "${FAV_FILE}" "${INSTALL_DIR}/fav"
echo "Setting executable permissions on ${INSTALL_DIR}/fav..."
chmod +x "${INSTALL_DIR}/fav"

# Add to PATH if not already present (in ~/.bashrc or ~/.zshrc)
PROFILE_FILES=("${HOME}/.bashrc" "${HOME}/.zshrc")
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "${PROFILE}" ] && ! grep -q "PATH.*\.local/bin" "${PROFILE}"; then
        echo "Adding ~/.local/bin to PATH in ${PROFILE}..."
        echo "# Add ~/.local/bin to PATH for Terminal Favorites Manager" >> "${PROFILE}"
        echo 'if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then' >> "${PROFILE}"
        echo '    PATH="$HOME/.local/bin:$PATH"' >> "${PROFILE}"
        echo 'fi' >> "${PROFILE}"
        echo 'export PATH' >> "${PROFILE}"
        echo "Added PATH configuration to ${PROFILE}."
    fi
done

# Add sourcing if not already there
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "${PROFILE}" ] && ! grep -q "source.*fav" "${PROFILE}"; then
        echo "Adding sourcing of ${INSTALL_DIR}/fav to ${PROFILE}..."
        echo "# Terminal Favorites Manager" >> "${PROFILE}"
        echo "source ${INSTALL_DIR}/fav" >> "${PROFILE}"
        echo "Added sourcing to ${PROFILE}. Run 'source ${PROFILE}' or restart shell."
    fi
done

# Cleanup
echo "Cleaning up temporary directory: ${TEMP_DIR}"
rm -rf "${TEMP_DIR}"

echo "Installation complete! Run 'source ~/.bashrc' (or ~/.zshrc) and then 'fav -h' to get started."
echo "If 'fav' is still not found, manually add ${INSTALL_DIR} to your PATH: export PATH=\"${INSTALL_DIR}:\$PATH\""