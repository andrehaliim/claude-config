# claude-config

Personal Claude Code rules, shared across PCs.

| File | Applies to |
|---|---|
| `rules/general.md` | All projects: language, plan before changes, code review, commit message, git |
| `rules/flutter.md` | Flutter/Dart projects only (those with a `pubspec.yaml`) |

Claude Code loads every `.md` file in `~/.claude/rules/` in every session, so `~/.claude/rules` is a junction to this repo's `rules/` folder.

## Install on a new PC (Windows)

```powershell
git clone https://github.com/andrehaliim/claude-config.git C:\Work\claude-config
powershell -ExecutionPolicy Bypass -File C:\Work\claude-config\setup.ps1
```

Then restart Claude. The script backs up any existing `~/.claude/rules` and `~/.claude/CLAUDE.md` (as `*.bak-<timestamp>`) and creates the junction. No admin rights needed.

## Update

- Edit the files in this repo, then commit and push.
- On other PCs: `git pull`. Changes apply to new sessions.

## Notes

- PC-specific notes can still go in `~/.claude/CLAUDE.md`; it is loaded together with these rules.
- Do not put secrets, `settings.json`, or `.credentials.json` in this repo.
- The Dart MCP rules (`hot_restart`, `dtd`) need a recent Dart SDK on `PATH`, e.g. FVM's `fvm\default\bin\cache\dart-sdk\bin` before any older standalone Dart SDK.
