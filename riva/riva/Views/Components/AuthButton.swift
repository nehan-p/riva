import SwiftUI

// MARK: - Auth Button
struct AuthButton: View {
    let label: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false

    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: accent.onAccentText))
                }
                Text(label)
                    .font(.interSemiBold(16))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(isDisabled ? theme.muted : accent.color)
            .foregroundColor(isDisabled ? theme.background : accent.onAccentText)
            .cornerRadius(14)
            .rivaShadow(color: theme.hardShadow, x: 4, y: 4)
            .opacity(isDisabled ? 0.6 : 1.0)
        }
        .disabled(isDisabled || isLoading)
    }
}

#Preview {
    VStack(spacing: 16) {
        AuthButton(label: "Sign In", action: {})
        AuthButton(label: "Loading", action: {}, isLoading: true)
        AuthButton(label: "Disabled", action: {}, isDisabled: true)
    }
    .padding(24)
    .background(Color.riva.inkBg)
    .environment(\.rivaTheme, .ink)
    .environment(\.rivaAccent, .gold)
}