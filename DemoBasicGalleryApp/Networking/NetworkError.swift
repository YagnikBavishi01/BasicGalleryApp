//
//  NetworkError.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import Foundation

/// Errors surfaced by ``ImageAPIServiceProtocol`` implementations.
///
/// Conforms to `LocalizedError` so its ``errorDescription`` can be shown
/// directly to the user (e.g. in an alert) without further mapping.
enum NetworkError: LocalizedError {

    /// The request could not be constructed into a valid `URL`.
    case invalidURL

    /// The server responded, but not with a successful HTTP status code.
    case invalidResponse

    /// The underlying `URLSession` task failed (e.g. timed out, host
    /// unreachable). The associated value is the original error.
    case requestFailed(Error)

    /// The response body could not be decoded into the expected model type.
    /// The associated value is the original decoding error.
    case decodingFailed(Error)

    /// The device has no internet connection.
    case offline

    /// A user-facing message describing the failure.
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL was invalid."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .requestFailed(let error):
            return error.localizedDescription
        case .decodingFailed:
            return "Failed to decode the server response."
        case .offline:
            return "No internet connection."
        }
    }
}
