//
//  ImageRepository.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import CoreData
import UIKit

/// Default ``ImageRepositoryProtocol`` implementation: fetches image
/// metadata from the network, persists downscaled thumbnails to Core Data
/// (including the raw bytes so they can be viewed offline), and falls back
/// to the cache when the network call fails.
final class ImageRepository: ImageRepositoryProtocol {

    private let apiService: ImageAPIServiceProtocol
    private let coreDataStack: CoreDataStack

    /// Creates a repository backed by the given dependencies.
    ///
    /// - Parameters:
    ///   - apiService: The service used to fetch image metadata and bytes.
    ///     Defaults to ``ImageAPIService``.
    ///   - coreDataStack: The stack used to read/write the local cache.
    ///     Defaults to ``CoreDataStack/shared``.
    init(apiService: ImageAPIServiceProtocol = ImageAPIService(),
         coreDataStack: CoreDataStack = .shared) {
        self.apiService = apiService
        self.coreDataStack = coreDataStack
    }

    /// Loads a page of images from the network, caching thumbnails to Core
    /// Data in the background.
    ///
    /// - Parameters:
    ///   - page: The 1-based page number to load.
    ///   - limit: The maximum number of images to return in this page.
    /// - Returns: The images for the requested page. Returned immediately
    ///   after the metadata request succeeds — the actual thumbnail bytes
    ///   are downloaded and persisted afterward, so this call isn't blocked
    ///   waiting for every image in the page to finish downloading.
    /// - Throws: The underlying network error if the request fails and
    ///   nothing has been cached for this page yet.
    func loadPage(_ page: Int, limit: Int) async throws -> [GalleryImage] {
        do {
            let images = try await apiService.fetchImages(page: page, limit: limit)
            // Persist thumbnails in the background so the caller (and the UI)
            // isn't blocked waiting for every image in the page to download.
            Task.detached(priority: .utility) { [weak self] in
                await self?.cache(images: images, page: page)
            }
            return images
        } catch {
            let cached = cachedImages(forPage: page)
            if !cached.isEmpty {
                return cached
            }
            throw error
        }
    }

    /// Returns every image already cached on disk, in display order.
    ///
    /// - Returns: All cached images, ordered by ``CachedImage/sortIndex``.
    func loadCachedImages() -> [GalleryImage] {
        let request = CachedImage.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "sortIndex", ascending: true)]
        let results = (try? coreDataStack.viewContext.fetch(request)) ?? []
        return results.map(GalleryImage.init(cachedImage:))
    }

    /// Returns the cached thumbnail bytes for an image, if any.
    ///
    /// - Parameter imageID: The identifier of the image to look up.
    /// - Returns: The cached image data, or `nil` if this image hasn't been
    ///   downloaded and cached yet.
    func cachedImageData(for imageID: String) -> Data? {
        let request = CachedImage.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", imageID)
        request.fetchLimit = 1
        return (try? coreDataStack.viewContext.fetch(request))?.first?.imageData
    }

    // MARK: - Private

    /// Returns whatever has already been cached for a specific page, in
    /// display order.
    ///
    /// - Parameter page: The page number to look up.
    /// - Returns: The cached images for that page, or an empty array if none
    ///   have been cached.
    private func cachedImages(forPage page: Int) -> [GalleryImage] {
        let request = CachedImage.fetchRequest()
        request.predicate = NSPredicate(format: "pageIndex == %d", page)
        request.sortDescriptors = [NSSortDescriptor(key: "sortIndex", ascending: true)]
        let results = (try? coreDataStack.viewContext.fetch(request)) ?? []
        return results.map(GalleryImage.init(cachedImage:))
    }

    /// Downloads a thumbnail-sized render of each image and persists it (and
    /// its metadata) to Core Data.
    ///
    /// - Parameters:
    ///   - images: The images to cache.
    ///   - page: The page these images belong to, recorded on each record
    ///     for later lookup via ``cachedImages(forPage:)``.
    private func cache(images: [GalleryImage], page: Int) async {
        let thumbnails: [(GalleryImage, Data?)] = await withTaskGroup(of: (GalleryImage, Data?).self) { group in
            for image in images {
                group.addTask { [apiService] in
                    let thumbnailURL = await image.thumbnailURL(width: Constants.API.thumbnailWidth, height: Constants.API.thumbnailHeight)
                    let data = try? await apiService.downloadImageData(from: thumbnailURL)
                    return (image, data)
                }
            }
            var results: [(GalleryImage, Data?)] = []
            for await result in group {
                results.append(result)
            }
            return results
        }

        let context = coreDataStack.newBackgroundContext()
        await context.perform {
            for (index, entry) in thumbnails.enumerated() {
                let (image, data) = entry
                let request = CachedImage.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", image.id)
                request.fetchLimit = 1
                let record = (try? context.fetch(request))?.first ?? CachedImage(context: context)
                record.id = image.id
                record.author = image.author
                record.downloadURL = image.downloadURL
                record.width = Int32(image.width)
                record.height = Int32(image.height)
                record.pageIndex = Int32(page)
                record.sortIndex = Int32(page * Constants.API.pageSize + index)
                record.createdAt = Date()
                if let data {
                    record.imageData = data
                }
            }
            self.coreDataStack.saveContext(context)
        }
    }
}
