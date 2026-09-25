# DemoBasicGalleryApp

Basic wallpaper gallery app (UIKit, MVVM, Core Data).

## Features
- Sign in with Google (GoogleSignIn-iOS SPM package)
- Paginated grid of online wallpapers (Lorem Picsum `list` API, no key required)
- Each loaded page is cached to Core Data (including image bytes), so already-viewed
  wallpapers remain browsable offline
- Full-screen image detail view
- Profile tab with user info and logout

## Architecture
- **MVVM**: `ViewModels/` expose state via closures; `ViewControllers/` are dumb consumers.
- **Repository pattern**: `Repository/ImageRepository.swift` is the single source of truth,
  merging the network service (`Networking/`) with the Core Data cache
  (`CoreData/CoreDataStack.swift`), falling back to cached data when offline.
- **Coordinator**: `App/AppCoordinator.swift` switches between the Login flow and the
  Gallery/Profile tab flow based on `Auth/SessionManager.swift`.

## Third-Party Libraries

| Library | Source | Why it's used |
|---|---|---|
| [GoogleSignIn-iOS](https://github.com/google/GoogleSignIn-iOS) | Swift Package Manager | Implements the "Sign in with Google" OAuth flow (`Auth/GoogleAuthService.swift`). This is the officially supported SDK for Google Sign-In on iOS — rolling a custom OAuth/WebView flow would mean re-implementing token exchange, session refresh, and Apple's required consent UI ourselves. |

Only the `GoogleSignIn` product of that package is linked. The package also
ships a `GoogleSignInSwift` product (a SwiftUI-only convenience button); it
was linked by default when the package was added but isn't imported
anywhere in this UIKit codebase (the sign-in button is a plain `UIButton`
wired up in `Main.storyboard`), so it has been **removed** from the
project's package dependencies to avoid carrying an unused framework.

Everything else — networking (`URLSession`), image decoding (`UIKit`),
persistence (`CoreData`) — uses first-party Apple frameworks only. The
Lorem Picsum image feed (`https://picsum.photos`) is a plain public HTTP
API, not an SDK/library, so it isn't a dependency in the Xcode-project
sense.

## Setup
1. Open `DemoBasicGalleryApp.xcodeproj` in Xcode; the GoogleSignIn-iOS SPM package resolves
   automatically.
2. Create an OAuth iOS client ID in the [Google Cloud Console](https://console.cloud.google.com/apis/credentials).
3. In `DemoBasicGalleryApp/Info.plist`, replace `YOUR_GOOGLE_CLIENT_ID` in both `GIDClientID`
   and the `CFBundleURLTypes` reversed-client-id URL scheme with your real client ID.
4. Also update `Constants.googleClientID` in `Common/Constants.swift` for reference/debugging.
5. Build and run on a simulator or device.
