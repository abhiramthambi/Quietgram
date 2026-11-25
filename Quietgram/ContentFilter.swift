import Foundation

/// JavaScript injected into every Instagram page.
/// Matches on links and visible text rather than Instagram's obfuscated class names,
/// so it survives most of their redesigns. If something slips through, this is the file to tweak.
enum ContentFilter {
    static var script: String {
        #"""
        (() => {
          if (window.__quietgram) return;
          window.__quietgram = true;

          const CFG = \#(FilterSettings.configJSON);
          const isBlocked = (path) => CFG.blockedPaths.some(p => path === p || path.startsWith(p + "/"));

          // ---------- 1. CSS (applied before the page paints) ----------
          let css = "";
          if (CFG.hideReelsNavButton) {
            css += 'a[href="/reels/"], a[href^="/reels/"] { display: none !important; }\n';
          }
          if (CFG.hideExploreGrid) {
            css += '.qg-explore main a[href^="/p/"], .qg-explore main a[href^="/reel/"] { display: none !important; }\n';
          }
          const style = document.createElement("style");
          style.textContent = css;
          (document.head || document.documentElement).appendChild(style);

          // ---------- 2. Route guard (Instagram is a single-page app) ----------
          const onRoute = () => {
            const path = location.pathname;
            if (isBlocked(path)) { location.replace("/"); return; }
            const onExplore = path === "/explore" || path === "/explore/" || path.startsWith("/explore/search");
            document.documentElement.classList.toggle("qg-explore", onExplore);
          };

          for (const method of ["pushState", "replaceState"]) {
            const original = history[method];
            history[method] = function () {
              const result = original.apply(this, arguments);
              onRoute();
              return result;
            };
          }
          window.addEventListener("popstate", onRoute);

          // Stop taps on blocked links before Instagram's router sees them
          document.addEventListener("click", (e) => {
            const a = e.target.closest && e.target.closest("a[href]");
            if (!a) return;
            const url = new URL(a.href, location.href);
            if (url.host === location.host && isBlocked(url.pathname)) {
              e.preventDefault();
              e.stopPropagation();
            }
          }, true);

          // ---------- 3. Feed cleaning ----------
          const findText = (root, re) => {
            const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
            let node;
            while ((node = walker.nextNode())) {
              if (re.test(node.nodeValue.trim())) return node;
            }
            return null;
          };

          const SPONSORED = /^(Sponsored|Ad)$/i;
          const CAUGHT_UP = /^(You[’']re all caught up|You[’']ve completely caught up|Suggested [Pp]osts)/;

          const hide = (el, reason) => {
            el.dataset.qgHidden = reason;
            el.style.setProperty("display", "none", "important");
          };

          const clean = () => {
            if (!document.body) return;
            const marker = CFG.hideSuggested ? findText(document.body, CAUGHT_UP) : null;
            document.querySelectorAll("article:not([data-qg-hidden])").forEach((post) => {
              if (CFG.hideSponsored && findText(post, SPONSORED)) return hide(post, "ad");
              if (CFG.hideFeedReels && post.querySelector('a[href*="/reel/"]')) return hide(post, "reel");
              if (marker && (marker.compareDocumentPosition(post) & Node.DOCUMENT_POSITION_FOLLOWING)) {
                return hide(post, "suggested");
              }
            });
          };

          let queued = false;
          const schedule = () => {
            if (queued) return;
            queued = true;
            setTimeout(() => { queued = false; clean(); }, 200);
          };

          new MutationObserver(schedule).observe(document.documentElement, { childList: true, subtree: true });
          onRoute();
          schedule();
        })();
        """#
    }
}
