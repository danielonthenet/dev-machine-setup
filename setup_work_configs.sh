#!/bin/bash
# Helper script to set up work configs from Google Drive
# Supports any custom-* directory pattern

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Auto-detect Google Drive location
if [[ -d "$HOME/Library/CloudStorage" ]]; then
    # Find GoogleDrive folder (works with any email)
    GOOGLE_DRIVE_ROOT=$(find "$HOME/Library/CloudStorage" -maxdepth 1 -name "GoogleDrive-*" -type d 2>/dev/null | head -1)
    if [[ -n "$GOOGLE_DRIVE_ROOT" ]]; then
        GOOGLE_DRIVE_PATH="$GOOGLE_DRIVE_ROOT/My Drive/Dev-Configs/Office-Mac-Setup"
    fi
fi

# Fallback to old path if new structure not found
if [[ -z "$GOOGLE_DRIVE_PATH" || ! -d "$GOOGLE_DRIVE_PATH" ]]; then
    GOOGLE_DRIVE_PATH="$HOME/Google Drive/Dev-Configs/Office-Mac-Setup"
fi

echo "🔍 Looking for work configs in Google Drive..."

if [[ ! -d "$GOOGLE_DRIVE_PATH" ]]; then
    echo "❌ Google Drive work configs not found"
    echo "💡 Please ensure Google Drive is synced first"
    echo "   Expected location: Dev-Configs/Office-Mac-Setup"
    exit 1
fi

echo "📦 Copying work configs from Google Drive..."

# Copy all custom-* directories
if compgen -G "$GOOGLE_DRIVE_PATH/custom-*" > /dev/null; then
    for custom_dir in "$GOOGLE_DRIVE_PATH"/custom-*/; do
        if [[ -d "$custom_dir" ]]; then
            dir_name=$(basename "$custom_dir")
            cp -r "$custom_dir" "$SCRIPT_DIR/"
            echo "✅ $dir_name/ directory copied"
        fi
    done
else
    echo "⚠️  No custom-* directories found in Google Drive"
fi

# Copy .zshrc.custom
if [[ -f "$GOOGLE_DRIVE_PATH/.zshrc.custom" ]]; then
    cp "$GOOGLE_DRIVE_PATH/.zshrc.custom" ~/.zshrc.custom
    echo "✅ .zshrc.custom copied to home directory"
fi

# Copy certificates
if [[ -d "$GOOGLE_DRIVE_PATH/certificates" ]]; then
    mkdir -p ~/certs
    cp "$GOOGLE_DRIVE_PATH/certificates"/* ~/certs/ 2>/dev/null || true
    echo "✅ Certificates copied"
fi

# Copy any custom-* files from common/
if compgen -G "$GOOGLE_DRIVE_PATH/custom-*.*" > /dev/null; then
    cp "$GOOGLE_DRIVE_PATH"/custom-*.* "$SCRIPT_DIR/common/" 2>/dev/null || true
    echo "✅ Custom override files copied"
fi

echo ""
echo "✅ Work configs restored!"
echo ""
echo "💡 Next steps:"
echo "   1. Run: ./setup_mac.sh"
echo "   2. Check for custom-* setup scripts:"
for custom_dir in "$SCRIPT_DIR"/custom-*/; do
    if [[ -d "$custom_dir" && -f "$custom_dir/setup_custom.sh" ]]; then
        echo "      Run: ./${custom_dir}setup_custom.sh"
    fi
done
