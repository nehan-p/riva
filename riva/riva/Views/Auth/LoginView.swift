import SwiftUI

// MARK: - Login View

struct LoginView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    @Environment(\.dismiss) private var dismiss
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var emailError: String?
    @State private var passwordError: String?
    
    @State private var isSigningIn: Bool = false
    
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
                        Text("Welcome back")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(theme.sub)
                            .tracking(0.5)
                        
                        // Form card
                        VStack(spacing: 16) {
                            // Email
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
                                .onSubmit { emailError = nil }
                                if let error = emailError {
                                    ErrorTextView(message: error)
                                }
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: 4) {
                                FieldLabel(text: "Password")
                                PasswordToggleField(
                                    text: $password,
                                    placeholder: "Your password",
                                    error: passwordError
                                )
                                .onSubmit { signIn() }
                                if let error = passwordError {
                                    ErrorTextView(message: error)
                                }
                            }
                            
                            // Forgot password link
                            HStack {
                                Spacer()
                                NavigationLink(destination: ForgotPasswordView()) {
                                    Text("Forgot password?")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(accent.color)
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
                        
                        // Log In button
                        Button {
                            signIn()
                        } label: {
                            HStack(spacing: 8) {
                                if isSigningIn {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: accent.onAccentText))
                                }
                                Text(isSigningIn ? "Logging in..." : "Log In")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(accent.color)
                            .foregroundColor(accent.onAccentText)
                            .cornerRadius(14)
                        }
                        .disabled(isSigningIn)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Sign up link
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(theme.sub)
                            Button {
                                dismiss()
                            } label: {
                                Text("Sign up")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(accent.color)
                            }
                        }
                        .padding(.top, 20)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Sign In Action
    
    private func signIn() {
        // Clear previous errors
        emailError = nil
        passwordError = nil
        sessionManager.clearError()
        
        // Validate
        var hasError = false
        
        if let error = Validators.validateEmail(email) {
            emailError = error.localizedDescription
            hasError = true
        }
        
        if let error = Validators.validatePassword(password) {
            passwordError = error.localizedDescription
            hasError = true
        }
        
        guard !hasError else { return }
        
        isSigningIn = true
        
        Task {
            await sessionManager.signIn(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password
            )
            await MainActor.run {
                isSigningIn = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(SessionManager())
            .environment(\.rivaTheme, .ink)
            .environment(\.rivaAccent, .gold)
    }
}