#!/bin/bash
# System Maintenance and Health Check Script

echo "🔧 Running System Maintenance..."

# Check system health
check_system_health() {
    echo "📊 System Health Check:"
    
    # Check disk space
    echo "💾 Disk Usage:"
    df -h | grep -E "/$|/System/Volumes/Data" | awk '{print "  " $5 " used on " $9}'
    
    # Check memory usage
    echo "🧠 Memory Usage:"
    memory_pressure=$(memory_pressure | grep "System-wide memory free percentage" | awk '{print $5}' | sed 's/%//')
    if [[ $memory_pressure -gt 20 ]]; then
        echo "  ✅ Memory: ${memory_pressure}% free"
    else
        echo "  ⚠️  Memory: ${memory_pressure}% free (Low)"
    fi
    
    # Check CPU temperature (if available)
    if command -v istats >/dev/null 2>&1; then
        echo "🌡️ System Temperature:"
        istats cpu temp
    fi
    
    # Check for software updates
    echo "🔄 Software Updates:"
    softwareupdate -l 2>/dev/null | grep -q "No new software available" && echo "  ✅ System up to date" || echo "  ⚠️  Updates available"
    
    # Check Homebrew
    if command -v brew >/dev/null 2>&1; then
        echo "🍺 Homebrew Status:"
        outdated=$(brew outdated --quiet | wc -l | tr -d ' ')
        if [[ $outdated -eq 0 ]]; then
            echo "  ✅ All packages up to date"
        else
            echo "  ⚠️  $outdated packages need updating"
        fi
    fi
}

# Clean temporary files
clean_temp_files() {
    echo "🗑️ Cleaning temporary files..."
    
    # Clean system temp
    sudo rm -rf /tmp/*
    
    # Clean user temp
    rm -rf ~/Library/Caches/com.apple.Safari/WebKitCache/*
    rm -rf ~/Library/Caches/Google/Chrome/Default/Cache/*
    rm -rf ~/Library/Caches/Firefox/Profiles/*/cache2/*
    
    # Clean Downloads folder of old files (older than 30 days)
    find ~/Downloads -type f -mtime +30 -delete 2>/dev/null
    
    # Clean trash
    rm -rf ~/.Trash/*
    
    echo "  ✅ Temporary files cleaned"
}

# Update all packages
update_packages() {
    echo "📦 Updating packages..."
    
    # Update macOS
    echo "🍎 Checking for macOS updates..."
    sudo softwareupdate -i -a --restart
    
    # Update Homebrew
    if command -v brew >/dev/null 2>&1; then
        echo "🍺 Updating Homebrew packages..."
        brew update && brew upgrade && brew cleanup
        brew doctor
    fi
    
    # Update npm packages
    if command -v npm >/dev/null 2>&1; then
        echo "📦 Updating global npm packages..."
        npm update -g
    fi
    
    # Update Python packages
    if command -v pip3 >/dev/null 2>&1; then
        echo "🐍 Updating Python packages..."
        pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install -U
    fi
    
    # Update Ruby gems
    if command -v gem >/dev/null 2>&1; then
        echo "💎 Updating Ruby gems..."
        gem update
    fi
}

# Optimize system performance
optimize_system() {
    echo "⚡ Optimizing system performance..."
    
    # Rebuild LaunchServices database
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
    
    # Flush DNS cache
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
    
    # Reset font cache
    sudo atsutil databases -remove
    
    # Repair disk permissions (if needed)
    echo "🔧 Checking disk permissions..."
    sudo diskutil verifyVolume /
    
    echo "  ✅ System optimization complete"
}

# Main execution
case "${1:-all}" in
    "health")
        check_system_health
        ;;
    "clean")
        clean_temp_files
        ;;
    "update")
        update_packages
        ;;
    "optimize")
        optimize_system
        ;;
    "all")
        check_system_health
        echo ""
        clean_temp_files
        echo ""
        optimize_system
        ;;
    *)
        echo "Usage: $0 {health|clean|update|optimize|all}"
        echo "  health   - Check system health"
        echo "  clean    - Clean temporary files"
        echo "  update   - Update all packages"
        echo "  optimize - Optimize system performance"
        echo "  all      - Run health check, clean, and optimize"
        ;;
esac
