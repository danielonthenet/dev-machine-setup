#!/usr/bin/env python3
"""Summarise Claude Code sessions from ~/.claude/projects/*/*.jsonl as markdown.

usage: claude_sessions_summary.py [--since YYYY-MM-DD] [--until YYYY-MM-DD] [--project SUBSTR] [--all]
Per session: date, project dir, AI title, first prompt, prompt count, files edited, lines +/-, git commits.
Days get a totals header. Sessions with <3 tool calls are hidden unless --all.
"""
import argparse, collections, glob, json, os, re

p = argparse.ArgumentParser()
p.add_argument("--since", default="0000")
p.add_argument("--until", default="9999")
p.add_argument("--project", default="")
p.add_argument("--all", action="store_true", help="include trivial sessions")
a = p.parse_args()

EDIT_TOOLS = {"Edit", "Write", "NotebookEdit"}


def text_of(content):
    if isinstance(content, str):
        return content
    return " ".join(b.get("text", "") for b in content if isinstance(b, dict) and b.get("type") == "text")


def summarise(path):
    s = dict(title=None, first=None, prompts=0, start=None, cwd=None, edits=set(), add=0, rem=0, commits=[], tools=collections.Counter())
    for line in open(path, errors="replace"):
        try:
            d = json.loads(line)
        except ValueError:
            continue
        t = d.get("type")
        if t == "ai-title":
            s["title"] = d.get("aiTitle") or d.get("title") or s["title"]
        if d.get("isSidechain"):
            continue
        s["start"] = s["start"] or d.get("timestamp")
        s["cwd"] = s["cwd"] or d.get("cwd")
        msg = d.get("message") or {}
        if t == "user" and (d.get("origin") or {}).get("kind", "human") == "human":
            txt = text_of(msg.get("content", "")).strip()
            if txt and not txt.startswith(("<", "Caveat")):
                s["prompts"] += 1
                s["first"] = s["first"] or txt
        elif t == "assistant" and isinstance(msg.get("content"), list):
            for b in msg["content"]:
                if b.get("type") != "tool_use":
                    continue
                s["tools"][b["name"]] += 1
                inp = b.get("input", {})
                if b["name"] in EDIT_TOOLS:
                    s["edits"].add(inp.get("file_path") or inp.get("notebook_path") or "?")
                    # ponytail: counts new/old text lines, not a real diff; fine for a summary
                    s["add"] += len((inp.get("new_string") or inp.get("content") or inp.get("new_source") or "").splitlines())
                    s["rem"] += len((inp.get("old_string") or "").splitlines())
                elif b["name"] == "Bash":
                    m = re.search(r"git commit.*?-m\s+(?:\"([^\"]+)|'([^']+))", inp.get("command", ""), re.S)
                    if m:
                        s["commits"].append((m.group(1) or m.group(2)).splitlines()[0])
    return s


rows = []
for f in glob.glob(os.path.expanduser("~/.claude/projects/*/*.jsonl")):
    s = summarise(f)
    if not s["start"] or not (a.since <= s["start"][:10] <= a.until) or a.project not in (s["cwd"] or ""):
        continue
    if a.all or sum(s["tools"].values()) >= 3:
        rows.append(s)

rows.sort(key=lambda s: s["start"])
by_day = collections.defaultdict(list)
for s in rows:
    by_day[s["start"][:10]].append(s)
day = None
for s in rows:
    if s["start"][:10] != day:
        day = s["start"][:10]
        ds = by_day[day]
        files = set().union(*(x["edits"] for x in ds))
        print(f"\n# {day} · {len(ds)} sessions, {len(files)} files, +{sum(x['add'] for x in ds)}/-{sum(x['rem'] for x in ds)}")
    title = s["title"] or (s["first"] or "(no prompt)")[:70]
    print(f"\n## {title}\n- dir: `{(s['cwd'] or '?').replace(os.path.expanduser('~'), '~')}` · {s['prompts']} prompts")
    if s["first"]:
        print(f"- asked: {s['first'][:200]!r}")
    if s["commits"]:
        print("- commits: " + "; ".join(s["commits"]))
    if s["edits"]:
        names = sorted(os.path.basename(e) for e in s["edits"])
        print(f"- edited {len(names)} (+{s['add']}/-{s['rem']}): " + ", ".join(names[:10]) + (" …" if len(names) > 10 else ""))
