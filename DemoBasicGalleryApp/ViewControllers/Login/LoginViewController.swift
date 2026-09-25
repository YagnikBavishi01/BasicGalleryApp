//
//  LoginViewController.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//
//  Layout lives in Main.storyboard ("LoginViewController" scene); this
//  class only wires the outlets to the view model.
//

import UIKit

/// Shows the "Sign in with Google" button and reflects ``LoginViewModel``'s
/// state (idle/loading/success/failure) in the UI.
final class LoginViewController: UIViewController {

    /// The identifier of this view controller's scene in `Main.storyboard`.
    static let storyboardIdentifier = "LoginViewController"

    @IBOutlet private weak var signInButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    /// The view model driving this screen. Must be set by the presenter
    /// (see ``AppCoordinator``) before the view loads.
    var viewModel: LoginViewModel!

    /// Called once sign-in completes successfully, so the presenter can
    /// transition to the main app flow.
    var onLoginSuccess: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        bindViewModel()
    }

    /// Subscribes to view model state changes and updates the UI
    /// accordingly.
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            DispatchQueue.main.async {
                switch state {
                case .idle:
                    self.activityIndicator.stopAnimating()
                    self.signInButton.isEnabled = true
                case .loading:
                    self.activityIndicator.startAnimating()
                    self.signInButton.isEnabled = false
                case .success:
                    self.activityIndicator.stopAnimating()
                    self.signInButton.isEnabled = true
                    self.onLoginSuccess?()
                case .failure(let message):
                    self.activityIndicator.stopAnimating()
                    self.signInButton.isEnabled = true
                    self.presentError(message)
                }
            }
        }
    }

    /// Presents an alert describing a sign-in failure.
    ///
    /// - Parameter message: The user-facing error message to display.
    private func presentError(_ message: String) {
        let alert = UIAlertController(title: "Sign in failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    /// Handles a tap on the "Sign in with Google" button.
    @IBAction private func signInTapped(_ sender: UIButton) {
        viewModel.signIn(presenting: self)
    }
}
