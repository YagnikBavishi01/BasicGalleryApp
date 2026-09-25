//
//  ImageRepositoryProtocol.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import Foundation

/// The single source of truth for gallery images, combining the network API
/// with the Core Data cache so the rest of the app doesn't need to know
/// where a given image actually came from.
protocol ImageRepositoryProtocol {

    /// Loads a page of images.
    ///
    /// Tries the network first and caches the result in the background;
    /// falls back to whatever has already been cached for that page when
    /// the network is unavailable.
    ///
    /// - Parameters:
    ///   - page: The 1-based page number to load.
    ///   - limit: The maximum number of images to return in this page.
    /// - Returns: The images for the requested page, from the network or,
    ///   failing that, the local cache.
    /// - Throws: An error if the network request fails and no cached data
    ///   exists for this page.
    func loadPage(_ page: Int, limit: Int) async throws -> [GalleryImage]

    /// Returns every image already cached on disk, in display order.
    ///
    /// - Returns: All cached images, ordered by their original page/position.
    func loadCachedImages() -> [GalleryImage]

    /// Returns the cached thumbnail bytes for an image, if any.
    ///
    /// - Parameter imageID: The identifier of the image to look up.
    /// - Returns: The cached image data, or `nil` if this image hasn't been
    ///   downloaded and cached yet.
    func cachedImageData(for imageID: String) -> Data?
}
