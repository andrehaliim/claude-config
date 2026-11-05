# General Rules

## Language

- Always reply in **Indonesian (Bahasa Indonesia)**, even when I write my question in another language (English, etc.).
- Keep code, identifiers, file names, commands, and technical terms as they are; only the explanation is in Indonesian.

## Plan before changing anything

Before editing, creating, or deleting any file, or running commands that change the project or system, first present a change plan and **wait for my approval**.

1. Investigate first (read-only): read the relevant code so the plan is based on the actual project, not guesses.
2. Present the plan with:
   - **Goal**: my request in your own words, so I can check you understood it.
   - **Files to change**: each file path with what will change in it and why.
   - **New files**: path and purpose (if any).
   - **Dependencies / config**: packages to add or remove, config or native files touched (if any).
   - **Risks / side effects**: what else could be affected (other screens, existing data, breaking changes).
   - **Verification**: how the change will be checked (analyze, tests, manual testing).
   - **Assumptions / questions**: anything unclear that I should decide.
3. **Stop and wait.** Do not start editing until I explicitly approve (e.g. "ok", "lanjut", "gas"). If I correct the plan, present the revised plan and wait again.
4. While working: if the approved plan turns out to need a meaningful change (other files, different approach, new dependency), stop and present the updated plan before continuing. Small details inside the approved scope do not need re-approval.

Exceptions (no plan needed): pure questions or explanations, read-only investigation, or when I explicitly say to do it right away (e.g. "langsung saja", "tanpa plan").

## Code review

When I ask for a code review, review only (do not edit anything), then report:

1. **Findings list**, sorted from most to least severe, numbered continuously across groups:
   - 🔴 **Critical**: bugs, crashes, data loss, security issues, broken functionality.
   - 🟠 **High**: likely bugs in edge cases, memory leaks, performance problems, missing error handling.
   - 🟡 **Medium**: maintainability, wrong patterns, duplication, deviation from project conventions.
   - 🟢 **Low**: style, naming, readability, small improvements.

   Each finding: `file:line`, what is wrong, why it matters (concrete impact), and the suggested fix in 1–2 sentences. Only report real issues; skip empty groups. If nothing is wrong, say so.

2. **Fix batches**: group the suggested fixes into small batches, ordered by priority (most critical first). Keep related fixes (same file or same concern) in the same batch. For each batch, list the finding numbers it covers, the files it touches, and its risk.

3. **Stop and wait** for me to choose which batch(es) to apply. Apply one batch at a time following the normal flow (plan → approval → edit → verify → end-of-task report), then offer the next batch.

## Git commit message at the end of every task

Every time a task that changed files in a git repository is finished, end the reply with a commit message (after any other end-of-task report, such as manual testing steps):

- Provide a ready-to-copy commit message inside a fenced code block (` ```text `), with nothing else inside the block.
- Follow the style of the repository's existing commits (check `git log`). If there is no clear style, use Conventional Commits in English: `type(scope): summary` (types: `feat`, `fix`, `refactor`, `style`, `chore`, `docs`, `test`, `perf`), with a summary of max ~72 characters.
- **Keep it short**: the summary line, plus at most 1–2 short sentences after a blank line only if really needed. No long bullet lists, no file-by-file details.
- If the conversation continues and files change again, give an **updated** commit message that covers all changes not yet committed (the whole task so far), not only the latest change.
- Only provide the message. Do not run `git commit` yourself (see Git below).

## Git

- Do not `commit`, `push`, create branches, or rewrite git history unless asked.
