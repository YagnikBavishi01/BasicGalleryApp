//
//  ProfileViewModel.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import Foundation

/// Drives the Profile screen: surfaces the signed-in user's details and
/// performs logout.
final class ProfileViewModel {

    private let authService: AuthServiceProtocol
    private let sessionManager: SessionManager

    /// Invoked after logout has completed, so the view controller can
    /// return to the login flow.
    var onLogout: (() -> Void)?

    /// Creates a profile view model backed by the given dependencies.
    ///
    /// - Parameters:
    ///   - authService: The service used to sign out. Defaults to
    ///     ``GoogleAuthService``.
    ///   - sessionManager: Where the current session is read from and
    ///     cleared. Defaults to ``SessionManager/shared``.
    init(authService: AuthServiceProtocol = GoogleAuthService(),
         sessionManager: SessionManager = .shared) {
        self.authService = authService
        self.sessionManager = sessionManager
    }

    /// The currently signed-in user's profile, if any.
    var user: AuthUser? {
        sessionManager.currentUser
    }

    /// Signs the user out and clears the local session, then calls
    /// ``onLogout``.
    func logout() {
        authService.signOut()
        sessionManager.endSession()
        onLogout?()
    }
}
