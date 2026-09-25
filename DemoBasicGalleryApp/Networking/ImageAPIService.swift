//
//  ImageAPIService.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import Foundation

/// Default ``ImageAPIServiceProtocol`` implementation that talks to the
/// Lorem Picsum "list" endpoint, a free open API that returns paginated
/// wallpaper/photo metadata without requiring an API key:
/// `https://picsum.photos/v2/list?page={page}&limit={limit}`.
final class ImageAPIService: ImageAPIServiceProtocol {

    private let session: URLSession

    /// Creates a service backed by the given `URLSession`.
    ///
    /// - Parameter session: The session used to perform requests. Defaults
    ///   to `.shared`; pass a custom session (e.g. one with a mock protocol)
    ///   in tests.
    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Fetches one page of image metadata from Picsum's `/list` endpoint.
    ///
    /// - Parameters:
    ///   - page: The 1-based page number to fetch.
    ///   - limit: The maximum number of images to return in this page.
    /// - Returns: The decoded images for the requested page.
    /// - Throws: ``NetworkError/invalidURL`` if the request URL couldn't be
    ///   built, ``NetworkError/invalidResponse`` for a non-2xx status code,
    ///   ``NetworkError/decodingFailed(_:)`` if the body doesn't match
    ///   ``GalleryImage``, ``NetworkError/offline`` when there's no internet
    ///   connection, or ``NetworkError/requestFailed(_:)`` for any other
    ///   transport failure.
    func fetchImages(page: Int, limit: Int) async throws -> [GalleryImage] {
        guard var components = URLComponents(string: "\(Constants.API.baseURL)/list") else {
            throw NetworkError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        guard let url = components.url else { throw NetworkError.invalidURL }

        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw NetworkError.invalidResponse
            }
            do {
                return try JSONDecoder().decode([GalleryImage].self, from: data)
            } catch {
                throw NetworkError.decodingFailed(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            if (error as NSError).domain == NSURLErrorDomain,
               (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.offline
            }
            throw NetworkError.requestFailed(error)
        }
    }

    /// Downloads the raw bytes for an image at the given URL.
    ///
    /// - Parameter urlString: The absolute URL of the image to download.
    /// - Returns: The downloaded image data.
    /// - Throws: ``NetworkError/invalidURL`` if `urlString` isn't a valid
    ///   URL, ``NetworkError/invalidResponse`` for a non-2xx status code, or
    ///   ``NetworkError/requestFailed(_:)`` for any other transport failure.
    func downloadImageData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw NetworkError.invalidResponse
            }
            return data
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}
