//
//  ImageAPIServiceProtocol.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import Foundation

/// An abstraction over the remote image API, so ``ImageRepository`` and the
/// rest of the app depend on this protocol rather than a concrete networking
/// implementation (making it easy to substitute a mock in tests).
protocol ImageAPIServiceProtocol {

    /// Fetches one page of image metadata.
    ///
    /// - Parameters:
    ///   - page: The 1-based page number to fetch.
    ///   - limit: The maximum number of images to return in this page.
    /// - Returns: The images for the requested page, or an empty array once
    ///   the end of the collection has been reached.
    /// - Throws: A ``NetworkError`` if the request fails.
    func fetchImages(page: Int, limit: Int) async throws -> [GalleryImage]

    /// Downloads the raw bytes for an image at the given URL.
    ///
    /// - Parameter urlString: The absolute URL of the image to download.
    /// - Returns: The downloaded image data.
    /// - Throws: A ``NetworkError`` if the request fails.
    func downloadImageData(from urlString: String) async throws -> Data
}
