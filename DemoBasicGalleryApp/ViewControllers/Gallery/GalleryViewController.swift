//
//  GalleryViewController.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//
//  Paginated grid of online wallpapers. Each image is cached to Core
//  Data as it loads, so previously viewed pages remain browsable
//  offline (see ImageRepository). Layout lives in Main.storyboard.
//

import UIKit

/// Shows a paginated grid of wallpapers, driven by ``GalleryViewModel``.
///
/// Supports pull-to-refresh, infinite scroll (see
/// `GalleryViewModel.loadNextPageIfNeeded(currentIndex:)`), and pushes
/// ``ImageDetailViewController`` on selection.
final class GalleryViewController: UIViewController {

    /// The identifier of this view controller's scene in `Main.storyboard`.
    static let storyboardIdentifier = "GalleryViewController"

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var emptyStateLabel: UILabel!

    /// The view model driving this screen. Must be set by the presenter
    /// (see ``AppCoordinator``) before the view loads.
    var viewModel: GalleryViewModel!

    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gallery"
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        bindViewModel()
        viewModel.loadFirstPage()
    }

    /// Subscribes to view model state changes and updates the UI
    /// accordingly.
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            DispatchQueue.main.async {
                switch state {
                case .idle, .loadingNextPage:
                    break
                case .loadingFirstPage:
                    self.emptyStateLabel.isHidden = true
                    // The view model already cleared its images synchronously;
                    // reload now so the collection view's item count can never
                    // drift out of sync with the data source (stale prefetch
                    // requests for now-invalid index paths is what crashes).
                    self.collectionView.reloadData()
                case .loaded:
                    self.refreshControl.endRefreshing()
                    self.collectionView.reloadData()
                    self.emptyStateLabel.isHidden = self.viewModel.numberOfImages > 0
                case .error(let message):
                    self.refreshControl.endRefreshing()
                    if self.viewModel.numberOfImages == 0 {
                        self.emptyStateLabel.isHidden = false
                    } else {
                        self.presentError(message)
                    }
                }
            }
        }
    }

    /// Presents an alert describing a load failure.
    ///
    /// - Parameter message: The user-facing error message to display.
    private func presentError(_ message: String) {
        let alert = UIAlertController(title: "Something went wrong", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    /// Handles the user pulling down to refresh; reloads the first page.
    @objc private func pullToRefresh() {
        viewModel.loadFirstPage()
    }
}

extension GalleryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfImages
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Always dequeue through the registered identifier so we never hand
        // UIKit a bare UICollectionViewCell (that alone crashes with "cell
        // without a reuseIdentifier"). If the model briefly disagrees with
        // the collection view about the item count, just return a blank cell
        // for that index instead of crashing.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryImageCell.reuseIdentifier, for: indexPath) as! GalleryImageCell
        if let image = viewModel.image(at: indexPath.item) {
            cell.configure(with: image, cachedData: viewModel.cachedImageData(for: image))
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.loadNextPageIfNeeded(currentIndex: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 8 + 12 + 12
        let width = (collectionView.bounds.width - spacing) / 2
        return CGSize(width: width, height: width * 1.2)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let image = viewModel.image(at: indexPath.item) else { return }
        let detailVC = ImageDetailViewController.instantiate(image: image, cachedData: viewModel.cachedImageData(for: image))
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
