//
//  AuthUser.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import Foundation

/// The signed-in user's profile, as surfaced by ``AuthServiceProtocol`` after
/// a successful Google Sign-In.
///
/// Persisted (via ``SessionManager``) so the app can decide which screen to
/// show on launch without re-authenticating.
struct AuthUser: Codable, Equatable {

    /// The stable, provider-issued identifier for this user.
    let userID: String

    /// The user's display name, shown on the Profile screen.
    let displayName: String

    /// The user's email address.
    let email: String

    /// URL of the user's Google account avatar, if one is set.
    let profileImageURL: String?
}
