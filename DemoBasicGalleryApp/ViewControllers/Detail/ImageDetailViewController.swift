//
//  ImageDetailViewController.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import UIKit

/// Full-screen preview of a single wallpaper.
///
/// Prefers the Core Data–cached bytes (so it works offline for previously
/// loaded images) and falls back to a network fetch of the full-resolution
/// original. Layout lives in `Main.storyboard`
/// ("ImageDetailViewController" scene).
final class ImageDetailViewController: UIViewController {

    /// The identifier of this view controller's scene in `Main.storyboard`.
    static let storyboardIdentifier = "ImageDetailViewController"

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private var image: GalleryImage!
    private var cachedData: Data?

    /// Creates and configures an instance from `Main.storyboard`.
    ///
    /// - Parameters:
    ///   - image: The image to display.
    ///   - cachedData: Previously cached bytes for this image, if any. When
    ///     present, shown immediately instead of hitting the network.
    /// - Returns: A configured, ready-to-push `ImageDetailViewController`.
    static func instantiate(image: GalleryImage, cachedData: Data?) -> ImageDetailViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! ImageDetailViewController
        controller.image = image
        controller.cachedData = cachedData
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = image.author
        loadImage()
    }

    /// Displays the cached image if available, otherwise downloads the
    /// full-resolution original.
    private func loadImage() {
        if let cachedData, let uiImage = UIImage(data: cachedData) {
            imageView.image = uiImage
            return
        }
        activityIndicator.startAnimating()
        guard let url = URL(string: image.downloadURL) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                guard let data, let uiImage = UIImage(data: data) else { return }
                self?.imageView.image = uiImage
            }
        }.resume()
    }
}
