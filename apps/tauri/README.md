# Spendot

Your daily spending, right in your menu bar.

This repo builds a real desktop app for **macOS and Windows from your
Windows machine** — no Mac required — using free GitHub-hosted build
runners. Every push to `main` produces:

- `spendot-mac-dmg` — a `.dmg` for macOS (unsigned — see note below)
- `spendot-windows-installer` — a `.exe` installer for Windows

## 1. Preview the UI right now (no setup needed)

Open `src/index.html` in your browser. Click the dot, add/remove expenses,
open settings. This is the exact same code the real app runs.

## 2. Put this on GitHub

1. Create a new repository on GitHub (public or private — Actions minutes
   are free either way, public repos get unlimited free minutes).
2. From this folder, run:
   ```
   git init
   git add .
   git commit -m "Spendot v1"
   git branch -M main
   git remote add origin https://github.com/YOUR-USERNAME/spendot.git
   git push -u origin main
   ```
3. That's it — pushing to `main` automatically triggers the build. Go to
   the **Actions** tab on your repo to watch it run (takes a few minutes).

## 3. Download your built app

1. On GitHub, click **Actions** → click the latest workflow run.
2. Scroll to **Artifacts** at the bottom.
3. Download `spendot-mac-dmg` and `spendot-windows-installer`.
4. Unzip — inside is the real `.dmg` / `.exe`.

## 4. Running the unsigned builds

**Windows:** double-click the `.exe`. You'll see a "Windows protected your
PC" SmartScreen warning (normal for unsigned apps) — click **More info** →
**Run anyway**.

**macOS:** double-click the `.dmg`, drag Spendot to Applications. The first
launch will be blocked by Gatekeeper ("Apple could not verify..."). Instead
of double-clicking, **right-click the app → Open → Open anyway**, or go to
**System Settings → Privacy & Security → Open Anyway**.

Once you're ready to sell this for real and remove those warnings, you'll
want:
- Apple Developer Program ($99/year) → lets you notarize, removing the
  Gatekeeper block entirely
- A Windows code signing certificate (~$100–300/year) → removes or softens
  the SmartScreen warning

Both can be added to this same workflow later without changing any app
code — only the GitHub Actions file needs new signing steps.

## What's in this repo

```
spendot/
├── src/                     ← the actual app UI (HTML/CSS/JS)
│   ├── index.html
│   ├── style.css
│   └── app.js
├── src-tauri/                ← native wrapper (tray icon, window, packaging)
│   ├── src/main.rs           ← tray setup, live icon color sync
│   ├── icons/                ← tray dot icons (green/amber/red) + app icon
│   ├── Cargo.toml
│   └── tauri.conf.json
├── .github/workflows/
│   └── build.yml             ← the free CI pipeline — builds Mac + Windows
├── package.json
└── README.md
```

## How the tray dot actually changes color

`app.js` calls `syncTrayIcon(level)` every time it recalculates your spend
status. Inside the real app, that calls a Rust command (`set_tray_icon` in
`main.rs`) which swaps the actual system tray icon between the three
pre-made PNGs in `src-tauri/icons/`. In a plain browser this call is a
harmless no-op — you'll only see the real tray icon change once this is
running as an actual Tauri app.

## Local development (once you have Rust + Node installed)

```
npm install
npx tauri icon src-tauri/icons/icon.png
npx tauri dev
```

`tauri dev` opens the real app window locally so you can test the tray
icon and window behavior directly, on whichever OS you're developing on.
