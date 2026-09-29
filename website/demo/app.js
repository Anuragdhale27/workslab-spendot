// ---------------------------------------------------------------
// STORAGE (localStorage for the browser preview — swapped to a real
// file via Tauri's fs API is a natural next step once this is wrapped)
// ---------------------------------------------------------------

const STORAGE_KEY = "spendot-data-v2";

function defaultState() {
  return {
    budget: 60,
    threshold: 70,
    quickAmounts: [5, 10, 20, 50],
    theme: "auto",
    entries: [],
    streak: 0,
    lastStreakDate: null,
  };
}

function loadState() {
  const raw = localStorage.getItem(STORAGE_KEY);
  if (!raw) return defaultState();
  try {
    return { ...defaultState(), ...JSON.parse(raw) };
  } catch {
    return defaultState();
  }
}

function saveState(state) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

let state = loadState();

// ---------------------------------------------------------------
// CATEGORY ICON GUESSING
// ---------------------------------------------------------------

const ICON_RULES = [
  { keywords: ["coffee", "latte", "espresso", "cafe"], icon: "☕" },
  { keywords: ["lunch", "dinner", "breakfast", "food", "restaurant", "meal"], icon: "🍽️" },
  { keywords: ["grocery", "groceries", "supermarket"], icon: "🛒" },
  { keywords: ["snack", "candy", "chips"], icon: "🍿" },
  { keywords: ["gas", "fuel", "uber", "taxi", "transport", "bus", "train"], icon: "🚗" },
  { keywords: ["movie", "game", "netflix", "spotify", "entertainment"], icon: "🎬" },
  { keywords: ["shopping", "clothes", "amazon"], icon: "🛍️" },
];

function iconFor(label) {
  const lower = (label || "").toLowerCase();
  for (const rule of ICON_RULES) {
    if (rule.keywords.some((k) => lower.includes(k))) return rule.icon;
  }
  return "💳";
}

// ---------------------------------------------------------------
// HELPERS
// ---------------------------------------------------------------

function todayStr() {
  return new Date().toISOString().slice(0, 10);
}

function todaysEntries() {
  const today = todayStr();
  return state.entries.filter((e) => e.date === today);
}

function todaysTotal() {
  return todaysEntries().reduce((sum, e) => sum + e.amount, 0);
}

function statusLevel(total, budget, threshold) {
  const ratio = budget > 0 ? total / budget : 0;
  if (ratio >= 1) return "red";
  if (ratio >= threshold / 100) return "amber";
  return "green";
}

function statusLabel(level) {
  if (level === "red") return "over budget";
  if (level === "amber") return "close to limit";
  return "under budget";
}

function formatMoney(n) {
  return `$${n % 1 === 0 ? n.toFixed(0) : n.toFixed(2)}`;
}

function updateStreak() {
  const today = todayStr();
  if (state.lastStreakDate === today) return;

  const yesterday = new Date(Date.now() - 86400000).toISOString().slice(0, 10);
  const yesterdayTotal = state.entries
    .filter((e) => e.date === yesterday)
    .reduce((sum, e) => sum + e.amount, 0);

  if (state.lastStreakDate === yesterday && yesterdayTotal > 0 && yesterdayTotal <= state.budget) {
    state.streak += 1;
  } else if (state.lastStreakDate !== null) {
    state.streak = 0;
  }
  state.lastStreakDate = today;
  saveState(state);
}

// ---------------------------------------------------------------
// THEME
// ---------------------------------------------------------------

function applyTheme() {
  const root = document.documentElement;
  if (state.theme === "auto") {
    root.removeAttribute("data-theme");
  } else {
    root.setAttribute("data-theme", state.theme);
  }
}

const systemDark = window.matchMedia("(prefers-color-scheme: dark)");
function syncAutoTheme() {
  if (state.theme === "auto") {
    document.documentElement.setAttribute("data-theme", systemDark.matches ? "dark" : "light");
  }
}
systemDark.addEventListener("change", syncAutoTheme);

// ---------------------------------------------------------------
// DOM REFS
// ---------------------------------------------------------------

const dot = document.getElementById("dot");
const dotMini = document.getElementById("dot-mini");
const popover = document.getElementById("popover");
const settingsPanel = document.getElementById("settings-panel");
const totalEl = document.getElementById("total");
const budgetDisplayEl = document.getElementById("budget-display");
const statusBadge = document.getElementById("status-badge");
const progressFill = document.getElementById("progress-fill");
const quickAddRow = document.getElementById("quick-add-row");
const entriesList = document.getElementById("entries-list");
const addForm = document.getElementById("add-form");
const amountInput = document.getElementById("amount-input");
const labelInput = document.getElementById("label-input");
const formError = document.getElementById("form-error");
const streakEl = document.getElementById("streak");
const clockEl = document.getElementById("clock");

const settingsBtn = document.getElementById("settings-btn");
const closeSettingsBtn = document.getElementById("close-settings-btn");
const appearanceRow = document.getElementById("appearance-row");
const budgetInput = document.getElementById("budget-input");
const thresholdInput = document.getElementById("threshold-input");
const quickAmountsEdit = document.getElementById("quick-amounts-edit");
const saveSettingsBtn = document.getElementById("save-settings-btn");

// ---------------------------------------------------------------
// TAURI BRIDGE — no-ops harmlessly in a plain browser. Once this
// runs inside the real Tauri app, window.__TAURI__ exists and this
// pushes the current status color to the real system tray icon.
// ---------------------------------------------------------------

function syncTrayIcon(level) {
  if (window.__TAURI__ && window.__TAURI__.invoke) {
    window.__TAURI__.invoke("set_tray_icon", { level }).catch(() => {});
  }
}

// ---------------------------------------------------------------
// RENDER
// ---------------------------------------------------------------

function render() {
  const total = todaysTotal();
  const level = statusLevel(total, state.budget, state.threshold);
  const levelSuffix = level !== "green" ? ` ${level}` : "";

  totalEl.textContent = formatMoney(total);
  budgetDisplayEl.textContent = formatMoney(state.budget);

  statusBadge.textContent = statusLabel(level);
  statusBadge.className = "badge" + levelSuffix;

  const pct = state.budget > 0 ? Math.min(100, (total / state.budget) * 100) : 0;
  progressFill.style.width = `${pct}%`;
  progressFill.className = "progress-fill" + levelSuffix;

  dot.className = "spendot-dot" + levelSuffix;
  dotMini.className = "spendot-dot spendot-dot--sm" + levelSuffix;

  syncTrayIcon(level);

  quickAddRow.innerHTML = "";
  state.quickAmounts.forEach((amt) => {
    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "quick-add-btn";
    btn.textContent = `+$${amt}`;
    btn.addEventListener("click", () => addEntry(amt, ""));
    quickAddRow.appendChild(btn);
  });

  const entries = todaysEntries();
  entriesList.innerHTML = "";
  if (entries.length === 0) {
    entriesList.innerHTML = `<div class="empty-state">no expenses logged today</div>`;
  } else {
    entries.slice().reverse().forEach((e) => {
      const row = document.createElement("div");
      row.className = "entry-row";
      const time = new Date(e.createdAt).toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });
      row.innerHTML = `
        <span class="entry-icon">${iconFor(e.label)}</span>
        <span class="entry-label">${escapeHtml(e.label || "expense")}</span>
        <span class="entry-time">${time}</span>
        <span class="entry-amount">${formatMoney(e.amount)}</span>
        <button class="entry-remove" data-id="${e.id}" aria-label="Remove expense">✕</button>
      `;
      entriesList.appendChild(row);
    });
  }

  streakEl.textContent = state.streak > 0 ? `🔥 ${state.streak} day streak` : "";

  budgetInput.value = state.budget;
  thresholdInput.value = state.threshold;
  [...appearanceRow.children].forEach((btn) => {
    btn.classList.toggle("active", btn.dataset.mode === state.theme);
  });
  quickAmountsEdit.innerHTML = "";
  state.quickAmounts.forEach((amt, i) => {
    const input = document.createElement("input");
    input.type = "number";
    input.min = "1";
    input.value = amt;
    input.dataset.index = i;
    quickAmountsEdit.appendChild(input);
  });
}

function escapeHtml(str) {
  const div = document.createElement("div");
  div.textContent = str;
  return div.innerHTML;
}

function addEntry(amount, label) {
  const entry = {
    id: `e_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`,
    amount: Math.round(amount * 100) / 100,
    label: label.trim(),
    date: todayStr(),
    createdAt: Date.now(),
  };
  state.entries.push(entry);
  saveState(state);
  render();
}

// ---------------------------------------------------------------
// EVENTS
// ---------------------------------------------------------------

dot.addEventListener("click", () => {
  popover.classList.toggle("hidden");
  settingsPanel.classList.add("hidden");
  if (!popover.classList.contains("hidden")) {
    updateStreak();
    render();
  }
});

addForm.addEventListener("submit", (evt) => {
  evt.preventDefault();
  const amount = parseFloat(amountInput.value);

  if (!amount || amount <= 0) {
    formError.textContent = "enter an amount first";
    formError.classList.remove("hidden");
    return;
  }
  formError.classList.add("hidden");
  addEntry(amount, labelInput.value);
  amountInput.value = "";
  labelInput.value = "";
  amountInput.focus();
});

entriesList.addEventListener("click", (evt) => {
  const btn = evt.target.closest(".entry-remove");
  if (!btn) return;
  state.entries = state.entries.filter((e) => e.id !== btn.dataset.id);
  saveState(state);
  render();
});

settingsBtn.addEventListener("click", () => {
  popover.classList.add("hidden");
  settingsPanel.classList.toggle("hidden");
});

closeSettingsBtn.addEventListener("click", () => {
  settingsPanel.classList.add("hidden");
});

appearanceRow.addEventListener("click", (evt) => {
  const btn = evt.target.closest(".appearance-opt");
  if (!btn) return;
  state.theme = btn.dataset.mode;
  applyTheme();
  syncAutoTheme();
  render();
});

saveSettingsBtn.addEventListener("click", () => {
  const budget = parseFloat(budgetInput.value);
  const threshold = parseFloat(thresholdInput.value);
  if (budget && budget > 0) state.budget = Math.round(budget);
  if (threshold && threshold > 0 && threshold <= 100) state.threshold = Math.round(threshold);

  const amounts = [...quickAmountsEdit.querySelectorAll("input")]
    .map((i) => parseFloat(i.value))
    .filter((v) => v > 0);
  if (amounts.length === 4) state.quickAmounts = amounts;

  saveState(state);
  settingsPanel.classList.add("hidden");
  render();
});

// ---------------------------------------------------------------
// CLOCK (cosmetic, fake menu bar preview only)
// ---------------------------------------------------------------

function tickClock() {
  const now = new Date();
  const opts = { weekday: "short", hour: "numeric", minute: "2-digit" };
  clockEl.textContent = now.toLocaleTimeString([], opts).replace(",", "");
}
tickClock();
setInterval(tickClock, 30000);

// ---------------------------------------------------------------
// INIT
// ---------------------------------------------------------------

applyTheme();
syncAutoTheme();
render();
