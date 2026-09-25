//
//  CachedImage+CoreDataProperties.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import Foundation
import CoreData

extension CachedImage {

    /// A typed fetch request for the `CachedImage` entity.
    ///
    /// - Returns: A fetch request with no predicate or sort descriptors
    ///   applied; callers configure those as needed.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedImage> {
        NSFetchRequest<CachedImage>(entityName: "CachedImage")
    }

    /// Picsum's stable identifier for the image; used as the effective
    /// primary key (see the entity's uniqueness constraint).
    @NSManaged public var id: String?

    /// The photographer/author credit.
    @NSManaged public var author: String?

    /// The full-resolution original image's URL, kept for reference and for
    /// reconstructing a ``GalleryImage`` while offline.
    @NSManaged public var downloadURL: String?

    /// The original image's width, in pixels.
    @NSManaged public var width: Int32

    /// The original image's height, in pixels.
    @NSManaged public var height: Int32

    /// The downloaded thumbnail's raw bytes, stored with Core Data's
    /// external binary storage so large blobs don't bloat the SQLite file.
    @NSManaged public var imageData: Data?

    /// The gallery page this image was fetched as part of.
    @NSManaged public var pageIndex: Int32

    /// A stable ordering index (page × page size + position within page),
    /// used to keep cached results in their original display order.
    @NSManaged public var sortIndex: Int32

    /// When this record was cached, for diagnostic/debugging purposes.
    @NSManaged public var createdAt: Date?

}

extension CachedImage: Identifiable {
}
