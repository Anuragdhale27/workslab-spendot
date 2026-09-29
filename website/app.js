// ---------------- live demo: resize the iframe to fit its content ----------------
// This is what turns the embed from a fixed empty box into a widget that
// hugs its real shape: short and wide when the popover is closed,
// taller once it opens — never a big empty square.

window.addEventListener("message", (evt) => {
  if (!evt.data || evt.data.type !== "spendot-demo-resize") return;
  const frame = document.getElementById("demo-frame");
  if (!frame) return;
  const height = Math.max(160, Math.min(760, evt.data.height + 20));
  frame.style.height = `${height}px`;
});

// ---------------- theme toggle ----------------

const THEME_KEY = "spendot-site-theme";

function applySiteTheme(theme) {
  document.documentElement.setAttribute("data-site-theme", theme);
  const btn = document.getElementById("theme-toggle");
  if (btn) btn.textContent = theme === "dark" ? "☀" : "🌙";
}

function initTheme() {
  const saved = localStorage.getItem(THEME_KEY);
  const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
  applySiteTheme(saved || (prefersDark ? "dark" : "light"));
}

function toggleTheme() {
  const current = document.documentElement.getAttribute("data-site-theme");
  const next = current === "dark" ? "light" : "dark";
  localStorage.setItem(THEME_KEY, next);
  applySiteTheme(next);
}

document.addEventListener("DOMContentLoaded", () => {
  initTheme();
  const btn = document.getElementById("theme-toggle");
  if (btn) btn.addEventListener("click", toggleTheme);

  // mobile nav toggle
  const navToggle = document.getElementById("nav-toggle");
  const navLinks = document.getElementById("nav-links");
  if (navToggle && navLinks) {
    navToggle.addEventListener("click", () => {
      navLinks.classList.toggle("open");
    });
  }
});
