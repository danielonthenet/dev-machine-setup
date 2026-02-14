#!/bin/bash
# MCP (Model Context Protocol) Servers Setup Script

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect_os.sh"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$HOME/.dotfiles-install.log"
}

log "🤖 Setting up MCP Servers..."

# Detect Claude Desktop config location based on OS
get_claude_config_dir() {
    case "$DOTFILES_OS" in
        "macos")
            echo "$HOME/Library/Application Support/Claude"
            ;;
        "linux"|"wsl")
            echo "$HOME/.config/Claude"
            ;;
        *)
            echo "Unsupported OS: $DOTFILES_OS" >&2
            return 1
            ;;
    esac
}

# Setup Puppeteer MCP Server
setup_puppeteer_mcp() {
    log "🎭 Setting up Puppeteer MCP Server..."
    
    # Check if npm is available
    if ! command -v npm &> /dev/null; then
        log "❌ npm not found. Please install Node.js first."
        return 1
    fi
    
    # Create MCP servers directory
    local mcp_servers_dir="$HOME/.mcp-servers"
    mkdir -p "$mcp_servers_dir"
    cd "$mcp_servers_dir"
    
    # Create puppeteer-mcp-claude directory
    local puppeteer_dir="$mcp_servers_dir/puppeteer-mcp-claude"
    
    if [[ -d "$puppeteer_dir" ]]; then
        log "📁 Puppeteer MCP server directory already exists, updating..."
        cd "$puppeteer_dir"
        npm update
    else
        log "📦 Creating Puppeteer MCP server..."
        npx @modelcontextprotocol/create-server puppeteer-mcp-claude
    fi
    
    log "✅ Puppeteer MCP server setup complete"
}

# Configure Claude Desktop
configure_claude_desktop() {
    log "⚙️  Configuring Claude Desktop..."
    
    local claude_config_dir=$(get_claude_config_dir)
    local claude_config_file="$claude_config_dir/claude_desktop_config.json"
    
    # Create Claude config directory if it doesn't exist
    mkdir -p "$claude_config_dir"
    
    # Determine the node path
    local node_path
    if command -v node &> /dev/null; then
        node_path=$(which node)
    else
        log "❌ Node.js not found in PATH"
        return 1
    fi
    
    # MCP server path
    local mcp_server_path="$HOME/.mcp-servers/puppeteer-mcp-claude/build/index.js"
    
    # Create or update Claude Desktop config
    if [[ -f "$claude_config_file" ]]; then
        log "📝 Updating existing Claude Desktop config..."
        # Backup existing config
        cp "$claude_config_file" "${claude_config_file}.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Check if puppeteer-mcp-claude already exists in config
        if grep -q "puppeteer-mcp-claude" "$claude_config_file"; then
            log "ℹ️  Puppeteer MCP server already configured in Claude Desktop"
        else
            log "➕ Adding Puppeteer MCP server to existing config..."
            # Use jq to add the new server (if jq is available)
            if command -v jq &> /dev/null; then
                local temp_file=$(mktemp)
                jq --arg node "$node_path" --arg server "$mcp_server_path" \
                   '.mcpServers["puppeteer-mcp-claude"] = {
                       "command": $node,
                       "args": [$server]
                   }' "$claude_config_file" > "$temp_file"
                mv "$temp_file" "$claude_config_file"
            else
                log "⚠️  jq not installed, please manually add the server to $claude_config_file"
                log "   Add this entry to the mcpServers section:"
                cat <<EOF
    "puppeteer-mcp-claude": {
      "command": "$node_path",
      "args": ["$mcp_server_path"]
    }
EOF
            fi
        fi
    else
        log "📄 Creating new Claude Desktop config..."
        cat > "$claude_config_file" <<EOF
{
  "mcpServers": {
    "puppeteer-mcp-claude": {
      "command": "$node_path",
      "args": ["$mcp_server_path"]
    }
  }
}
EOF
    fi
    
    log "✅ Claude Desktop configuration complete"
    log "📍 Config file: $claude_config_file"
}

# Main setup function
main() {
    echo "🚀 MCP Servers Setup"
    echo "===================="
    echo ""
    
    # Check if running interactively
    if [[ -t 0 ]]; then
        echo "This will set up MCP servers for Claude Desktop:"
        echo "  • Puppeteer MCP Server (browser automation)"
        echo ""
        read -p "Continue? [Y/n]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]?$ ]]; then
            echo "Setup cancelled."
            exit 0
        fi
    fi
    
    setup_puppeteer_mcp
    configure_claude_desktop
    
    echo ""
    echo "✅ MCP Servers setup complete!"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Restart Claude Desktop if it's running"
    echo "   2. The Puppeteer MCP server will be available in Claude"
    echo "   3. You can add more MCP servers by editing:"
    echo "      $(get_claude_config_dir)/claude_desktop_config.json"
    echo ""
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
