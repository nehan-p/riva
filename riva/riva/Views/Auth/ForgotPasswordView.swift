import SwiftUI

// MARK: - Forgot Password View

struct ForgotPasswordView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    @Environment(\.dismiss) private var dismiss
    
    @State private var email: String = ""
    @State private var emailError: String?
    @State private var isSending: Bool = false
    @State private var didSend: Bool = false
    
    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(theme.text)
                            .frame(width: 40, height: 40)
                            .background(theme.chip)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Wordmark
                        Text("RIVA")
                            .font(.rivaWordmark)
                            .foregroundColor(accent.color)
                            .tracking(6)
                            .padding(.top, 16)
                            .padding(.bottom, 4)
                        
                        // Tagline
                        Text("Reset your password")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(theme.sub)
                            .tracking(0.5)
                        
                        if !didSend {
                            // Form card
                            VStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    FieldLabel(text: "Email")
                                    RoundedIconField(
                                        text: $email,
                                        placeholder: "you@example.com",
                                        icon: "envelope.fill",
                                        error: emailError,
                                        keyboard: .emailAddress,
                                        textContentType: .emailAddress
                                    )
                                    .onSubmit { sendResetLink() }
                                    if let error = emailError {
                                        ErrorTextView(message: error)
                                    }
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(theme.raised)
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // Supabase error
                            AuthErrorBanner(message: sessionManager.authError)
                            
                            // Send button
                            Button {
                                sendResetLink()
                            } label: {
                                HStack(spacing: 8) {
                                    if isSending {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: accent.onAccentText))
                                    }
                                    Text(isSending ? "Sending..." : "Send Reset Link")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(accent.color)
                                .foregroundColor(accent.onAccentText)
                                .cornerRadius(14)
                            }
                            .disabled(isSending)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        } else {
                            // Success state
                            VStack(spacing: 20) {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(accent.color)
                                    .padding(.bottom, 8)
                                
                                Text("Reset link sent to \(email.trimmingCharacters(in: .whitespaces))")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(theme.sub)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                                
                                Button {
                                    dismiss()
                                } label: {
                                    Text("Back to Log In")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(accent.color)
                                }
                                .padding(.top, 16)
                            }
                            .padding(.top, 48)
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Send Reset Link
    
    private func sendResetLink() {
        emailError = nil
        sessionManager.clearError()
        
        if let error = Validators.validateEmail(email) {
            emailError = error.localizedDescription
            return
        }
        
        isSending = true
        
        Task {
            await sessionManager.resetPassword(email: email.trimmingCharacters(in: .whitespaces))
            await MainActor.run {
                isSending = false
                if sessionManager.authError == nil {
                    didSend = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ForgotPasswordView()
            .environmentObject(SessionManager())
            .environment(\.rivaTheme, .ink)
            .environment(\.rivaAccent, .gold)
    }
}