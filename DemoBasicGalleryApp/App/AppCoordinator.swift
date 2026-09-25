//
//  AppCoordinator.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import UIKit

/// Decides which flow (Login vs. Gallery/Profile) is shown as the window's
/// root, and owns the transitions between them.
///
/// Screens are defined in `Main.storyboard`; this coordinator instantiates
/// them by storyboard identifier and injects their view model, since
/// storyboard-loaded view controllers only support `init?(coder:)`.
final class AppCoordinator {

    private weak var window: UIWindow?
    private let sessionManager: SessionManager
    private let storyboard = UIStoryboard(name: "Main", bundle: nil)

    /// Creates a coordinator that will set `window`'s root view controller.
    ///
    /// - Parameters:
    ///   - window: The window to present the app's UI in.
    ///   - sessionManager: Used to decide the initial flow. Defaults to
    ///     ``SessionManager/shared``.
    init(window: UIWindow, sessionManager: SessionManager = .shared) {
        self.window = window
        self.sessionManager = sessionManager
    }

    /// Shows the Login flow or the Gallery/Profile flow, depending on
    /// whether a session already exists.
    ///
    /// Call once, after any silent sign-in restoration has completed.
    func start() {
        if sessionManager.isLoggedIn {
            showGallery()
        } else {
            showLogin()
        }
    }

    /// Presents ``LoginViewController`` as the window's root.
    func showLogin() {
        let loginVC = storyboard.instantiateViewController(withIdentifier: LoginViewController.storyboardIdentifier) as! LoginViewController
        loginVC.viewModel = LoginViewModel()
        loginVC.onLoginSuccess = { [weak self] in
            self?.showGallery()
        }
        window?.rootViewController = UINavigationController(rootViewController: loginVC)
        window?.makeKeyAndVisible()
    }

    /// Presents the Gallery/Profile tab bar as the window's root.
    func showGallery() {
        let galleryVC = storyboard.instantiateViewController(withIdentifier: GalleryViewController.storyboardIdentifier) as! GalleryViewController
        galleryVC.viewModel = GalleryViewModel()

        let profileVC = storyboard.instantiateViewController(withIdentifier: ProfileViewController.storyboardIdentifier) as! ProfileViewController
        profileVC.viewModel = ProfileViewModel()
        profileVC.onLogout = { [weak self] in
            self?.showLogin()
        }

        let galleryNav = UINavigationController(rootViewController: galleryVC)
        galleryNav.tabBarItem = UITabBarItem(title: "Gallery", image: UIImage(systemName: "photo.on.rectangle"), tag: 0)

        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 1)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [galleryNav, profileNav]

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
}
