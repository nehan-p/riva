import SwiftUI

@main
struct RivaApp: App {
    @State private var theme: RivaTheme = .ink
    @State private var accent: RivaAccent = .gold
    
    var body: some Scene {
        WindowGroup {
            FeedView()
                .environment(\.rivaTheme, theme)
                .environment(\.rivaAccent, accent)
        }
    }
}