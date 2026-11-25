import SwiftUI

@main
struct QuietgramApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                InstagramWebView()
            }
        }
    }
}
