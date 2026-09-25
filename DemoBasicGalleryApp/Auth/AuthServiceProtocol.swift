//
//  AuthServiceProtocol.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import UIKit

/// An abstraction over the sign-in provider, so the rest of the app depends
/// on this protocol rather than the concrete `GoogleSignIn` SDK (making it
/// easy to substitute a mock in tests or swap providers later).
protocol AuthServiceProtocol {

    /// Presents the sign-in UI and completes when the user finishes (or
    /// cancels) authentication.
    ///
    /// - Parameter viewController: The view controller to present the
    ///   sign-in flow from.
    /// - Returns: The signed-in user's profile.
    /// - Throws: An error if sign-in fails or is cancelled.
    func signIn(presenting viewController: UIViewController) async throws -> AuthUser

    /// Signs the current user out and clears the provider's local session.
    func signOut()

    /// Attempts to silently restore a previous sign-in (e.g. on app launch),
    /// without presenting any UI.
    ///
    /// - Returns: The previously signed-in user's profile, or `nil` if there
    ///   is no valid existing session.
    func restorePreviousSignIn() async -> AuthUser?
}
