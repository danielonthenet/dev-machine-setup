# Claude Profile Swap Tool

A minimal command-line tool to switch Claude Code auth/backend state without clobbering the rest of your Claude setup.

## What It Switches

The tool only saves and restores:
- Profile-specific env from `~/.claude/settings.json`
- OAuth credentials
- Metadata about the saved profile

This is intentional. It avoids resetting shared Claude configuration such as:
- `extraKnownMarketplaces`
- `enabledPlugins`
- MCP servers
- hooks
- installed plugin/cache state under `~/.claude/plugins/`
- general user state in `~/.claude.json`

## Current Claude File Layout

On the current Claude Code setup, the useful source-of-truth locations are:
- `~/.claude/settings.json`
- `~/.claude.json`
- `~/.claude/plugins/`

The profile swap tool only changes the auth/backend portion of `~/.claude/settings.json` plus credentials. It does not replace `~/.claude.json` or the plugin directories.

## Features

- Save Claude auth/backend profiles
- List saved profiles
- Switch between profiles with minimal config churn
- Delete profiles
- Check current auth status
- Store profile data in `~/.claude-profiles/`

## Installation

The tool is automatically available if you have run the dev-machine-setup scripts. The functions are loaded through `~/.zshrc`.

To manually load the functions in a new shell session:

```bash
source /path/to/common/shared/claude-profile-swap.sh
```

## Usage

### Save Current Profile

Log into Claude Code with the account or backend setup you want to save, then run:

```bash
claude-save <profile-name>
```

Example:

```bash
claude-save work
claude-save personal
```

### List Profiles

```bash
claude-list
```

### Switch Profiles

```bash
claude-switch <profile-name>
```

Example:

```bash
claude-switch work
claude-switch personal
```

After switching, restart Claude Code for the change to take effect.

### Check Current Status

```bash
claude-status
```

### Delete a Profile

```bash
claude-delete <profile-name>
```

Example:

```bash
claude-delete old-account
```

## Direct Script Usage

You can also run the script directly:

```bash
/path/to/claude-profile-swap.sh save myprofile
/path/to/claude-profile-swap.sh list
/path/to/claude-profile-swap.sh switch myprofile
/path/to/claude-profile-swap.sh delete myprofile
/path/to/claude-profile-swap.sh status
```

## How It Works

### Storage Layout

Profiles live in `~/.claude-profiles/`:

```text
~/.claude-profiles/
├── work/
│   ├── settings.json      # minimal profile env snapshot
│   ├── credentials.json   # OAuth credentials when present
│   └── metadata.txt
├── personal/
│   ├── credentials.json
│   └── metadata.txt
└── .backup-20260412-145114/
    ├── settings.json
    └── credentials.json
```

### Platform Support

- macOS: OAuth credentials are stored in Keychain
- Linux/Windows: OAuth credentials are stored in `~/.claude/.credentials.json`

### What Gets Saved

Each profile may contain:
- `settings.json`: only the profile-specific env keys from `~/.claude/settings.json`
- `credentials.json`: OAuth credentials if present
- `metadata.txt`: identifier, save time, platform, and presence flags

### What Does Not Get Swapped

These stay shared across all profiles:
- `~/.claude.json`
- `~/.claude/plugins/`
- plugin marketplaces and installed plugin state
- non-profile keys in `~/.claude/settings.json`

That means commands like these should remain in place across profile switches:

```text
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins
/codex:setup
```

### Backward Compatibility

Older saved profiles may contain a full `settings.json` or legacy extra files such as `config.json`. The switcher now only applies the profile-specific env subset when restoring, so old profiles still work without overwriting shared plugin or settings state.

## Example Workflow

```bash
# Save a work Bedrock/backend profile
claude-save work

# Log in with a personal account and save it
claude-save personal

# Switch back to work later
claude-switch work

# Restart Claude Code
```

If you change your auth/backend setup later, re-run `claude-save <name>` to refresh that profile. You do not need to re-save just because you added a Claude plugin marketplace or enabled a plugin.

## Troubleshooting

### A plugin or marketplace disappeared after switching

That usually means the profile was saved by an older version of the script that overwrote the full `settings.json`. Re-save the profile once with the current script:

```bash
claude-save <profile-name>
```

### The wrong OAuth account is still active after switching

The current script clears OAuth credentials when switching to a profile that does not have them. If you still see stale auth, restart Claude Code and run:

```bash
claude-status
```

### Profiles do not work after switching

Check:
1. Claude Code was fully restarted after the switch.
2. The profile was saved while the intended account/backend was active.
3. Keychain access was allowed on macOS if OAuth is involved.

## Uninstall

To remove all saved profile data:

```bash
rm -rf ~/.claude-profiles
```

To remove the shell integration, edit `common/shared/aliases.sh` and remove the Claude Profile Management section.

## Technical Notes

- Written in Bash
- Uses Python 3 when available to merge JSON safely
- Keeps plugin and general Claude state shared on purpose
- Focuses on minimal switching: auth/backend env plus credentials
