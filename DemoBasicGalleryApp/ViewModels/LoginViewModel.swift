//
//  LoginViewModel.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import UIKit

/// Drives the Login screen: presents Google Sign-In and reports back the
/// result as a simple, view-friendly ``State``.
final class LoginViewModel {

    /// The observable state of the sign-in flow.
    enum State {
        /// No sign-in attempt in progress.
        case idle

        /// A sign-in attempt is in progress; the UI should show a spinner
        /// and disable the sign-in button.
        case loading

        /// Sign-in completed successfully for the given user.
        case success(AuthUser)

        /// Sign-in failed; the associated value is a user-facing message.
        case failure(String)
    }

    private let authService: AuthServiceProtocol
    private let sessionManager: SessionManager

    /// Invoked whenever ``State`` changes, so the view controller can update
    /// its UI accordingly.
    var onStateChange: ((State) -> Void)?

    /// Creates a login view model backed by the given dependencies.
    ///
    /// - Parameters:
    ///   - authService: The service used to perform sign-in. Defaults to
    ///     ``GoogleAuthService``.
    ///   - sessionManager: Where the signed-in user's session is persisted.
    ///     Defaults to ``SessionManager/shared``.
    init(authService: AuthServiceProtocol = GoogleAuthService(),
         sessionManager: SessionManager = .shared) {
        self.authService = authService
        self.sessionManager = sessionManager
    }

    /// Starts the Google Sign-In flow, presenting it from `viewController`.
    ///
    /// Reports ``State/loading``, then either ``State/success(_:)`` or
    /// ``State/failure(_:)`` via ``onStateChange``.
    ///
    /// - Parameter viewController: The view controller to present the
    ///   sign-in sheet from.
    func signIn(presenting viewController: UIViewController) {
        onStateChange?(.loading)
        Task {
            do {
                let user = try await authService.signIn(presenting: viewController)
                sessionManager.startSession(for: user)
                onStateChange?(.success(user))
            } catch {
                onStateChange?(.failure(error.localizedDescription))
            }
        }
    }
}
