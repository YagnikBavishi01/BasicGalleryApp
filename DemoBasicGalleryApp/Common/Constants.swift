//
//  Constants.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import Foundation

/// Namespace for app-wide constants.
enum Constants {

    /// Constants related to the Lorem Picsum image API.
    enum API {
        /// Base URL for the Lorem Picsum v2 API.
        static let baseURL = "https://picsum.photos/v2"

        /// Number of images requested per gallery page.
        static let pageSize = 20

        /// Grid cells are small, so we ask Picsum for an already-downscaled
        /// image (via its `/id/{id}/{w}/{h}` resize endpoint) instead of the
        /// multi-megapixel original — that keeps network, decode, and Core
        /// Data cache size all proportional to what's actually on screen.
        static let thumbnailWidth = 300

        /// See ``thumbnailWidth``.
        static let thumbnailHeight = 360
    }

    /// Keys used to persist values in `UserDefaults`.
    enum UserDefaultsKeys {
        /// Key under which the signed-in user's encoded ``AuthUser`` is
        /// stored (see ``SessionManager``).
        static let currentUser = "com.demobasicgalleryapp.currentUser"

        /// Reserved for a simple logged-in flag; not currently used since
        /// ``SessionManager/isLoggedIn`` derives from ``currentUser``.
        static let isLoggedIn = "com.demobasicgalleryapp.isLoggedIn"
    }

    /// OAuth client ID from Google Cloud Console (see
    /// `GoogleService-Info.plist`).
    ///
    /// Also set in Info.plist as `GIDClientID`, with the reversed-client-id
    /// URL scheme registered under `CFBundleURLTypes`.
    static let googleClientID = "804632926300-aphjrncdn4gcaqfli3v1ic92to1huhkf.apps.googleusercontent.com"
}
