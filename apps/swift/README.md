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

1. Push this folder to a new GitHub repo (same steps as the Tauri repo):
   ```
   git init
   git add .
   git commit -m "Spendot native Swift v1"
   git branch -M main
   git remote add origin https://github.com/YOUR-USERNAME/spendot-swift.git
   git push -u origin main
   ```
2. Go to the **Actions** tab — `build-mac.yml` runs automatically on a
   real macOS GitHub runner (this one has actual Xcode installed, so
   `swift build` compiles for real, no cross-compilation tricks needed).
3. Download the `spendot-swift-mac-dmg` artifact when it finishes.
4. Since it's unsigned, opening it needs the same **right-click → Open →
   Open Anyway** step as the Tauri version, until you add the $99 Apple
   Developer notarization step later.

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
└── .github/workflows/build-mac.yml ← builds + packages the .dmg, free runner
```

## Honest caveat

I wrote this Swift code carefully against Apple's real, current
`MenuBarExtra` API, but — same as the Tauri project — I don't have a Mac
to compile it myself before handing it to you. The GitHub Actions run
will be the first real compile. If it fails, copy the exact error from
the Actions log back to me and I'll fix it directly; Swift compiler
errors are usually very precise about the line and cause.

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
