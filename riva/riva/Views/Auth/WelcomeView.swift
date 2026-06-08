import SwiftUI

// MARK: - Welcome View

struct WelcomeView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()
                
                // Riva wordmark
                VStack(spacing: 4) {
                    Text("RIVA")
                        .font(.archivoBlack(48))
                        .foregroundColor(accent.color)
                        .tracking(6)
                    
                    Text("The Gym Social")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.sub)
                        .tracking(3)
                }
                
                Spacer()
                
                // CTAs
                VStack(spacing: 12) {
                    NavigationLink(destination: SignUpView()) {
                        HStack {
                            Text("Sign Up")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(accent.color)
                        .foregroundColor(accent.onAccentText)
                        .cornerRadius(14)
                    }
                    
                    NavigationLink(destination: LoginView()) {
                        HStack {
                            Text("Log In")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(accent.color, lineWidth: 1.5)
                                .background(Color.clear)
                        )
                        .foregroundColor(accent.color)
                        .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
            .background(theme.background)
        }
        .tint(accent.color)
    }
}

// MARK: - Preview

#Preview {
    WelcomeView()
        .environmentObject(SessionManager())
        .environment(\.rivaTheme, .ink)
        .environment(\.rivaAccent, .gold)
}