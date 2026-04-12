#!/bin/bash
# Helper script to set up work configs from Google Drive
# Supports any custom-* directory pattern

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_ENV_TMP=""

cleanup_current_env_tmp() {
    if [[ -n "$CURRENT_ENV_TMP" && -f "$CURRENT_ENV_TMP" ]]; then
        rm -f "$CURRENT_ENV_TMP"
    fi
}

trap cleanup_current_env_tmp EXIT INT TERM

# Locate Google Drive for Desktop mount (supports any Google account email)
GOOGLE_DRIVE_ROOT=$(find "$HOME/Library/CloudStorage" -maxdepth 1 -name "GoogleDrive-*" -type d 2>/dev/null | head -1)
GOOGLE_DRIVE_PATH="${GOOGLE_DRIVE_ROOT:+$GOOGLE_DRIVE_ROOT/My Drive/Dev-Configs/Office-Mac-Setup}"

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

# Set up project .env files by prompting for all values.
# Google Drive holds a <project>.env.template (keys + non-secret defaults, secrets blank)
# and a <project>.env.target (destination path, e.g. $HOME/path/to/project/.env).
# Secrets are never stored in Google Drive — always prompted interactively.
#
# To add a new project:
#   1. Create Dev-Configs/Office-Mac-Setup/project-envs/<project>.env.template
#   2. Create Dev-Configs/Office-Mac-Setup/project-envs/<project>.env.target
PROJECT_ENVS_DIR="$GOOGLE_DRIVE_PATH/project-envs"
if [[ -d "$PROJECT_ENVS_DIR" ]]; then
    for template_file in "$PROJECT_ENVS_DIR"/*.env.template; do
        [[ -f "$template_file" ]] || continue
        project=$(basename "$template_file" .env.template)
        target_file="$PROJECT_ENVS_DIR/$project.env.target"

        if [[ ! -f "$target_file" ]]; then
            echo "⚠️  No .target file for $project — skipping"
            continue
        fi

        dest=$(eval echo "$(cat "$target_file")")
        echo ""
        echo "🔑 Setting up .env for: $project → $dest"
        mkdir -p "$(dirname "$dest")"
        # Write to a secure temp file in the destination directory so the
        # existing .env is preserved until all prompts complete successfully.
        dest_tmp=$(mktemp "${dest}.tmp.XXXXXX")
        chmod 600 "$dest_tmp"
        CURRENT_ENV_TMP="$dest_tmp"
        _env_aborted=false

        while IFS= read -r line; do
            if [[ -z "$line" || "$line" =~ ^# ]]; then
                echo "$line" >> "$dest_tmp"
                continue
            fi
            key="${line%%=*}"
            default="${line#*=}"
            if [[ -z "$default" ]]; then
                if ! IFS= read -r -s -p "  $key (hidden): " value < /dev/tty; then
                    printf '\n' >&2
                    echo "⚠️  Aborted — preserving existing .env" >&2
                    _env_aborted=true
                    break
                fi
                printf '\n' >&2
            else
                if ! IFS= read -r -p "  $key [$default]: " value < /dev/tty; then
                    printf '\n' >&2
                    echo "⚠️  Aborted — preserving existing .env" >&2
                    _env_aborted=true
                    break
                fi
                value="${value:-$default}"
            fi
            echo "$key=$value" >> "$dest_tmp"
        done < "$template_file"

        if [[ "$_env_aborted" == true ]]; then
            cleanup_current_env_tmp
            CURRENT_ENV_TMP=""
            continue
        fi
        mv "$dest_tmp" "$dest"
        chmod 600 "$dest"
        CURRENT_ENV_TMP=""
        echo "✅ $project .env written to $dest"
    done
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
