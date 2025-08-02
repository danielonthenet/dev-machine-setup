#!/bin/bash

# =============================================================================
# Setup Validation Script
# =============================================================================
# 
# This script validates that all setup scripts have correct syntax and can be
# executed. It's useful for testing changes and ensuring everything works.
#
# Usage: ./validate_setup.sh
#
# =============================================================================

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
test_script() {
    local script_path="$1"
    local test_name="$2"
    
    echo -n "Testing $test_name... "
    
    if [[ ! -f "$script_path" ]]; then
        echo -e "${RED}FAIL${NC} (file not found)"
        ((TESTS_FAILED++))
        return 1
    fi
    
    # Check if file is executable
    if [[ ! -x "$script_path" ]]; then
        echo -e "${YELLOW}WARN${NC} (not executable, fixing...)"
        chmod +x "$script_path"
    fi
    
    # Check syntax
    if bash -n "$script_path" 2>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC} (syntax error)"
        # Show syntax error
        echo -e "${RED}Syntax error in $script_path:${NC}"
        bash -n "$script_path"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test PowerShell syntax
test_powershell() {
    local script_path="$1"
    local test_name="$2"
    
    echo -n "Testing $test_name... "
    
    if [[ ! -f "$script_path" ]]; then
        echo -e "${RED}FAIL${NC} (file not found)"
        ((TESTS_FAILED++))
        return 1
    fi
    
    # Check if PowerShell is available for syntax checking
    if command -v pwsh >/dev/null 2>&1; then
        if pwsh -NoProfile -Command "try { \$null = [System.Management.Automation.PSParser]::Tokenize((Get-Content '$script_path' -Raw), [ref]\$null); Write-Output 'OK' } catch { exit 1 }" >/dev/null 2>&1; then
            echo -e "${GREEN}PASS${NC}"
            ((TESTS_PASSED++))
            return 0
        else
            echo -e "${RED}FAIL${NC} (syntax error)"
            ((TESTS_FAILED++))
            return 1
        fi
    else
        echo -e "${YELLOW}SKIP${NC} (PowerShell not available)"
        return 0
    fi
}

# Test shared library loading
test_library() {
    local script_path="$1"
    local test_name="$2"
    
    echo -n "Testing $test_name... "
    
    if [[ ! -f "$script_path" ]]; then
        echo -e "${RED}FAIL${NC} (file not found)"
        ((TESTS_FAILED++))
        return 1
    fi
    
    # Test if library can be sourced
    if bash -c "source '$script_path'" 2>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC} (cannot source)"
        ((TESTS_FAILED++))
        return 1
    fi
}

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    Development Machine Setup - Validation     ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

echo -e "${YELLOW}🔍 Validating Platform Setup Scripts${NC}"
echo "----------------------------------------"

# Test main platform setup scripts
test_script "$SCRIPT_DIR/setup_mac.sh" "macOS Setup Script"
test_script "$SCRIPT_DIR/setup_linux.sh" "Linux Setup Script"
test_powershell "$SCRIPT_DIR/setup_windows.ps1" "Windows Setup Script"

echo ""
echo -e "${YELLOW}🔍 Validating Shared Libraries${NC}"
echo "----------------------------------------"

# Test shared libraries
test_library "$SCRIPT_DIR/common/setup_dotfiles.sh" "Shared Dotfiles Library"
test_script "$SCRIPT_DIR/common/setup_dev_env.sh" "Development Environment Setup"
test_script "$SCRIPT_DIR/common/detect_os.sh" "OS Detection"
test_script "$SCRIPT_DIR/common/validate_version_managers.sh" "Version Manager Validation"

echo ""
echo -e "${YELLOW}🔍 Validating Platform-Specific Scripts${NC}"
echo "----------------------------------------"

# Test platform-specific scripts
test_script "$SCRIPT_DIR/macos/setup_macos.sh" "macOS Platform Script"
test_script "$SCRIPT_DIR/linux/setup_linux.sh" "Linux Platform Script"
test_powershell "$SCRIPT_DIR/windows/setup_windows.ps1" "Windows Platform Script"

echo ""
echo -e "${YELLOW}🔍 Validating Shared Configuration${NC}"
echo "----------------------------------------"

# Test shared configuration scripts
test_script "$SCRIPT_DIR/common/shared/aliases.sh" "Shared Aliases"
test_script "$SCRIPT_DIR/common/shared/functions.sh" "Shared Functions"
test_script "$SCRIPT_DIR/common/shared/exports.sh" "Shared Exports"
test_script "$SCRIPT_DIR/common/shared/lazy_load.sh" "Lazy Loading"

echo ""
echo -e "${YELLOW}🔍 Validating Package Definitions${NC}"
echo "----------------------------------------"

# Test package definition scripts
test_script "$SCRIPT_DIR/macos/packages.sh" "macOS Packages"
test_script "$SCRIPT_DIR/linux/packages.sh" "Linux Packages"
test_powershell "$SCRIPT_DIR/windows/packages.ps1" "Windows Packages"

echo ""
echo -e "${YELLOW}🔍 Validating Utility Scripts${NC}"
echo "----------------------------------------"

# Test utility scripts
test_script "$SCRIPT_DIR/validate_installation.sh" "Installation Validation Script"

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}                 Test Results                  ${NC}"
echo -e "${BLUE}================================================${NC}"

echo ""
if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ All tests passed! ($TESTS_PASSED/$((TESTS_PASSED + TESTS_FAILED)))${NC}"
    echo -e "${GREEN}🚀 Setup scripts are ready for deployment${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed! ($TESTS_PASSED passed, $TESTS_FAILED failed)${NC}"
    echo -e "${RED}🔧 Please fix the issues above before deploying${NC}"
    exit 1
fi
