//
//  GoogleAuthService.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import UIKit
import GoogleSignIn

/// Thin wrapper around the `GoogleSignIn` SDK so the rest of the app only
/// ever depends on ``AuthServiceProtocol``.
///
/// Requires the GoogleSignIn-iOS Swift package (added via SPM) plus
/// `GIDClientID` and the reversed-client-id URL scheme configured in
/// Info.plist — see ``Constants/googleClientID``.
final class GoogleAuthService: AuthServiceProtocol {

    /// Presents Google's sign-in sheet from `viewController` and maps the
    /// result onto ``AuthUser``.
    ///
    /// - Parameter viewController: The view controller to present from.
    /// - Returns: The signed-in user's profile.
    /// - Throws: An error if sign-in fails, is cancelled, or the resulting
    ///   Google account is missing a user identifier.
    func signIn(presenting viewController: UIViewController) async throws -> AuthUser {
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        return try makeAuthUser(from: result.user)
    }

    /// Signs out of the current Google session.
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }

    /// Attempts to silently restore a previous Google sign-in, without
    /// presenting any UI.
    ///
    /// - Returns: The previously signed-in user's profile, or `nil` if there
    ///   is no valid existing session.
    func restorePreviousSignIn() async -> AuthUser? {
        await withCheckedContinuation { continuation in
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, _ in
                guard let user, let authUser = try? self.makeAuthUser(from: user) else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: authUser)
            }
        }
    }

    // MARK: - Private

    /// Maps a `GIDGoogleUser` onto the app's own ``AuthUser`` model.
    ///
    /// - Parameter user: The Google user returned by the SDK.
    /// - Returns: The mapped ``AuthUser``.
    /// - Throws: ``NetworkError/invalidResponse`` if the Google account has
    ///   no user identifier.
    private func makeAuthUser(from user: GIDGoogleUser) throws -> AuthUser {
        guard let userID = user.userID else {
            throw NetworkError.invalidResponse
        }
        return AuthUser(
            userID: userID,
            displayName: user.profile?.name ?? "Guest",
            email: user.profile?.email ?? "",
            profileImageURL: user.profile?.imageURL(withDimension: 200)?.absoluteString
        )
    }
}
