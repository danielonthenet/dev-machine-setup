#!/bin/bash
# Version Manager Validation Script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory and source detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect_os.sh"

echo -e "${BLUE}🔍 Validating Version Manager Setup${NC}"
echo "=================================="

# Track validation results
validation_passed=true

load_sdkman_if_available() {
    export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"

    if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
        # shellcheck disable=SC1090
        source "$SDKMAN_DIR/bin/sdkman-init.sh"
        return 0
    fi

    return 1
}

sdkman_loaded=false
if load_sdkman_if_available && command -v sdk >/dev/null 2>&1; then
    sdkman_loaded=true
fi

# Function to check if a command exists
check_command() {
    local cmd="$1"
    local name="$2"
    local required="$3"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name is installed"
        return 0
    else
        if [[ "$required" == "true" ]]; then
            echo -e "${RED}✗${NC} $name is not installed (required)"
            validation_passed=false
        else
            echo -e "${YELLOW}⚠${NC} $name is not installed (optional)"
        fi
        return 1
    fi
}

# Function to check version manager and show current version
check_version_manager() {
    local manager="$1"
    local language="$2"
    local version_cmd="$3"
    
    echo ""
    echo -e "${BLUE}$language Version Manager ($manager):${NC}"
    
    if check_command "$manager" "$manager" "false"; then
        # Get current version
        local current_version
        case "$manager" in
            "rbenv")
                current_version=$(rbenv version 2>/dev/null | cut -d' ' -f1)
                echo "  Current Ruby version: $current_version"
                ;;
            "pyenv")
                current_version=$(pyenv version 2>/dev/null | cut -d' ' -f1)
                echo "  Current Python version: $current_version"
                ;;
            "g")
                current_version=$(g --version 2>/dev/null || echo "unknown")
                echo "  Go version manager: $current_version"
                if command -v go >/dev/null 2>&1; then
                    echo "  Current Go version: $(go version | cut -d' ' -f3 | sed 's/go//')"
                fi
                ;;
            "nvm")
                if [[ -n "$NVM_DIR" && -s "$NVM_DIR/nvm.sh" ]]; then
                    source "$NVM_DIR/nvm.sh"
                    current_version=$(nvm current 2>/dev/null || echo "none")
                    echo "  Current Node.js version: $current_version"
                else
                    echo "  NVM not properly initialized"
                fi
                ;;
            "tfswitch")
                if command -v terraform >/dev/null 2>&1; then
                    current_version=$(terraform version -json 2>/dev/null | jq -r '.terraform_version' 2>/dev/null || terraform version | head -1 | cut -d' ' -f2)
                    echo "  Current Terraform version: $current_version"
                else
                    echo "  No Terraform version installed"
                fi
                ;;
            "sdk")
                if command -v java >/dev/null 2>&1; then
                    current_version=$(java -version 2>&1 | head -n1)
                    echo "  Current Java version: $current_version"
                else
                    echo "  No Java version installed"
                fi
                ;;
        esac
    fi
}

# Check PATH additions
echo ""
echo -e "${BLUE}PATH Configuration:${NC}"
echo "Current PATH includes:"

check_path_entry() {
    local path_entry="$1"
    local description="$2"
    
    if [[ ":$PATH:" == *":$path_entry:"* ]]; then
        echo -e "  ${GREEN}✓${NC} $path_entry ($description)"
    else
        echo -e "  ${RED}✗${NC} $path_entry ($description) - missing from PATH"
        validation_passed=false
    fi
}

check_path_entry "$HOME/.rbenv/bin" "rbenv"
check_path_entry "$HOME/.pyenv/bin" "pyenv"
check_path_entry "$HOME/.goenv/bin" "goenv"
check_path_entry "$HOME/go/bin" "Go binaries"
if command -v sdk &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} SDKMAN! (sdk available)"
elif [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    echo -e "  ${RED}✗${NC} SDKMAN! init script exists but could not be loaded"
    validation_passed=false
else
    echo -e "  ${RED}✗${NC} SDKMAN! init script not found"
    validation_passed=false
fi

# Check version managers
check_version_manager "rbenv" "Ruby" "ruby -v"
check_version_manager "pyenv" "Python" "python --version"
check_version_manager "goenv" "Go" "go version"
check_version_manager "sdk" "Java" "java -version 2>&1 | head -n1"
check_version_manager "nvm" "Node.js" "node --version"
check_version_manager "tfswitch" "Terraform" "terraform version"

# Check environment variables
echo ""
echo -e "${BLUE}Environment Variables:${NC}"

check_env_var() {
    local var_name="$1"
    local description="$2"
    
    if [[ -n "${!var_name}" ]]; then
        echo -e "  ${GREEN}✓${NC} $var_name: ${!var_name}"
    else
        echo -e "  ${YELLOW}⚠${NC} $var_name: not set ($description)"
    fi
}

check_env_var "PYENV_ROOT" "Python environment root"
check_env_var "GOENV_ROOT" "Go environment root"
check_env_var "GOPATH" "Go workspace"
check_env_var "NVM_DIR" "Node Version Manager directory"
check_env_var "SDKMAN_DIR" "SDKMAN! directory"

# Test version manager initialization
echo ""
echo -e "${BLUE}Version Manager Initialization:${NC}"

# Test rbenv
if command -v rbenv >/dev/null 2>&1; then
    if rbenv versions >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} rbenv is properly initialized"
    else
        echo -e "  ${RED}✗${NC} rbenv is not properly initialized"
        validation_passed=false
    fi
fi

# Test pyenv
if command -v pyenv >/dev/null 2>&1; then
    if pyenv versions >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} pyenv is properly initialized"
    else
        echo -e "  ${RED}✗${NC} pyenv is not properly initialized"
        validation_passed=false
    fi
fi

# Test nvm
if [[ -d "$NVM_DIR" ]]; then
    if command -v nvm >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} nvm is properly initialized"
    else
        echo -e "  ${YELLOW}⚠${NC} nvm directory exists but command not available (may need shell restart)"
    fi
fi

# Summary
echo ""
echo "=================================="
if [[ "$validation_passed" == "true" ]]; then
    echo -e "${GREEN}✅ All critical checks passed!${NC}"
    echo ""
    echo "🎉 Your version managers are properly configured!"
    echo ""
    echo "📋 Available commands:"
    echo "  • ruby-install <version>    - Install Ruby version"
    echo "  • python-install <version>  - Install Python version" 
    echo "  • go-install <version>      - Install Go version"
    echo "  • node-install <version>    - Install Node.js version"
    echo "  • terraform-install <ver>   - Install Terraform version"
    echo "  • show-versions             - Show all current versions"
    echo "  • update-version-managers   - Update all version managers"
else
    echo -e "${RED}❌ Some validation checks failed!${NC}"
    echo ""
    echo "🔧 To fix issues:"
    echo "  1. Restart your shell: exec zsh"
    echo "  2. Re-run the setup: ./common/setup_dev_env.sh"
    echo "  3. Check your shell configuration"
    echo ""
    echo "💡 If problems persist, try:"
    echo "  • Manually source version managers in ~/.zshrc"
    echo "  • Check file permissions on version manager directories"
    echo "  • Verify PATH settings in ~/.zshrc"
fi

echo ""
echo "🔄 To re-run this validation: ./common/validate_version_managers.sh"
