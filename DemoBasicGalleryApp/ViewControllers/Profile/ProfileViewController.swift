//
//  ProfileViewController.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//
//  Layout lives in Main.storyboard ("ProfileViewController" scene).
//

import UIKit

/// Shows the signed-in user's avatar, name, and email, with a logout
/// action, driven by ``ProfileViewModel``.
final class ProfileViewController: UIViewController {

    /// The identifier of this view controller's scene in `Main.storyboard`.
    static let storyboardIdentifier = "ProfileViewController"

    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!

    /// The view model driving this screen. Must be set by the presenter
    /// (see ``AppCoordinator``) before the view loads.
    var viewModel: ProfileViewModel!

    /// Called once logout completes, so the presenter can return to the
    /// login flow.
    var onLogout: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        avatarImageView.clipsToBounds = true
        populate()
        viewModel.onLogout = { [weak self] in
            self?.onLogout?()
        }
    }

    /// Fills in the user's name, email, and (asynchronously) avatar.
    private func populate() {
        nameLabel.text = viewModel.user?.displayName ?? "Guest"
        emailLabel.text = viewModel.user?.email ?? ""
        guard let urlString = viewModel.user?.profileImageURL, let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.avatarImageView.image = image
            }
        }.resume()
    }

    /// Handles a tap on the "Log Out" button by confirming, then invoking
    /// ``ProfileViewModel/logout()``.
    @IBAction private func logoutTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.viewModel.logout()
        })
        present(alert, animated: true)
    }
}
