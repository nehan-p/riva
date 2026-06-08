import SwiftUI

// MARK: - Shared Auth UI Components
// Used by LoginView, SignUpView, and ForgotPasswordView.

// MARK: - Rounded Icon Text Field

struct RoundedIconField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    let error: String?
    var keyboard: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil

    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(isFocused ? accent.color : theme.muted)
                .frame(width: 18)
            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .textContentType(textContentType)
                .disableAutocorrection(true)
                .foregroundColor(theme.text)
                .font(.system(size: 16, weight: .regular))
                .focused($isFocused)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            error != nil ? Color.red : (isFocused ? accent.color : theme.line),
                            lineWidth: isFocused ? 1.5 : 1
                        )
                )
        )
    }
}

// MARK: - Password Field (with visibility toggle)

struct PasswordToggleField: View {
    @Binding var text: String
    let placeholder: String
    let error: String?

    @State private var isVisible = false
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.fill")
                .font(.system(size: 14))
                .foregroundColor(isFocused ? accent.color : theme.muted)
                .frame(width: 18)
            if isVisible {
                TextField(placeholder, text: $text)
                    .foregroundColor(theme.text)
                    .font(.system(size: 16, weight: .regular))
                    .focused($isFocused)
            } else {
                SecureField(placeholder, text: $text)
                    .foregroundColor(theme.text)
                    .font(.system(size: 16, weight: .regular))
                    .focused($isFocused)
            }
            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .font(.system(size: 14))
                    .foregroundColor(theme.muted)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            error != nil ? Color.red : (isFocused ? accent.color : theme.line),
                            lineWidth: isFocused ? 1.5 : 1
                        )
                )
        )
    }
}

// MARK: - Error Text

struct ErrorTextView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 11, weight: .regular))
            .foregroundColor(.red)
            .padding(.leading, 8)
    }
}

// MARK: - Field Label

struct FieldLabel: View {
    let text: String
    @Environment(\.rivaTheme) private var theme

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(theme.sub)
            .tracking(1)
            .padding(.leading, 4)
    }
}

// MARK: - Supabase Error Banner

struct AuthErrorBanner: View {
    let message: String?

    var body: some View {
        if let error = message {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                Text(error)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.red)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .transition(.opacity)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        FieldLabel(text: "Email")
        RoundedIconField(
            text: .constant(""),
            placeholder: "you@example.com",
            icon: "envelope.fill",
            error: nil,
            keyboard: .emailAddress,
            textContentType: .emailAddress
        )

        FieldLabel(text: "Password")
        PasswordToggleField(
            text: .constant(""),
            placeholder: "Min. 8 characters",
            error: "Password too short"
        )

        ErrorTextView(message: "This is an error message.")
        AuthErrorBanner(message: "Invalid credentials")
    }
    .padding(24)
    .background(Color.riva.inkBg)
    .environment(\.rivaTheme, .ink)
    .environment(\.rivaAccent, .gold)
}