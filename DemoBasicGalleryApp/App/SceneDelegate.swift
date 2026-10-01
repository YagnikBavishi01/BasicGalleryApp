//
//  SceneDelegate.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import UIKit
import GoogleSignIn

/// Owns this app's single window and kicks off ``AppCoordinator`` once any
/// previous Google session has been silently restored.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    /// The scene's main window.
    var window: UIWindow?

    private var coordinator: AppCoordinator?

    /// Creates the window, attempts to silently restore a previous Google
    /// sign-in, and then asks ``AppCoordinator`` to show the appropriate
    /// initial flow.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // Show something immediately so the user never sees a blank window
        // while the previous Google session is being restored.
        let placeholder = UIViewController()
        placeholder.view.backgroundColor = .systemBackground
        window.rootViewController = placeholder
        window.makeKeyAndVisible()

        let coordinator = AppCoordinator(window: window)
        self.coordinator = coordinator

        Task {
            if let user = await GoogleAuthService().restorePreviousSignIn() {
                SessionManager.shared.startSession(for: user)
            }
            coordinator.start()
        }
    }

    /// Forwards the Google Sign-In redirect URL to the SDK so it can
    /// complete the in-progress sign-in flow.
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        GIDSignIn.sharedInstance.handle(url)
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
