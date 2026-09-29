# Spendot — monorepo

Everything in one place: two app builds and the marketing website with a
live, always-current demo.

```
spendot/
├── apps/
│   ├── tauri/     ← cross-platform (macOS + Windows), one codebase
│   └── swift/     ← native macOS-only version, real MenuBarExtra
├── website/       ← marketing site + live demo, deployed to spendot.workslab.in
└── .github/workflows/
    ├── build-tauri.yml      ← builds Mac .dmg + Windows .exe, free runners
    ├── build-swift.yml      ← builds native Mac .dmg, free runner
    └── deploy-website.yml   ← deploys the website on every push, free
```

## 1. Push this to GitHub

```
git init
git add .
git commit -m "Spendot monorepo v1"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/spendot.git
git push -u origin main
```

All three workflows kick off automatically. Check the **Actions** tab.

## 2. Turn on GitHub Pages (one-time setup)

1. On GitHub: repo → **Settings** → **Pages**.
2. Under **Build and deployment → Source**, choose **GitHub Actions**
   (not "Deploy from a branch" — the workflow handles it).
3. That's it. From now on, every push to `main` redeploys the website.

## 3. Point your domain at it (one-time setup)

`website/CNAME` already contains `spendot.workslab.in`, which tells GitHub
Pages what domain to expect. You still need to point the domain itself at
GitHub — this part happens wherever `workslab.in`'s DNS is managed:

Add a **CNAME record**:
```
Host:  spendot
Value: YOUR-USERNAME.github.io
```

DNS changes can take anywhere from a few minutes to a few hours to
propagate. Once it resolves, go back to **Settings → Pages** on GitHub and
confirm the custom domain shows a green checkmark (this also auto-issues
a free HTTPS certificate for you).

## How the live demo stays in sync automatically

This is the part you specifically asked for: **you never hand-edit the
website's demo.** Every time `deploy-website.yml` runs, its first real
step deletes `website/demo/` and copies the current contents of
`apps/tauri/src/` into it. So the flow is:

1. You edit `apps/tauri/src/app.js` (or `style.css`, `index.html`) —
   change a color, add a feature, fix a bug.
2. You push to `main`.
3. `deploy-website.yml` runs, copies your updated source into
   `website/demo/`, and redeploys the site.
4. Visitors at spendot.workslab.in are looking at your actual latest code,
   automatically, with no manual step in between.

## Pricing

The website has a pricing card set to **$4.99, one-time purchase**. The
"Buy for Mac" / "Buy for Windows" buttons are currently placeholders
(`href="#"`) — real checkout needs a payment processor wired in. For a
$4.99 one-time digital download, the two easiest no-code options are:

- **Gumroad** — simplest, takes ~10% fee, gives you a hosted checkout link
- **Lemon Squeezy** — similar, handles tax/VAT automatically, popular for
  indie Mac apps specifically

Once you pick one, replace the two `href="#"` values in
`website/index.html` with your real checkout links — no other code needs
to change.

## Each app's own README

- `apps/tauri/README.md` — Tauri build details, local dev, signing notes
- `apps/swift/README.md` — native Swift version details, comparison table
