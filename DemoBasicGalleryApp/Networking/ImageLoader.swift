//
//  ImageLoader.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import UIKit

/// A small in-memory cache and de-duplicated network fetcher for thumbnails
/// shown in fast-scrolling collection views.
///
/// Without this, every cell reuse would re-download and re-decode its image
/// from scratch, which is what was driving scroll CPU through the roof.
final class ImageLoader {

    /// The shared loader instance used throughout the gallery UI.
    static let shared = ImageLoader()

    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession

    /// Creates a loader backed by the given `URLSession`.
    ///
    /// - Parameter session: The session used to perform downloads. Defaults
    ///   to `.shared`.
    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Returns the already-decoded image for `urlString`, if one is
    /// currently held in the in-memory cache.
    ///
    /// - Parameter urlString: The URL previously passed to
    ///   ``loadImage(from:completion:)``.
    /// - Returns: The cached image, or `nil` if it hasn't been loaded (or
    ///   has been evicted).
    func cachedImage(for urlString: String) -> UIImage? {
        cache.object(forKey: urlString as NSString)
    }

    /// Loads the image at `urlString`, serving it from the in-memory cache
    /// when possible.
    ///
    /// The completion handler is always called on the main thread.
    ///
    /// - Parameters:
    ///   - urlString: The absolute URL of the image to load.
    ///   - completion: Called with the loaded `UIImage`, or `nil` if the URL
    ///     was invalid or the download/decoding failed.
    /// - Returns: The underlying `URLSessionDataTask`, so the caller can
    ///   cancel it (e.g. on cell reuse) if the image is no longer needed.
    ///   Returns `nil` when no network request was needed (cache hit or
    ///   invalid URL).
    @discardableResult
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
        if let cached = cachedImage(for: urlString) {
            completion(cached)
            return nil
        }
        guard let url = URL(string: urlString) else {
            completion(nil)
            return nil
        }
        let task = session.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            self?.cache.setObject(image, forKey: urlString as NSString)
            DispatchQueue.main.async { completion(image) }
        }
        task.resume()
        return task
    }
}
