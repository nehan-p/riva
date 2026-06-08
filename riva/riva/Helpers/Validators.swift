import Foundation

// MARK: - Validation Errors

enum ValidationError: LocalizedError, Equatable {
    case emailInvalid
    case passwordTooShort(minLength: Int)
    case usernameInvalidFormat
    case usernameTooShort(minLength: Int)
    case usernameTooLong(maxLength: Int)
    case usernameUnavailable
    
    var errorDescription: String? {
        switch self {
        case .emailInvalid:
            return "Please enter a valid email address."
        case .passwordTooShort(let minLength):
            return "Password must be at least \(minLength) characters."
        case .usernameInvalidFormat:
            return "Username can only contain letters, numbers, and underscores."
        case .usernameTooShort(let minLength):
            return "Username must be at least \(minLength) characters."
        case .usernameTooLong(let maxLength):
            return "Username must be \(maxLength) characters or fewer."
        case .usernameUnavailable:
            return "That username is already taken."
        }
    }
}

// MARK: - Validators

enum Validators {
    private static let usernameRegex = try! NSRegularExpression(
        pattern: "^[a-zA-Z0-9_]+$"
    )
    
    static func validateEmail(_ email: String) -> ValidationError? {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty,
              trimmed.contains("@"),
              trimmed.contains("."),
              trimmed.count >= 5 else {
            return .emailInvalid
        }
        return nil
    }
    
    static func validatePassword(_ password: String, minLength: Int = 8) -> ValidationError? {
        guard password.count >= minLength else {
            return .passwordTooShort(minLength: minLength)
        }
        return nil
    }
    
    static func validateUsernameFormat(_ username: String, minLength: Int = 3, maxLength: Int = 20) -> ValidationError? {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= minLength else {
            return .usernameTooShort(minLength: minLength)
        }
        guard trimmed.count <= maxLength else {
            return .usernameTooLong(maxLength: maxLength)
        }
        let range = NSRange(location: 0, length: trimmed.utf16.count)
        guard usernameRegex.firstMatch(in: trimmed, options: [], range: range) != nil else {
            return .usernameInvalidFormat
        }
        return nil
    }
}