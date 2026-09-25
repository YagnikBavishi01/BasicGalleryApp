//
//  AppDelegate.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import UIKit

/// The app's `UIApplicationDelegate`.
///
/// UI setup (window, root view controller) happens in ``SceneDelegate``
/// since the app uses the UIScene lifecycle; this type only performs
/// app-wide, scene-independent setup.
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// Eagerly loads the Core Data persistent store at launch, so the first
    /// access from ``ImageRepository`` doesn't pay that cost mid-scroll.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = CoreDataStack.shared.persistentContainer
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
