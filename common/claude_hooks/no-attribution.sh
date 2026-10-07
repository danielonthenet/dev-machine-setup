#!/bin/bash
# PreToolUse(Bash) guard: block git commit / gh pr commands that carry AI
# attribution, so the rule holds even if the model ignores the instructions.
# Scans the command text plus any message/body file it names (-F, --body-file).
# Human `Co-authored-by:` trailers are allowed.
cmd=$(jq -r '.tool_input.command // empty')
[[ "$cmd" =~ git.*commit || "$cmd" =~ gh.*pr.*(create|edit) ]] || exit 0

text="$cmd"
for f in $(echo "$cmd" | grep -oE '(--body-file|--file|-F)[ =]+[^ ]+' | sed -E 's/^[^ =]+[ =]+//'); do
    f="${f//[\"\']/}"; f="${f/#\~/$HOME}"
    [[ -f "$f" ]] && text+=$'\n'"$(cat "$f")"
done

if echo "$text" | grep -qiE 'co-authored-by:[^<]*(claude|codex|copilot|gemini|cursor|anthropic|openai)[^<]*<[^>]*(noreply|anthropic|openai|copilot)|generated with|noreply@anthropic'; then
    echo "Blocked: remove AI attribution (AI Co-Authored-By trailer / 'Generated with') from the commit or PR text. See ~/.claude/CLAUDE.md." >&2
    exit 2
fi
