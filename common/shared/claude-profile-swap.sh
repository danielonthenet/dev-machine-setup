#!/usr/bin/env bash
# Claude Profile Swap - Minimal tool to switch between Claude accounts
# Stores profile auth/backend state in ~/.claude-profiles/
# Compatible with both bash and zsh

# Detect whether this file is being sourced or executed directly.
# $# cannot be used for this: when sourced from .zshrc the caller's
# positional parameters are visible, so $# > 0 is possible even though
# no CLI arguments were passed to the script itself.
_CLAUDE_PROFILE_SWAP_SOURCED=false
if [[ -n "${ZSH_VERSION:-}" && "$ZSH_EVAL_CONTEXT" == *":file"* ]]; then
    _CLAUDE_PROFILE_SWAP_SOURCED=true
elif [[ -n "${BASH_VERSION:-}" && "${BASH_SOURCE[0]:-}" != "${0}" ]]; then
    _CLAUDE_PROFILE_SWAP_SOURCED=true
fi

# Don't use strict mode when sourced - it can affect the parent shell
if [[ "$_CLAUDE_PROFILE_SWAP_SOURCED" == false ]]; then
    set -euo pipefail
fi

PROFILES_DIR="$HOME/.claude-profiles"
CLAUDE_DIR="$HOME/.claude"
CLAUDE_SETTINGS_FILE="$CLAUDE_DIR/settings.json"
CLAUDE_CREDENTIALS_FILE="$CLAUDE_DIR/.credentials.json"
CLAUDE_USER_STATE_FILE="$HOME/.claude.json"
KEYCHAIN_SERVICE="Claude Code-credentials"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Detect platform
detect_platform() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *MINGW*|*MSYS*|*CYGWIN*) echo "windows" ;;
        *) echo "unknown" ;;
    esac
}

PLATFORM=$(detect_platform)

have_python3() {
    command -v python3 >/dev/null 2>&1
}

# Return success when settings.json contains profile-specific auth/backend env.
# Keep this intentionally narrow so shared settings such as plugins, MCP,
# hooks, and other user preferences stay untouched when switching.
settings_has_profile_data() {
    local settings_file="${1:-$CLAUDE_SETTINGS_FILE}"

    [[ -f "$settings_file" ]] || return 1

    if ! have_python3; then
        return 0
    fi

    python3 - "$settings_file" <<'PY'
import json
import sys

path = sys.argv[1]

def managed(key: str) -> bool:
    return (
        key.startswith("ANTHROPIC_")
        or key.startswith("OTEL_")
        or "BEDROCK" in key
        or key in {
            "AWS_BEARER_TOKEN_BEDROCK",
            "CLAUDE_CODE_USE_BEDROCK",
            "CLAUDE_CODE_SKIP_BEDROCK_AUTH",
            "CLAUDE_CODE_ENABLE_TELEMETRY",
        }
    )

try:
    with open(path, "r", encoding="utf-8") as handle:
        data = json.load(handle)
except Exception:
    raise SystemExit(0)

env = data.get("env", {})
if not isinstance(env, dict):
    env = {}

raise SystemExit(0 if any(managed(str(key)) for key in env) else 1)
PY
}

# Save only the profile-specific env subset from settings.json.
write_profile_settings_snapshot() {
    local source_file="$1"
    local destination_file="$2"

    rm -f "$destination_file"

    [[ -f "$source_file" ]] || return 0

    if ! have_python3; then
        cp "$source_file" "$destination_file"
        chmod 600 "$destination_file"
        return 0
    fi

    if ! python3 - "$source_file" "$destination_file" <<'PY'
import json
import os
import sys

source_path, destination_path = sys.argv[1], sys.argv[2]

def managed(key: str) -> bool:
    return (
        key.startswith("ANTHROPIC_")
        or key.startswith("OTEL_")
        or "BEDROCK" in key
        or key in {
            "AWS_BEARER_TOKEN_BEDROCK",
            "CLAUDE_CODE_USE_BEDROCK",
            "CLAUDE_CODE_SKIP_BEDROCK_AUTH",
            "CLAUDE_CODE_ENABLE_TELEMETRY",
        }
    )

with open(source_path, "r", encoding="utf-8") as handle:
    data = json.load(handle)

env = data.get("env", {})
if not isinstance(env, dict):
    env = {}

snapshot_env = {
    key: value
    for key, value in env.items()
    if managed(str(key))
}

if not snapshot_env:
    if os.path.exists(destination_path):
        os.remove(destination_path)
    raise SystemExit(0)

parent = os.path.dirname(destination_path)
if parent:
    os.makedirs(parent, exist_ok=True)

with open(destination_path, "w", encoding="utf-8") as handle:
    json.dump({"env": snapshot_env}, handle, indent=2, sort_keys=True)
    handle.write("\n")
PY
    then
        cp "$source_file" "$destination_file"
    fi

    if [[ -f "$destination_file" ]]; then
        chmod 600 "$destination_file"
    fi
}

# Merge a saved profile snapshot into the current settings file, only changing
# profile-specific env keys and leaving the rest of settings.json alone.
apply_profile_settings_snapshot() {
    local source_file="$1"
    local destination_file="${2:-$CLAUDE_SETTINGS_FILE}"

    if ! have_python3; then
        if [[ -f "$source_file" ]]; then
            cp "$source_file" "$destination_file"
            chmod 600 "$destination_file"
        else
            rm -f "$destination_file"
        fi
        return 0
    fi

    if ! python3 - "$source_file" "$destination_file" <<'PY'
import json
import os
import sys

source_path, destination_path = sys.argv[1], sys.argv[2]

def managed(key: str) -> bool:
    return (
        key.startswith("ANTHROPIC_")
        or key.startswith("OTEL_")
        or "BEDROCK" in key
        or key in {
            "AWS_BEARER_TOKEN_BEDROCK",
            "CLAUDE_CODE_USE_BEDROCK",
            "CLAUDE_CODE_SKIP_BEDROCK_AUTH",
            "CLAUDE_CODE_ENABLE_TELEMETRY",
        }
    )

def load_json(path: str) -> dict:
    if not path or not os.path.exists(path):
        return {}
    with open(path, "r", encoding="utf-8") as handle:
        data = json.load(handle)
    return data if isinstance(data, dict) else {}

target = load_json(destination_path)
source = load_json(source_path)

target_env = target.get("env", {})
if not isinstance(target_env, dict):
    target_env = {}

source_env = source.get("env", {})
if not isinstance(source_env, dict):
    source_env = {}

for key in list(target_env):
    if managed(str(key)):
        target_env.pop(key, None)

for key, value in source_env.items():
    if managed(str(key)):
        target_env[key] = value

if target_env:
    target["env"] = target_env
else:
    target.pop("env", None)

if target:
    parent = os.path.dirname(destination_path)
    if parent:
        os.makedirs(parent, exist_ok=True)
    with open(destination_path, "w", encoding="utf-8") as handle:
        json.dump(target, handle, indent=2, sort_keys=True)
        handle.write("\n")
else:
    if os.path.exists(destination_path):
        os.remove(destination_path)
PY
    then
        if [[ -f "$source_file" ]]; then
            cp "$source_file" "$destination_file"
        else
            rm -f "$destination_file"
        fi
    fi

    if [[ -f "$destination_file" ]]; then
        chmod 600 "$destination_file"
    fi
}

get_settings_identifier_for_file() {
    local settings_file="${1:-$CLAUDE_SETTINGS_FILE}"

    [[ -f "$settings_file" ]] || return 0

    if ! have_python3; then
        if grep -q "BEDROCK" "$settings_file" 2>/dev/null; then
            echo "Bedrock (custom)"
        fi
        return 0
    fi

    python3 - "$settings_file" <<'PY'
import json
import sys

path = sys.argv[1]

try:
    with open(path, "r", encoding="utf-8") as handle:
        data = json.load(handle)
except Exception:
    print("Custom Claude settings")
    raise SystemExit(0)

env = data.get("env", {})
if not isinstance(env, dict):
    env = {}

bedrock_url = env.get("ANTHROPIC_BEDROCK_BASE_URL", "")
has_bedrock = (
    bool(bedrock_url)
    or any("BEDROCK" in str(key) for key in env)
    or env.get("CLAUDE_CODE_USE_BEDROCK") == "1"
)

if has_bedrock:
    print(f"Bedrock: {bedrock_url}" if bedrock_url else "Bedrock (custom)")
elif env:
    print("Custom Claude settings")
PY
}

# Get profile identifier - what to show to identify this auth setup
get_profile_identifier() {
    local identifier="unknown"

    local settings_identifier
    settings_identifier=$(get_settings_identifier_for_file "$CLAUDE_SETTINGS_FILE")
    if [[ -n "$settings_identifier" ]]; then
        identifier="$settings_identifier"
    fi

    local credentials
    credentials=$(read_credentials)
    if [[ -n "$credentials" ]]; then
        if [[ "$identifier" == "unknown" ]]; then
            identifier="Anthropic OAuth"
        else
            identifier="$identifier + OAuth"
        fi
    fi

    echo "$identifier"
}

# Read credentials from keychain (macOS) or file (Linux/Windows)
read_credentials() {
    if [[ "$PLATFORM" == "macos" ]]; then
        security find-generic-password -s "$KEYCHAIN_SERVICE" -w 2>/dev/null || echo ""
    else
        if [[ -f "$CLAUDE_CREDENTIALS_FILE" ]]; then
            cat "$CLAUDE_CREDENTIALS_FILE"
        else
            echo ""
        fi
    fi
}

# Write credentials to keychain (macOS) or file (Linux/Windows)
write_credentials() {
    local credentials="$1"
    if [[ "$PLATFORM" == "macos" ]]; then
        security add-generic-password -U -s "$KEYCHAIN_SERVICE" -a "$USER" -w "$credentials" 2>/dev/null
    else
        mkdir -p "$CLAUDE_DIR"
        echo "$credentials" > "$CLAUDE_CREDENTIALS_FILE"
        chmod 600 "$CLAUDE_CREDENTIALS_FILE"
    fi
}

delete_credentials() {
    if [[ "$PLATFORM" == "macos" ]]; then
        security delete-generic-password -s "$KEYCHAIN_SERVICE" -a "$USER" >/dev/null 2>&1 || true
    else
        rm -f "$CLAUDE_CREDENTIALS_FILE"
    fi
}

# Save current profile
claude_save_profile() {
    local profile_name="$1"

    if [[ -z "$profile_name" ]]; then
        echo -e "${RED}Error: Profile name required${NC}"
        echo "Usage: claude-save <name>"
        return 1
    fi

    # Validate profile name
    if [[ ! "$profile_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo -e "${RED}Error: Profile name can only contain letters, numbers, hyphens, and underscores${NC}"
        return 1
    fi

    if [[ ! -f "$CLAUDE_SETTINGS_FILE" ]]; then
        echo -e "${YELLOW}Warning: $CLAUDE_SETTINGS_FILE not found${NC}"
        echo "This is normal for standard Anthropic accounts that only use OAuth credentials."
    fi

    local identifier
    identifier=$(get_profile_identifier)

    local credentials
    credentials=$(read_credentials)

    local has_profile_settings="no"
    if settings_has_profile_data "$CLAUDE_SETTINGS_FILE"; then
        has_profile_settings="yes"
    fi

    if [[ "$has_profile_settings" == "no" ]] && [[ -z "$credentials" ]]; then
        echo -e "${RED}Error: No authentication found${NC}"
        echo "No profile-specific settings in $CLAUDE_SETTINGS_FILE and no OAuth credentials."
        echo "Make sure you're logged into Claude Code first."
        return 1
    fi

    # Create profiles directory
    mkdir -p "$PROFILES_DIR"
    chmod 700 "$PROFILES_DIR"

    local profile_dir="$PROFILES_DIR/$profile_name"

    # Check if profile already exists
    if [[ -d "$profile_dir" ]]; then
        echo -e "${YELLOW}Profile '$profile_name' already exists. Overwrite? (y/N)${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Cancelled."
            return 0
        fi
    fi

    mkdir -p "$profile_dir"
    chmod 700 "$profile_dir"

    # Remove old saved auth artifacts before writing the new snapshot.
    rm -f "$profile_dir/settings.json" "$profile_dir/credentials.json" "$profile_dir/metadata.txt"

    write_profile_settings_snapshot "$CLAUDE_SETTINGS_FILE" "$profile_dir/settings.json"
    if [[ -f "$profile_dir/settings.json" ]]; then
        has_profile_settings="yes"
        echo -e "${GREEN}  ✓ Saved profile settings from settings.json${NC}"
    else
        has_profile_settings="no"
    fi

    local has_credentials="no"
    if [[ -n "$credentials" ]]; then
        echo "$credentials" > "$profile_dir/credentials.json"
        chmod 600 "$profile_dir/credentials.json"
        has_credentials="yes"
        echo -e "${GREEN}  ✓ Saved OAuth credentials${NC}"
    fi

    # Save metadata
    cat > "$profile_dir/metadata.txt" <<EOF
identifier: $identifier
saved: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
platform: $PLATFORM
has_settings: $has_profile_settings
has_credentials: $has_credentials
EOF
    chmod 600 "$profile_dir/metadata.txt"

    echo -e "${GREEN}✓ Saved profile '$profile_name'${NC}"
    echo -e "${BLUE}  Stored in: $profile_dir${NC}"
}

# List all profiles
claude_list_profiles() {
    if [[ ! -d "$PROFILES_DIR" ]]; then
        echo -e "${YELLOW}No profiles found. Use 'claude-save <name>' to create one.${NC}"
        return 0
    fi

    local current_identifier
    current_identifier=$(get_profile_identifier)

    echo -e "${BLUE}Available Claude profiles:${NC}"
    echo ""

    local count=0
    for profile_dir in "$PROFILES_DIR"/*; do
        if [[ -d "$profile_dir" ]]; then
            local profile_name
            profile_name=$(basename "$profile_dir")
            local identifier="unknown"
            local saved="unknown"

            if [[ -f "$profile_dir/metadata.txt" ]]; then
                identifier=$(grep "^identifier:" "$profile_dir/metadata.txt" | cut -d' ' -f2- || echo "unknown")
                saved=$(grep "^saved:" "$profile_dir/metadata.txt" | cut -d' ' -f2- || echo "unknown")
            fi

            local marker=""
            if [[ "$identifier" == "$current_identifier" && "$current_identifier" != "unknown" ]]; then
                marker=" ${GREEN}[ACTIVE]${NC}"
            fi

            echo -e "  ${GREEN}$profile_name${NC}$marker"
            echo -e "    Saved: $saved"
            echo ""

            ((count++))
        fi
    done

    if [[ $count -eq 0 ]]; then
        echo -e "${YELLOW}No profiles found. Use 'claude-save <name>' to create one.${NC}"
    fi
}

# Switch to a profile
claude_switch_to() {
    local profile_name="$1"

    if [[ -z "$profile_name" ]]; then
        echo -e "${RED}Error: Profile name required${NC}"
        echo "Usage: claude-switch <name>"
        echo ""
        echo "Available profiles:"
        claude_list_profiles
        return 1
    fi

    local profile_dir="$PROFILES_DIR/$profile_name"

    if [[ ! -d "$profile_dir" ]]; then
        echo -e "${RED}Error: Profile '$profile_name' not found${NC}"
        echo ""
        echo "Available profiles:"
        claude_list_profiles
        return 1
    fi

    # Check if profile has any auth data
    if [[ ! -f "$profile_dir/settings.json" ]] && [[ ! -f "$profile_dir/credentials.json" ]]; then
        echo -e "${RED}Error: Profile '$profile_name' has no authentication data${NC}"
        return 1
    fi

    mkdir -p "$CLAUDE_DIR"

    local current_credentials
    current_credentials=$(read_credentials)

    local had_profile_settings="no"
    if settings_has_profile_data "$CLAUDE_SETTINGS_FILE"; then
        had_profile_settings="yes"
    fi

    # Backup current auth before switching
    local backup_dir="$PROFILES_DIR/.backup-$(date +%Y%m%d-%H%M%S)"
    local backed_up_anything="no"
    mkdir -p "$backup_dir"
    chmod 700 "$backup_dir"

    write_profile_settings_snapshot "$CLAUDE_SETTINGS_FILE" "$backup_dir/settings.json"
    if [[ -f "$backup_dir/settings.json" ]]; then
        backed_up_anything="yes"
        echo -e "${BLUE}  Backed up profile settings${NC}"
    fi

    if [[ -n "$current_credentials" ]]; then
        echo "$current_credentials" > "$backup_dir/credentials.json"
        chmod 600 "$backup_dir/credentials.json"
        backed_up_anything="yes"
        echo -e "${BLUE}  Backed up credentials${NC}"
    fi

    if [[ "$backed_up_anything" == "yes" ]]; then
        echo -e "${BLUE}Backup saved to: $backup_dir${NC}"
        echo ""
    else
        rmdir "$backup_dir" 2>/dev/null || true
    fi

    apply_profile_settings_snapshot "$profile_dir/settings.json" "$CLAUDE_SETTINGS_FILE"
    if [[ -f "$profile_dir/settings.json" ]]; then
        echo -e "${GREEN}  ✓ Restored profile settings${NC}"
    elif [[ "$had_profile_settings" == "yes" ]]; then
        echo -e "${GREEN}  ✓ Cleared profile-specific settings${NC}"
    fi

    if [[ -f "$profile_dir/credentials.json" ]]; then
        local credentials
        credentials=$(cat "$profile_dir/credentials.json")
        write_credentials "$credentials"
        echo -e "${GREEN}  ✓ Restored OAuth credentials${NC}"
    elif [[ -n "$current_credentials" ]]; then
        delete_credentials
        echo -e "${GREEN}  ✓ Cleared OAuth credentials${NC}"
    fi

    echo ""
    echo -e "${GREEN}✓ Switched to profile '$profile_name'${NC}"
    echo -e "${YELLOW}⚠  Restart Claude Code for changes to take effect${NC}"
}

# Delete a profile
claude_delete_profile() {
    local profile_name="$1"

    if [[ -z "$profile_name" ]]; then
        echo -e "${RED}Error: Profile name required${NC}"
        echo "Usage: claude-delete <name>"
        return 1
    fi

    local profile_dir="$PROFILES_DIR/$profile_name"

    if [[ ! -d "$profile_dir" ]]; then
        echo -e "${RED}Error: Profile '$profile_name' not found${NC}"
        return 1
    fi

    echo -e "${YELLOW}Delete profile '$profile_name'? This cannot be undone. (y/N)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        return 0
    fi

    rm -rf "$profile_dir"
    echo -e "${GREEN}✓ Deleted profile '$profile_name'${NC}"
}

# Show current active profile
claude_show_status() {
    local identifier
    identifier=$(get_profile_identifier)

    local settings_identifier
    settings_identifier=$(get_settings_identifier_for_file "$CLAUDE_SETTINGS_FILE")

    local credentials
    credentials=$(read_credentials)
    local has_credentials="no"
    if [[ -n "$credentials" ]]; then
        has_credentials="yes"
    fi

    echo -e "${BLUE}Current Claude Authentication Status:${NC}"
    echo -e "  Platform: $PLATFORM"
    echo ""

    if [[ -n "$settings_identifier" ]]; then
        echo -e "  ${GREEN}✓ $settings_identifier${NC}"
        echo -e "    Settings: $CLAUDE_SETTINGS_FILE"
    elif [[ -f "$CLAUDE_SETTINGS_FILE" ]]; then
        echo -e "  ${BLUE}• Shared Claude settings present${NC}"
        echo -e "    Settings: $CLAUDE_SETTINGS_FILE"
    fi

    if [[ "$has_credentials" == "yes" ]]; then
        echo -e "  ${GREEN}✓ Anthropic OAuth credentials${NC}"
        if [[ "$PLATFORM" == "macos" ]]; then
            echo -e "    Storage: macOS Keychain"
        else
            echo -e "    Storage: $CLAUDE_CREDENTIALS_FILE"
        fi
    fi

    if [[ -f "$CLAUDE_USER_STATE_FILE" ]]; then
        echo -e "  ${BLUE}• Shared Claude user state present${NC}"
        echo -e "    State: $CLAUDE_USER_STATE_FILE"
    fi

    if [[ "$identifier" == "unknown" ]]; then
        echo -e "  ${RED}✗ No authentication found${NC}"
        echo -e "    Make sure you're logged into Claude Code."
    fi
}

# Functions are automatically available when sourced (no export needed in zsh)
# In bash, export if being sourced; in zsh, functions are auto-available
if [[ -n "${BASH_VERSION:-}" ]] && [[ "${BASH_SOURCE[0]:-}" != "${0}" ]]; then
    export -f claude_save_profile  2>/dev/null || true
    export -f claude_list_profiles 2>/dev/null || true
    export -f claude_switch_to 2>/dev/null || true
    export -f claude_delete_profile 2>/dev/null || true
    export -f claude_show_status 2>/dev/null || true
fi

# Only provide CLI path when executed directly (not sourced).
if [[ "$_CLAUDE_PROFILE_SWAP_SOURCED" == false ]]; then
    case "${1:-}" in
        save)
            claude_save_profile "${2:-}"
            ;;
        list)
            claude_list_profiles
            ;;
        switch)
            claude_switch_to "${2:-}"
            ;;
        delete)
            claude_delete_profile "${2:-}"
            ;;
        status)
            claude_show_status
            ;;
        *)
            echo "Claude Profile Swap - Manage multiple Claude Code accounts"
            echo ""
            echo "Usage:"
            echo "  $0 save <name>      Save current profile"
            echo "  $0 list             List all profiles"
            echo "  $0 switch <name>    Switch to a profile"
            echo "  $0 delete <name>    Delete a profile"
            echo "  $0 status           Show current status"
            exit 1
            ;;
    esac
fi
