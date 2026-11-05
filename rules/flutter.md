# Flutter Project Rules

> **Scope:** these rules apply ONLY when the project (or a parent folder) contains a `pubspec.yaml`.
> Ignore this entire file in non-Flutter/Dart projects.
> If a project's own `CLAUDE.md` conflicts with this file, follow the project's `CLAUDE.md`.

## 1. Understand the project before writing code

- Before changing anything, read `pubspec.yaml`, `analysis_options.yaml`, and the folder structure under `lib/`.
- Follow the patterns that **already exist** in the project. Do not introduce new ones:
  - **State management**: use whatever the project already uses (Provider, Riverpod, Bloc, GetX, etc.). Do not mix or replace it without permission.
  - **Folder structure & naming**: put new files where the project's conventions say they belong (e.g. `views/` vs `pages/` vs `screens/`, `proxy/` vs `network/`). Do not create new top-level structures.
  - **Networking, models, routing, local storage**: reuse the existing libraries and helpers (e.g. the already-configured `dio`/`http` client, existing models).
- Before creating a new widget, helper, or extension, search the project for an existing one that does the same thing.
- If the project's patterns are unclear or inconsistent, ask instead of guessing.

## 2. Flutter version & FVM

- If a `.fvmrc` (or `.fvm/`) exists, **always** run commands through FVM: `fvm flutter ...` and `fvm dart ...`, never the global `flutter`/`dart`.
- Do not change the Flutter version in `.fvmrc`, the `environment: sdk:` constraint in `pubspec.yaml`, or run `flutter upgrade` without permission.
- Do not use APIs that are unavailable in the project's Flutter/Dart version. Check the version first, since projects may be on different versions.

## 3. Dependencies

- **Do not add, remove, or upgrade packages without permission.** First explain which package, why, and what the alternatives are.
- Once approved, use `fvm flutter pub add <package>` (or `flutter pub add`) instead of editing versions by hand.
- Never edit `pubspec.lock` manually.
- Prefer solutions using already-installed packages before proposing a new one.

## 4. Dart & Flutter code style

- Follow Effective Dart and the lints configured in the project's `analysis_options.yaml`.
- **Null safety**: avoid the `!` operator unless the value is guaranteed non-null. Prefer `?.`, `??`, and explicit checks.
- Use `const` constructors and `const` widgets wherever possible.
- Split large widgets into **separate widget classes** (`StatelessWidget`/`StatefulWidget`), not `_buildXxx()` helper methods that return widgets.
- Do not put business logic, API calls, or heavy work inside `build()`.
- Always `dispose()` every controller (`TextEditingController`, `AnimationController`, `ScrollController`, `StreamSubscription`, `FocusNode`, etc.).
- After an `await` inside a `State`, check `if (!mounted) return;` before using `context` or calling `setState`.
- Never use a `BuildContext` across an async gap without a `mounted` (or `context.mounted`) check.
- Handle network/IO errors explicitly (try/catch, show a message to the user). Never swallow exceptions silently.
- Use `debugPrint` or the project's logger instead of `print`, and do not leave unnecessary debug logs behind.
- **UI text**: if the project uses localization (`l10n/`, `.arb`, `intl`, `easy_localization`), all new user-facing strings must go through it, not be hardcoded.
- **Sizing & theming**: use colors, text styles, and sizing helpers from the project's theme/constants (e.g. `Theme.of(context)`, constants files, `flutter_screenutil` if used). Do not hardcode new colors or sizes arbitrarily.
- **No hardcoded secrets**: API keys, tokens, passwords, and production base URLs must never be written directly in code.

## 5. Code generation

- If the project uses `build_runner` (e.g. `json_serializable`, `freezed`, `riverpod_generator`, `drift`, `injectable`), run this after changing the source files:
  `fvm dart run build_runner build --delete-conflicting-outputs`
- **Never edit generated files** (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.config.dart`, etc.) by hand.

## 6. Sensitive areas: ask first

Do not change any of the following without explicit permission:

- Native folders `android/`, `ios/`, `macos/`, `windows/`, `linux/`, `web/` (including `build.gradle`, `AndroidManifest.xml`, `Info.plist`, `Podfile`).
- Signing & credentials: keystores, `key.properties`, `google-services.json`, `GoogleService-Info.plist`, `.env` files.
- Application ID / bundle identifier, app name, version (`version:` in `pubspec.yaml`), and app icons.

## 7. UI design changes: mockups first

When I ask to change a UI design, whether a whole screen or a single part (card, dialog, bottom sheet, list item, form, button, app bar, etc.), do not implement right away:

1. Read the current widget and the project's theme (colors, text styles, spacing, radius, fonts, icons) first, so the mockups fit the existing app.
2. Show **2–4 distinct mockup options** to choose from. Present them visually with the best available tool (inline visual widget or HTML mockup at mobile width). If no visual tool is available, fall back to an ASCII sketch plus a clear description.
   - Show the current design next to the options for comparison, when practical.
   - Label each option (A, B, C, ...) with 1–2 sentences on what makes it different (layout, hierarchy, density, style).
   - Use realistic sample data from the app, not lorem ipsum, and keep the options within the project's theme unless I ask for a new style.
   - Mockups are previews only. They are not code to copy; the final result is built in Flutter with the project's widgets and theme.
3. **Stop and wait** for my choice. I may pick one, combine parts of several, or ask for new options.
4. After I choose, continue with the change plan (`general.md`) for the chosen design, then implement it.

Exception: small, precise tweaks I describe exactly (e.g. "change the padding to 16", "make the title bold") do not need mockups.

## 8. Verify before claiming done

After changing code, run (with `fvm` if the project uses FVM):

1. `fvm dart format <changed files>`: format only the files you changed, never reformat the whole project.
2. `fvm flutter analyze`: no new errors. Fix any new warnings introduced by your own changes too.
3. `fvm flutter test`: if the project has a `test/` folder containing tests.

Report the results as they are. If something fails or cannot be run, say so clearly. Do not claim the work is done.

## 9. Hot reload / hot restart via Dart MCP

After finishing code edits, apply them to the running app through the Dart MCP server (`dart-mcp-server` tools):

> Tool names differ between Dart SDK versions (e.g. older SDKs use `connect_dart_tooling_daemon`, newer ones use `dtd`). Use whichever tools the connected Dart MCP server actually provides.

1. If not connected yet, connect to the Dart Tooling Daemon (DTD):
   - Newer SDKs (`dtd` tool): run `listDtdUris` first, then `connect` with the chosen URI (prefer the instance whose working dir matches the project or the IDE), then `listConnectedApps` to find the running app.
   - Older SDKs (`connect_dart_tooling_daemon`): this needs a URI from me.
   - Never make up a DTD URI. If none can be found, ask me for it and suggest the IDE command "Dart: Copy DTD Uri to clipboard".
2. Choose the right action:
   - **Hot reload** (`hot_reload`): for UI/widget changes and logic changes inside existing methods.
   - **Hot restart** (`hot_restart`): when the change affects app state initialization, e.g. `main()`, `initState()`, global/static variables, providers/DI setup, enums, or class/generic type changes. If the server has no hot restart tool (older Dart SDK), tell me to hot restart myself (press `R` in the `flutter run` terminal, or the IDE's Hot Restart button).
   - **Full rebuild needed**: hot reload/restart does NOT cover changes to `pubspec.yaml` (new packages), native code (`android/`, `ios/`), assets declarations, or `.env`/build config. Do not try to reload; tell me the app must be stopped and run again.
3. After reloading, check `get_runtime_errors` and fix any new runtime errors before reporting.
4. If no app is running or the Dart MCP server is unavailable, do not launch the app yourself. Say clearly that the reload was skipped and why.

## 10. End-of-task report: manual testing steps

Every time a task that changed code is finished, end the reply with numbered manual testing steps that I can follow myself in the running app, placed **before** the git commit message (the commit message rule lives in `general.md`):

- Where to start (which screen/page and how to get there).
- What to do (tap, type, scroll, input values to use).
- The expected result for each step.
- Relevant edge cases to check too (empty data, invalid input, no internet, long text, etc.).

## 11. Build folders

- Do not run `flutter clean` or delete `build/`, `.dart_tool/`, or `.fvm/` without permission.
