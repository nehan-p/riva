import SwiftUI

// MARK: - Hard Offset Shadow Modifier
/// The signature Riva shadow: a solid block offset with no blur
struct HardShadowModifier: ViewModifier {
    let color: Color
    let offset: CGSize
    
    func body(content: Content) -> some View {
        content
            .shadow(color: .clear, radius: 0, x: 0, y: 0)
            .overlay(
                content
                    .offset(x: offset.width, y: offset.height)
                    .blendMode(.destinationOut)
                    .allowsHitTesting(false)
            )
            .compositingGroup()
            .background(
                GeometryReader { geo in
                    Rectangle()
                        .fill(color)
                        .offset(x: offset.width, y: offset.height)
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            )
    }
}

/// A simpler approach using standard SwiftUI shadows with no blur
extension View {
    /// Apply Riva's signature hard offset shadow
    /// - Parameters:
    ///   - color: Shadow color (typically theme.hardShadow)
    ///   - x: Horizontal offset in points
    ///   - y: Vertical offset in points
    /// - Returns: View with hard block shadow
    func rivaShadow(color: Color = .black.opacity(0.55), x: CGFloat = 4, y: CGFloat = 4) -> some View {
        self.background(
            Rectangle()
                .fill(color)
                .offset(x: x, y: y)
                .mask(self)
        )
    }
    
    /// Apply the card emphasis shadow (4x4 for PR/Milestone cards)
    func emphasisShadow(theme: RivaTheme) -> some View {
        rivaShadow(color: theme.hardShadow, x: 4, y: 4)
    }
    
    /// Apply the nav bar shadow (3x3)
    func navShadow(theme: RivaTheme) -> some View {
        rivaShadow(color: theme.hardShadow, x: 3, y: 3)
    }
    
    /// Apply the center plate shadow (3x3)
    func plateShadow(theme: RivaTheme) -> some View {
        rivaShadow(color: theme.hardShadow, x: 3, y: 3)
    }
}