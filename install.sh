#!/bin/bash

# Terminal Favorites Manager Installer
# Downloads fav.sh from GitHub release, verifies SHA-256 checksum (provided as argument), and installs to /usr/local/bin or ~/.local/bin
# Usage: curl -sS https://github.com/marceloxp/fav/releases/download/v1.0.0/install.sh | bash -s <sha256_checksum>

set -e  # Exit on error

# Configuration
VERSION="1.0.0"  # Change this to your release version
GITHUB_REPO="marceloxp/fav"
FAV_URL="https://github.com/marceloxp/fav/releases/download/v${VERSION}/fav.sh"
CHECKSUM_URL="https://github.com/marceloxp/fav/releases/download/v${VERSION}/SHA256SUMS"
INSTALL_DIR_ROOT="/usr/local/bin"
INSTALL_DIR_USER="${HOME}/.local/bin"

# Check if checksum was provided
if [ -z "$1" ]; then
    echo "Error: SHA-256 checksum required as argument."
    echo "Usage: $0 <sha256_checksum>"
    echo "Get the checksum from https://github.com/${GITHUB_REPO}/releases/tag/v${VERSION} or the SHA256SUMS file."
    exit 1
fi
EXPECTED_SHA256="$1"

# Validate checksum format (64 chars for SHA-256)
if ! echo "${EXPECTED_SHA256}" | grep -Eq '^[0-9a-fA-F]{64}$'; then
    echo "Error: Invalid SHA-256 checksum format. Must be 64 hexadecimal characters."
    exit 1
fi

# Temp files
TEMP_DIR=$(mktemp -d)
FAV_FILE="${TEMP_DIR}/fav.sh"
CHECKSUM_FILE="${TEMP_DIR}/SHA256SUMS"

echo "Installing Terminal Favorites Manager v${VERSION}..."

# Download fav.sh
echo "Downloading fav.sh..."
curl -sS -L -o "${FAV_FILE}" "${FAV_URL}"

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

# Optional: Download and check SHA256SUMS file for additional validation
echo "Downloading SHA256SUMS for additional verification..."
curl -sS -L -o "${CHECKSUM_FILE}" "${CHECKSUM_URL}"
if grep -q "${EXPECTED_SHA256}  fav.sh" "${CHECKSUM_FILE}"; then
    echo "SHA256SUMS file verification OK!"
else
    echo "Warning: SHA256SUMS file does not match provided checksum. Proceeding with provided checksum."
fi

# Determine install location
if [ "$EUID" -eq 0 ]; then
    INSTALL_DIR="${INSTALL_DIR_ROOT}"
else
    INSTALL_DIR="${INSTALL_DIR_USER}"
    # Ensure dir exists
    mkdir -p "${INSTALL_DIR}"
fi

# Install
echo "Installing to ${INSTALL_DIR}..."
mv "${FAV_FILE}" "${INSTALL_DIR}/fav"
chmod +x "${INSTALL_DIR}/fav"

# Add to shell profile if not already there
PROFILE_FILES=("${HOME}/.bashrc" "${HOME}/.zshrc")
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "${PROFILE}" ] && ! grep -q "source.*fav" "${PROFILE}"; then
        echo "# Terminal Favorites Manager" >> "${PROFILE}"
        echo "source ${INSTALL_DIR}/fav" >> "${PROFILE}"
        echo "Added sourcing to ${PROFILE}. Run 'source ${PROFILE}' or restart shell."
    fi
done

# Cleanup
rm -rf "${TEMP_DIR}"

echo "Installation complete! Run 'fav -h' to get started."
echo "If 'fav' is not found, add ${INSTALL_DIR} to your PATH or restart your shell."