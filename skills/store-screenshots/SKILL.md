---
name: store-screenshots
description: Set up store screenshot generation for an app project. Analyzes the app to pick the features worth showing, writes captions for every locale, matches the app's colors and fonts, and installs a generator that renders framed Play Store / App Store screenshots and a landscape banner from manual screenshots. Use when the user asks for store screenshots, promo frames, screenshot mockups, a store banner, or runs /store-screenshots.
---

# Store screenshots

Sets up `<project>/screenshots/` so the user only has to take the
screenshots by hand and run one command:

```
python screenshots/generate.py
```

which writes `screenshots/framed/<locale>/<name>.png` (1080x1920 store
frames) and `screenshots/framed/banner_<locale>.png` (1920x1080).

The generator lives next to this file in `generator/`. Read
`generator/generate.py`, `generator/config.example.json` and the templates
in `generator/templates/` before writing the config: every template
placeholder and CSS variable you can set is documented there.

## 1. Understand the app

Look at the project before proposing anything:

- **Name and icon**: launcher icon source (e.g. `assets/icon/`,
  `flutter_launcher_icons` config), display name.
- **Locales**: the app's own localization. For Flutter read `l10n.yaml`
  and the `.arb` files in its `arb-dir`; elsewhere look for `values-xx/`,
  `*.lproj`, i18n JSON. One caption per locale the app ships.
- **Theme**: primary, secondary/accent and surface colors (Flutter:
  `ThemeData`, `ColorScheme`, color constants; elsewhere the design
  tokens). Note the dark shades usable for a background gradient.
- **Fonts**: the font families the app uses and the `.ttf`/`.otf` files in
  the repo (`pubspec.yaml` fonts, `assets/fonts`, `assets/google_fonts`).
  The templates need a body font in weights 500 and 700, and a brand font
  for the app name on the banner. If the app loads fonts at runtime
  (e.g. `google_fonts` without bundled files), tell the user which files
  are needed and ask before downloading anything.
- **Features**: pages/routes, navigation, README, store listing text, home
  screen widgets, dark mode, onboarding. Figure out what the app is for
  and who it is for.

## 2. Propose the shot list

Pick 8 to 12 screens that sell the app, in store order:

- The first 2 or 3 carry the core promise: most people never scroll
  further.
- One clear benefit per screen; no two screens about the same thing.
- Include a home screen widget (as `"layout": "widget"`) and a dark mode
  shot when the app has them.
- Name the files `NN_short_name` (`01_home`, `02_quran`, ...).

Captions, written natively per locale (not word-for-word translations):

- Title: a benefit, at most ~26 characters so it stays on one line.
- Subtitle: what the screen offers, at most ~55 characters (two lines).
- Match the app's tone and the wording its own UI uses.

Present the list to the user as a table (file, screen, how to set it up,
caption per locale) and let them change it before writing files.

## 3. Install the generator

1. Copy `generator/generate.py` and `generator/templates/` into
   `<project>/screenshots/`. If `screenshots/` already holds something
   else, ask for another folder name. When updating an existing setup,
   replace only these two; never touch `config.json`, `custom/` or
   `raw/`.
2. Add `screenshots/raw/` and `screenshots/framed/` to `.gitignore`.
3. Write `screenshots/config.json` (shape: `config.example.json`):
   - `locales`: from step 1.
   - `source_width`: screenshot width in pixels (1080 on most phones);
     `crop_top`: status bar height in those pixels (around 100 at 1080).
   - `vars.app_name`, `images.icon`: paths are relative to `screenshots/`.
   - `vars.tagline_1`, `tagline_2`, `tagline_sub` per locale, for the
     banner: a two-line tagline (the second line is the key benefit,
     shown in `accent`), each line at most ~20 characters, and a one
     sentence subtitle of at most ~90 characters.
   - `fonts` and `theme`: map the app's theme onto every CSS variable in
     the example. Background gradient from the darkest brand shades,
     `accent` from the brand's highlight color, `blob-*` as faint
     tints (alpha under 0.12) for the banner's bubbles, `glow-*` from
     accent/primary with alpha, `title`/`subtitle` with strong contrast
     on the background, `wallpaper-*` light tints for the widget layout.
     For a light brand, a light gradient with dark text is fine; keep the
     contrast.
   - `banner.shots`: two app screens (not widget shots), back then
     front; the front phone is the strongest screen.
   - `captions`: from step 2. Widget entries get `"layout": "widget"` and
     `"crop": [top, bottom]`; adjust the crop once the real screenshot is
     in.
4. Write `screenshots/SHOTLIST.md` for the user: one row per screenshot
   with file name, screen, setup (data to show, light/dark, scroll
   position), plus these capture tips:
   - Same device for every shot, portrait, no notifications, full battery
     or clean status bar (Android demo mode).
   - Realistic demo data, no personal data.
   - Widget shots on a plain #00FF00 wallpaper.
   - Save as `screenshots/raw/<locale>/<name>.png` (jpg/webp also fine),
     switching the app language for each locale.

## 4. Extra styling

- Anything the templates do not cover goes into a project override:
  copy the template into `screenshots/custom/` and edit it there. The
  generator reads `custom/` before `templates/`.
- Extra text for a template: add it to `vars` (one string, or
  `{locale: string}`) or as an extra key on a caption entry, then use
  `{{key}}` in the template. Values are HTML-escaped. Extra images go in
  `images` and become data URIs.
- A layout of its own: `custom/<layout>.html` plus `"layout": "<layout>"`
  on the entries that use it.

## 5. Render and check

After the user has put the screenshots in `raw/`:

1. Run `python screenshots/generate.py` (`python3` on macOS/Linux). It
   needs Chrome or Edge, lists missing screenshots and skips them.
2. Look at every output image yourself. Check for wrapped or clipped
   titles, a status bar that is still visible or cropped too far, widget
   edges with green fringes or bad crops, and the banner composition.
3. Fix captions, `crop_top`, widget `crop` or theme values in
   `config.json` and render again until it looks right.
