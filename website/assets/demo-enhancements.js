// This file is only ever loaded inside the embedded website demo
// (injected by deploy-website.yml after copying the real app source).
// It never ships in the actual desktop app.

window.addEventListener("DOMContentLoaded", function () {
  var dotEl = document.getElementById("dot");
  var popoverEl = document.getElementById("popover");

  // Show the popover already open so visitors see the real product
  // immediately, instead of a bare menu bar they have to click first.
  if (dotEl && popoverEl && popoverEl.classList.contains("hidden")) {
    dotEl.click();
  }

  function reportHeight() {
    var h = document.documentElement.scrollHeight;
    window.parent.postMessage({ type: "spendot-demo-resize", height: h }, "*");
  }

  reportHeight();
  window.addEventListener("resize", reportHeight);

  var observer = new MutationObserver(reportHeight);
  observer.observe(document.body, { childList: true, subtree: true, attributes: true });
});
