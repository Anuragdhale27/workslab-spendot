# Spendot (native Swift version)

A native SwiftUI menu bar app — no webview, no Tauri, pure AppKit/SwiftUI.
This is a **parallel, Mac-only** version alongside the Tauri build. It has
no Windows equivalent; if you want both platforms from one codebase, use
the Tauri project instead.

## What this uses

- **SwiftUI `MenuBarExtra`** (macOS 13+) — Apple's modern API for exactly
  this kind of app: a menu bar icon that opens a small popover window.
  This is real API, not a simulation — it's the same mechanism apps like
  the ones you saw on TinyShelf use.
- **`TimelineView(.animation)`** drives the rotating sheen + breathing
  pulse on the dot continuously, entirely in SwiftUI, no timers or hacks.
- **JSON file persistence** in `~/Library/Application Support/Spendot/`
  — same idea as the Tauri version's local file, just written with
  Swift's `Codable` instead of hand-rolled JS.

## Build it for free via GitHub Actions (no Mac needed)

`.github/workflows/build-swift.yml` builds a **universal** (Apple Silicon +
Intel) binary on a macOS runner, assembles `Spendot.app`, ad-hoc signs it
and packages `Spendot.dmg`. It runs on pushes to `main` and on pull
requests that touch `apps/swift/**`, or manually via **Actions → Run
workflow**.

1. **Forks:** GitHub disables Actions on forks by default. Open the
   **Actions** tab and click "I understand my workflows, go ahead and
   enable them".
2. Run **Build Spendot (Swift, native macOS)**.
3. Download the `spendot-swift-mac-dmg` artifact (kept for 14 days).

## Install

1. Open the DMG and drag `Spendot.app` to `/Applications`.
2. The app is ad-hoc signed but **not notarized** (that needs a paid Apple
   Developer account), so macOS blocks the first launch. Either
   right-click → **Open** → **Open**, or run once in Terminal:
   ```
   xattr -cr /Applications/Spendot.app
   ```
   Re-run it after every new download (the browser re-adds the quarantine flag).
3. The dot appears in the menu bar. There is no Dock icon.

## Quit / uninstall

- **Quit:** click the dot, then **Quit** (or ⌘Q).
- **Uninstall:** quit the app, then drag it to the Bin. If macOS says it is
  still open: `pkill -x Spendot`.
- **Remove saved data (optional):** `rm -rf ~/Library/Application\ Support/Spendot`
- **Reinstalling / updating:** always quit the running app first
  (`pkill -x Spendot`). Opening the app while an old copy is still running
  just brings the old process (and its old code) back.

## Where your data lives

Expenses and settings are saved to
`~/Library/Application Support/Spendot/data.json` on every change. The
folder is recreated if it goes missing. To find the file:
`find ~/Library -path "*pendot*" -name data.json`

## Structure

```
spendot-swift/
├── Package.swift                  ← Swift package manifest
├── icon-source.png                ← source image, converted to .icns in CI
├── Sources/Spendot/
│   ├── SpendotApp.swift            ← @main entry point, MenuBarExtra wiring
│   ├── StatusDotView.swift         ← the animated dot (rotating sheen + breathe)
│   ├── ContentView.swift           ← the popover: totals, quick add, entries
│   ├── SettingsView.swift          ← budget / threshold / quick amounts
│   ├── ExpenseStore.swift          ← persistence + all business logic
│   └── Models.swift                ← Expense, AppState, category icon guesser
└── .github/workflows/build-swift.yml ← builds + packages the .dmg, free runner
```

## Note

The Tauri version recently got a working 7-day history view. This Swift
version doesn't have it yet — port `renderHistory()`'s logic from
`apps/tauri/src/app.js` into `ExpenseStore.swift` / `ContentView.swift`
when you're ready to bring the two versions back in sync.

## Comparing this to the Tauri version

| | Swift (this) | Tauri |
|---|---|---|
| Platforms | macOS only | macOS + Windows, one codebase |
| Feel | Fully native, no webview | Native window, small embedded webview |
| Menu bar API | Real `NSStatusItem` via `MenuBarExtra` | Tauri's cross-platform tray API |
| Language | Swift | HTML/CSS/JS + Rust |
| Best for | Polished Mac-only release | Fastest path to selling on both OSes |

Nothing stops you from shipping both — some indie devs ship a native Mac
app and a separate Electron/Tauri Windows app under the same product name
once they've validated demand.
