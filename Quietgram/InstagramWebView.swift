import SwiftUI
import WebKit

struct InstagramWebView: UIViewRepresentable {

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()          // keeps you logged in
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = FilterSettings.blockAutoplay ? .all : []
        // Look like mobile Safari so Instagram serves the normal mobile site
        config.applicationNameForUserAgent = "Version/18.0 Mobile/15E148 Safari/604.1"

        config.userContentController.addUserScript(
            WKUserScript(source: ContentFilter.script,
                         injectionTime: .atDocumentStart,
                         forMainFrameOnly: true)
        )

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground

        let refresh = UIRefreshControl()
        refresh.addTarget(context.coordinator, action: #selector(Coordinator.pullToRefresh), for: .valueChanged)
        webView.scrollView.refreshControl = refresh

        context.coordinator.webView = webView
        webView.load(URLRequest(url: FilterSettings.home))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        weak var webView: WKWebView?

        @objc func pullToRefresh() {
            webView?.reload()
        }

        // Block Reels on real page loads and send non-Instagram links to Safari
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            guard let url = navigationAction.request.url, let host = url.host else { return .allow }
            let isMainFrame = navigationAction.targetFrame?.isMainFrame ?? true
            guard isMainFrame else { return .allow }

            if !FilterSettings.isAllowed(host: host) {
                await UIApplication.shared.open(url)
                return .cancel
            }
            if FilterSettings.isBlocked(path: url.path) {
                webView.load(URLRequest(url: FilterSettings.home))
                return .cancel
            }
            return .allow
        }

        // target="_blank" links: open in the same view
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.scrollView.refreshControl?.endRefreshing()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            webView.scrollView.refreshControl?.endRefreshing()
        }
    }
}
