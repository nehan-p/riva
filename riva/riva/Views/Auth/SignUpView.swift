import SwiftUI

// MARK: - Sign Up View

struct SignUpView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""
    
    @State private var nameError: String?
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var usernameError: String?
    
    @State private var isSigningUp: Bool = false
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, email, username, password
    }
    
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
                    
                    // Step indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(isAnyFieldFilled ? accent.color : theme.line)
                            .frame(width: 8, height: 8)
                        Circle()
                            .fill(theme.line)
                            .frame(width: 6, height: 6)
                    }
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
                        Text("Create your account")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(theme.sub)
                            .tracking(0.5)
                        
                        // Form card
                        VStack(spacing: 16) {
                            // Name
                            VStack(alignment: .leading, spacing: 4) {
                                FieldLabel(text: "Display Name")
                                RoundedIconField(
                                    text: $name,
                                    placeholder: "Your full name",
                                    icon: "person.fill",
                                    error: nameError,
                                    textContentType: .name
                                )
                                .focused($focusedField, equals: .name)
                                .onSubmit { focusedField = .email }
                                .onChange(of: name) { _, _ in nameError = nil }
                                if let error = nameError {
                                    ErrorTextView(message: error)
                                }
                            }
                            
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
                                .focused($focusedField, equals: .email)
                                .onSubmit { focusedField = .username }
                                .onChange(of: email) { _, _ in emailError = nil }
                                if let error = emailError {
                                    ErrorTextView(message: error)
                                }
                            }
                            
                            // Username
                            VStack(alignment: .leading, spacing: 4) {
                                FieldLabel(text: "Username")
                                HStack(spacing: 0) {
                                    Text("@")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(theme.muted)
                                        .padding(.leading, 14)
                                    TextField("yourhandle", text: $username)
                                        .focused($focusedField, equals: .username)
                                        .keyboardType(.asciiCapable)
                                        .disableAutocorrection(true)
                                        .foregroundColor(theme.text)
                                        .font(.system(size: 16, weight: .regular))
                                        .padding(.vertical, 14)
                                        .padding(.trailing, 14)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(theme.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    usernameError != nil ? Color.red
                                                        : (focusedField == .username ? accent.color : theme.line),
                                                    lineWidth: focusedField == .username ? 1.5 : 1
                                                )
                                        )
                                )
                                .onChange(of: username) { _, _ in usernameError = nil }
                                .onSubmit { focusedField = .password }
                                if let error = usernameError {
                                    ErrorTextView(message: error)
                                }
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: 4) {
                                FieldLabel(text: "Password")
                                PasswordToggleField(
                                    text: $password,
                                    placeholder: "Min. 8 characters",
                                    error: passwordError
                                )
                                .focused($focusedField, equals: .password)
                                .onSubmit { signUp() }
                                if let error = passwordError {
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
                        
                        // Sign Up button
                        Button {
                            signUp()
                        } label: {
                            HStack(spacing: 8) {
                                if isSigningUp {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: accent.onAccentText))
                                }
                                Text(isSigningUp ? "Creating account..." : "Create Account")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(accent.color)
                            .foregroundColor(accent.onAccentText)
                            .cornerRadius(14)
                        }
                        .disabled(isSigningUp)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Log in link
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(theme.sub)
                            Button {
                                dismiss()
                            } label: {
                                Text("Log in")
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
    
    // MARK: - Helpers
    
    private var isAnyFieldFilled: Bool {
        !name.isEmpty || !email.isEmpty || !username.isEmpty || !password.isEmpty
    }
    
    // MARK: - Sign Up Action
    
    private func signUp() {
        nameError = nil
        emailError = nil
        passwordError = nil
        usernameError = nil
        sessionManager.clearError()
        
        var hasError = false
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if trimmedName.isEmpty {
            nameError = "Display name is required."
            hasError = true
        }
        if let error = Validators.validateEmail(email) {
            emailError = error.localizedDescription
            hasError = true
        }
        if let error = Validators.validateUsernameFormat(username) {
            usernameError = error.localizedDescription
            hasError = true
        }
        if let error = Validators.validatePassword(password) {
            passwordError = error.localizedDescription
            hasError = true
        }
        
        guard !hasError else { return }
        
        isSigningUp = true
        
        Task {
            do {
                let isAvailable = try await sessionManager.checkUsernameAvailability(username)
                if !isAvailable {
                    await MainActor.run {
                        usernameError = ValidationError.usernameUnavailable.localizedDescription
                        isSigningUp = false
                    }
                    return
                }
                await sessionManager.signUp(
                    email: email.trimmingCharacters(in: .whitespaces),
                    password: password,
                    username: username.trimmingCharacters(in: .whitespaces),
                    name: trimmedName
                )
                await MainActor.run {
                    isSigningUp = false
                }
            } catch {
                await MainActor.run {
                    isSigningUp = false
                    sessionManager.authError = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(SessionManager())
            .environment(\.rivaTheme, .ink)
            .environment(\.rivaAccent, .gold)
    }
}