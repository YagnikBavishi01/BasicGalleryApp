//
//  GalleryImage.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import Foundation

/// A single wallpaper/photo entry as returned by the Lorem Picsum `list` API.
///
/// This is the app's one domain model for a gallery image — it can be
/// decoded directly from the network response, or reconstructed from a
/// cached ``CachedImage`` Core Data record so the gallery view model can
/// treat online and offline data identically.
struct GalleryImage: Decodable, Equatable {

    /// Picsum's stable identifier for the image, used both as the Core Data
    /// primary key and to build resized thumbnail URLs.
    let id: String

    /// The photographer/author credit shown under the thumbnail.
    let author: String

    /// The width, in pixels, of the original full-resolution image.
    let width: Int

    /// The height, in pixels, of the original full-resolution image.
    let height: Int

    /// The Picsum web page URL for this image (not used for display).
    let url: String

    /// Direct URL to the full-resolution original image file.
    ///
    /// This is intentionally *not* used for grid thumbnails — see
    /// ``thumbnailURL(width:height:)`` — because the original can be several
    /// megapixels and multiple megabytes.
    let downloadURL: String

    /// Maps Picsum's snake_case JSON keys onto this struct's properties.
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case width
        case height
        case url
        case downloadURL = "download_url"
    }

    /// Builds a URL for a downscaled render of this image via Picsum's
    /// resize endpoint.
    ///
    /// Use this for grid thumbnails instead of ``downloadURL``, which points
    /// at the full-resolution original. Requesting an appropriately sized
    /// image keeps network transfer, decoding cost, and on-disk cache size
    /// all proportional to what's actually rendered on screen.
    ///
    /// - Parameters:
    ///   - width: The desired image width, in pixels.
    ///   - height: The desired image height, in pixels.
    /// - Returns: A URL string for a resized copy of this image.
    func thumbnailURL(width: Int, height: Int) -> String {
        "https://picsum.photos/id/\(id)/\(width)/\(height)"
    }
}

extension GalleryImage {

    /// Reconstructs a `GalleryImage` from a Core Data ``CachedImage`` record,
    /// so previously downloaded pages can be displayed while offline.
    ///
    /// Marked `nonisolated` because this only reads plain scalar/`String`
    /// properties off an already-fetched managed object; without it, the
    /// module's default actor isolation (`SWIFT_DEFAULT_ACTOR_ISOLATION =
    /// MainActor`) would infer this initializer as `@MainActor`, which
    /// conflicts with ``ImageRepository``'s protocol-required methods
    /// (themselves `nonisolated`, since `ImageRepositoryProtocol` declares no
    /// isolation) calling it synchronously.
    ///
    /// - Parameter cachedImage: The Core Data record to read from.
    nonisolated init(cachedImage: CachedImage) {
        self.id = cachedImage.id ?? UUID().uuidString
        self.author = cachedImage.author ?? ""
        self.width = Int(cachedImage.width)
        self.height = Int(cachedImage.height)
        self.url = cachedImage.downloadURL ?? ""
        self.downloadURL = cachedImage.downloadURL ?? ""
    }
}
