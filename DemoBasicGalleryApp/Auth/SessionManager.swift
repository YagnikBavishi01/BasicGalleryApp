//
//  SessionManager.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import Foundation

/// Persists the lightweight "who is logged in" profile so the app can
/// decide which screen to show on launch.
///
/// The actual Google session token lives inside the GoogleSignIn SDK's own
/// keychain storage; this type only tracks the app-facing ``AuthUser``.
final class SessionManager {

    /// The shared session used throughout the app.
    static let shared = SessionManager()

    private let defaults: UserDefaults

    /// Creates a session manager backed by the given `UserDefaults`.
    ///
    /// - Parameter defaults: The store to persist the current user in.
    ///   Defaults to `.standard`.
    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// The currently signed-in user's profile, or `nil` if no one is signed
    /// in. Persisted across launches.
    private(set) var currentUser: AuthUser? {
        get {
            guard let data = defaults.data(forKey: Constants.UserDefaultsKeys.currentUser) else { return nil }
            return try? JSONDecoder().decode(AuthUser.self, from: data)
        }
        set {
            guard let newValue, let data = try? JSONEncoder().encode(newValue) else {
                defaults.removeObject(forKey: Constants.UserDefaultsKeys.currentUser)
                return
            }
            defaults.set(data, forKey: Constants.UserDefaultsKeys.currentUser)
        }
    }

    /// Whether a user is currently signed in.
    var isLoggedIn: Bool {
        currentUser != nil
    }

    /// Marks `user` as the signed-in user and persists their profile.
    ///
    /// - Parameter user: The user who just completed sign-in.
    func startSession(for user: AuthUser) {
        currentUser = user
    }

    /// Clears the persisted session, as if no one were signed in.
    func endSession() {
        currentUser = nil
    }
}
