//
//  CoreDataStack.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import CoreData

/// Owns the app's Core Data stack, used to persist gallery images for
/// offline viewing (see ``ImageRepository`` and ``CachedImage``).
final class CoreDataStack {

    /// The shared stack used throughout the app.
    static let shared = CoreDataStack()

    private init() {}

    /// The persistent container for the `GalleryModel` data model.
    ///
    /// Lazily loaded on first access; a failure to load the persistent
    /// store is treated as a programmer error (`assertionFailure`) rather
    /// than a recoverable runtime condition.
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GalleryModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }
        // Configure via `container` directly: going through `self.viewContext`
        // here would re-enter this lazy initializer and recurse.
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    /// The main-queue-confined context used for reads that back the UI.
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    /// Creates a new context suitable for background writes (e.g. caching
    /// downloaded thumbnails), configured to prefer in-memory changes over
    /// the persisted store on merge conflicts.
    ///
    /// - Returns: A new private-queue `NSManagedObjectContext`.
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    /// Saves `context` if it has pending changes.
    ///
    /// A save failure is treated as a programmer error (`assertionFailure`)
    /// rather than a recoverable runtime condition.
    ///
    /// - Parameter context: The context to save.
    func saveContext(_ context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            assertionFailure("Failed to save Core Data context: \(error)")
        }
    }
}
