import Foundation

/// Flip these to taste, then rebuild.
enum FilterSettings {
    static let home = URL(string: "https://www.instagram.com/")!

    /// Paths blocked entirely (exact match or anything underneath).
    /// "/reels" kills the Reels feed. Single reels friends send you ("/reel/abc") still open.
    static let blockedPaths = ["/reels"]

    static let hideReelsNavButton = true   // Reels icon in the tab bar
    static let hideExploreGrid    = true   // Keeps the search box, hides the doomscroll grid
    static let hideSponsored      = true   // "Sponsored" / "Ad" posts
    static let hideSuggested      = true   // Everything after "You're all caught up"
    static let hideFeedReels      = false  // Reels posted by people you follow
    static let blockAutoplay      = false  // Videos only play when tapped

    /// Hosts allowed to load inside the app. Anything else opens in Safari.
    static let allowedHosts = ["instagram.com", "cdninstagram.com", "facebook.com", "fbcdn.net", "fb.com"]

    static func isBlocked(path: String) -> Bool {
        blockedPaths.contains { path == $0 || path.hasPrefix($0 + "/") }
    }

    static func isAllowed(host: String) -> Bool {
        allowedHosts.contains { host == $0 || host.hasSuffix("." + $0) }
    }

    static var configJSON: String {
        let dict: [String: Any] = [
            "blockedPaths": blockedPaths,
            "hideReelsNavButton": hideReelsNavButton,
            "hideExploreGrid": hideExploreGrid,
            "hideSponsored": hideSponsored,
            "hideSuggested": hideSuggested,
            "hideFeedReels": hideFeedReels
        ]
        let data = try! JSONSerialization.data(withJSONObject: dict)
        return String(data: data, encoding: .utf8)!
    }
}
