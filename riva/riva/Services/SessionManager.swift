import Foundation
import SwiftUI
import Supabase

// MARK: - Auth State

enum AuthState {
    case loading
    case authenticated
    case unauthenticated
    case emailVerificationPending(email: String)
}

// MARK: - Session Manager

@MainActor
final class SessionManager: ObservableObject {
    @Published var session: Session?
    @Published var currentUser: RivaUser?
    @Published var authState: AuthState = .loading
    @Published var authError: String?
    
    private let service = SupabaseService.shared
    
    init() {
        Task {
            await restoreSession()
            await observeAuthChanges()
        }
    }
    
    // MARK: - Session Restore
    
    private func restoreSession() async {
        authState = .loading
        guard let existingSession = await service.currentSession else {
            authState = .unauthenticated
            return
        }
        self.session = existingSession
        await fetchCurrentUser()
        
        // If fetchCurrentUser failed (user deleted from server), clear session
        if currentUser == nil {
            self.session = nil
            authState = .unauthenticated
        } else {
            authState = .authenticated
        }
    }
    
    // MARK: - Auth State Observer
    
    private func observeAuthChanges() async {
        let stream = await service.authStateChanges()
        for await (event, newSession) in stream {
            switch event {
            case .initialSession:
                // Already handled by restoreSession
                break
            case .signedIn:
                self.session = newSession
                await fetchCurrentUser()
                authState = .authenticated
            case .signedOut:
                self.session = nil
                self.currentUser = nil
                // If we were in pending verification, go back to unauthenticated
                if case .emailVerificationPending = authState {
                    authState = .unauthenticated
                } else {
                    authState = .unauthenticated
                }
            case .tokenRefreshed:
                self.session = newSession
            case .userUpdated, .userDeleted:
                await fetchCurrentUser()
            case .mfaChallengeVerified:
                break
            case .passwordRecovery:
                break
            }
        }
    }
    
    // MARK: - Fetch Current User
    
    private func fetchCurrentUser() async {
        guard let userId = session?.user.id else { return }
        do {
            currentUser = try await service.fetchUser(id: userId)
        } catch {
            // Profile may not exist yet during sign-up flow, or user was deleted
            currentUser = nil
        }
    }
    
    // MARK: - Auth Actions
    
    func signIn(email: String, password: String) async {
        authError = nil
        do {
            try await service.signIn(email: email, password: password)
            // authStateChanges will handle the rest via .signedIn event
        } catch let error as AuthError {
            authError = error.localizedDescription
        } catch {
            authError = error.localizedDescription
        }
    }
    
    func signUp(email: String, password: String, username: String, name: String) async {
        authError = nil
        do {
            // The Supabase database trigger handle_new_user() automatically
            // creates the public.users row after auth.users insert succeeds.
            let requiresConfirmation = try await service.signUpWithRedirect(
                email: email,
                password: password
            )
            
            if requiresConfirmation {
                // Email confirmation is required — show verification screen
                authState = .emailVerificationPending(email: email)
            }
            // If no confirmation needed, authStateChanges will fire .signedIn
        } catch let error as AuthError {
            authError = error.localizedDescription
        } catch {
            authError = error.localizedDescription
        }
    }
    
    func signOut() async {
        authError = nil
        do {
            try await service.signOut()
            // authStateChanges will handle the rest via .signedOut event
        } catch {
            authError = error.localizedDescription
        }
    }
    
    func resetPassword(email: String) async {
        authError = nil
        do {
            try await service.resetPasswordForEmail(email)
        } catch {
            authError = error.localizedDescription
        }
    }
    
    func checkUsernameAvailability(_ username: String) async throws -> Bool {
        return try await service.checkUsernameAvailability(username)
    }
    
    // MARK: - Deep Link Verification
    
    /// Called when the app receives a deep link from email verification.
    func handleVerificationURL(_ url: URL) {
        guard url.scheme == "riva",
              url.host == "auth",
              url.path == "/callback" else {
            return
        }
        
        Task {
            do {
                try await service.exchangeAuthCode(from: url)
                // authStateChanges will fire .signedIn → session + user fetched
            } catch {
                authError = error.localizedDescription
            }
        }
    }
    
    func clearError() {
        authError = nil
    }
}
