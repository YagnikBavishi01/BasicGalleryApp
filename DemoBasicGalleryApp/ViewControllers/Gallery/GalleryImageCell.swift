//
//  GalleryImageCell.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//
//  Prototype cell defined in Main.storyboard (Gallery scene).
//

import UIKit

/// A single grid cell showing an image thumbnail and its author's name.
///
/// Prefers the Core Data–cached thumbnail bytes when available (so already
/// downloaded images render instantly and work offline), and otherwise
/// downloads a downscaled render via ``ImageLoader``.
final class GalleryImageCell: UICollectionViewCell {

    /// The identifier this cell is registered under in `Main.storyboard`.
    static let reuseIdentifier = "GalleryImageCell"

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var authorLabel: UILabel!

    private var currentImageID: String?
    private var loadTask: URLSessionDataTask?

    /// Configures the cell to display `image`.
    ///
    /// Cancels any in-flight download from a previous configuration (e.g.
    /// from cell reuse during fast scrolling) before starting a new one.
    ///
    /// - Parameters:
    ///   - image: The image metadata to display.
    ///   - cachedData: Previously cached thumbnail bytes for this image, if
    ///     any (see `GalleryViewModel.cachedImageData(for:)`). When present,
    ///     this is used directly instead of hitting the network.
    func configure(with image: GalleryImage, cachedData: Data?) {
        loadTask?.cancel()
        currentImageID = image.id
        authorLabel.text = image.author
        imageView.image = nil

        if let cachedData, let uiImage = UIImage(data: cachedData) {
            imageView.image = uiImage
            return
        }

        let thumbnailURL = image.thumbnailURL(width: Constants.API.thumbnailWidth, height: Constants.API.thumbnailHeight)
        let requestedID = image.id
        loadTask = ImageLoader.shared.loadImage(from: thumbnailURL) { [weak self] uiImage in
            guard let self, self.currentImageID == requestedID else { return }
            self.imageView.image = uiImage
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        loadTask?.cancel()
        loadTask = nil
        imageView.image = nil
        currentImageID = nil
    }
}
