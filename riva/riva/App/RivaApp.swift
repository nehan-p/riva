import SwiftUI

@main
struct RivaApp: App {
    @StateObject private var sessionManager = SessionManager()
    @State private var theme: RivaTheme = .ink
    @State private var accent: RivaAccent = .gold
    
    var body: some Scene {
        WindowGroup {
            AuthGateView()
                .environmentObject(sessionManager)
                .environment(\.rivaTheme, theme)
                .environment(\.rivaAccent, accent)
                .onOpenURL { url in
                    sessionManager.handleVerificationURL(url)
                }
        }
    }
}