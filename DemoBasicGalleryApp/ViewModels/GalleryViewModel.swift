//
//  GalleryViewModel.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import Foundation

/// Drives the paginated gallery grid: loads pages from the repository
/// (network-first, Core Data fallback when offline) and exposes a simple,
/// view-friendly state to the view controller.
final class GalleryViewModel {

    /// The observable state of the gallery's loading pipeline.
    enum State {
        /// No load has been requested yet.
        case idle

        /// The first page is being (re)loaded, e.g. on initial load or
        /// pull-to-refresh. The view controller should treat the grid as
        /// empty until ``State/loaded`` arrives.
        case loadingFirstPage

        /// An additional page is being appended as the user scrolls.
        case loadingNextPage

        /// New images have been appended to ``images``; the view controller
        /// should reload its data.
        case loaded

        /// Loading failed; the associated value is a user-facing message.
        case error(String)
    }

    /// The images currently available to display, in display order.
    private(set) var images: [GalleryImage] = []
    private let repository: ImageRepositoryProtocol
    private var currentPage = 1
    private var isLastPageReached = false
    private var isFetching = false

    /// Invoked whenever ``State`` changes, so the view controller can update
    /// its UI accordingly.
    var onStateChange: ((State) -> Void)?

    /// Creates a gallery view model backed by the given repository.
    ///
    /// - Parameter repository: The source of image data. Defaults to
    ///   ``ImageRepository``.
    init(repository: ImageRepositoryProtocol = ImageRepository()) {
        self.repository = repository
    }

    /// The number of images currently available, for
    /// `UICollectionViewDataSource.numberOfItemsInSection`.
    var numberOfImages: Int { images.count }

    /// Returns the image at `index`, if it exists.
    ///
    /// - Parameter index: The index into ``images``.
    /// - Returns: The image at that index, or `nil` if `index` is out of
    ///   bounds.
    func image(at index: Int) -> GalleryImage? {
        guard images.indices.contains(index) else { return nil }
        return images[index]
    }

    /// Returns the cached thumbnail bytes for `image`, if any have been
    /// downloaded and persisted already.
    ///
    /// - Parameter image: The image to look up.
    /// - Returns: The cached image data, or `nil` if not yet cached.
    func cachedImageData(for image: GalleryImage) -> Data? {
        repository.cachedImageData(for: image.id)
    }

    /// Resets pagination and (re)loads the first page.
    ///
    /// Call on initial load and on pull-to-refresh.
    func loadFirstPage() {
        currentPage = 1
        isLastPageReached = false
        images = []
        onStateChange?(.loadingFirstPage)
        fetch(page: currentPage)
    }

    /// Loads the next page if `currentIndex` is near the end of the
    /// currently loaded images and a fetch isn't already in flight.
    ///
    /// Call this from `UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:)`
    /// as the user scrolls.
    ///
    /// - Parameter currentIndex: The index of the item about to be
    ///   displayed.
    func loadNextPageIfNeeded(currentIndex: Int) {
        guard !isFetching, !isLastPageReached else { return }
        let threshold = images.count - 5
        guard currentIndex >= max(threshold, 0) else { return }
        currentPage += 1
        onStateChange?(.loadingNextPage)
        fetch(page: currentPage)
    }

    /// Fetches `page` from the repository and updates ``images`` and
    /// ``State`` accordingly.
    ///
    /// - Parameter page: The page number to fetch.
    private func fetch(page: Int) {
        isFetching = true
        Task {
            do {
                let newImages = try await repository.loadPage(page, limit: Constants.API.pageSize)
                isFetching = false
                if newImages.isEmpty {
                    isLastPageReached = true
                    onStateChange?(.loaded)
                    return
                }
                images.append(contentsOf: newImages)
                onStateChange?(.loaded)
            } catch {
                isFetching = false
                if images.isEmpty {
                    let cached = repository.loadCachedImages()
                    if !cached.isEmpty {
                        images = cached
                        isLastPageReached = true
                        onStateChange?(.loaded)
                        return
                    }
                }
                onStateChange?(.error(error.localizedDescription))
            }
        }
    }
}
