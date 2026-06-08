import SwiftUI

// MARK: - Auth Gate View

struct AuthGateView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    
    var body: some View {
        ZStack {
            theme.background
                .ignoresSafeArea()
            
            switch sessionManager.authState {
            case .loading:
                loadingView
            case .authenticated:
                FeedView()
                    .transition(.opacity)
            case .unauthenticated:
                WelcomeView()
                    .transition(.opacity)
            case .emailVerificationPending(let email):
                EmailVerificationView(email: email)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: String(describing: sessionManager.authState))
    }
    
    // MARK: - Loading / Splash
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            // Riva wordmark
            VStack(spacing: 4) {
                Text("RIVA")
                    .font(.archivoBlack(42))
                    .foregroundColor(accent.color)
                    .tracking(4)
                
                Text("The Gym Social")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.sub)
                    .tracking(2)
            }
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: accent.color))
                .padding(.top, 24)
        }
    }
}

// MARK: - Email Verification View

struct EmailVerificationView: View {
    let email: String
    @EnvironmentObject private var sessionManager: SessionManager
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 20) {
                // Riva wordmark
                VStack(spacing: 4) {
                    Text("RIVA")
                        .font(.archivoBlack(40))
                        .foregroundColor(accent.color)
                        .tracking(5)
                    
                    Text("The Gym Social")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(theme.sub)
                        .tracking(2)
                }
                .padding(.bottom, 24)
                
                // Mail icon
                Image(systemName: "envelope.fill")
                    .font(.system(size: 44))
                    .foregroundColor(accent.color)
                
                // Heading
                Text("Check Your Email")
                    .font(.archivoBold(24))
                    .foregroundColor(theme.text)
                
                // Instructions
                Text("We sent a verification link to")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(theme.sub)
                
                Text(email)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(accent.color)
                
                Text("Click the link in the email to activate your account, then come back and log in.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(theme.sub)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Back to log in
                Button {
                    sessionManager.authState = .unauthenticated
                } label: {
                    Text("Back to Log In")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(accent.color)
                }
                .padding(.top, 16)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    AuthGateView()
        .environmentObject(SessionManager())
        .environment(\.rivaTheme, .ink)
        .environment(\.rivaAccent, .gold)
}