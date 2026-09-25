//
//  CachedImage+CoreDataClass.swift
//  DemoBasicGalleryApp
//
//  Created by Yagnik Bavishi on 25/09/26.
//

import Foundation
import CoreData

/// The Core Data–persisted record for a single gallery image, including its
/// downloaded thumbnail bytes so it can be viewed offline.
///
/// See ``GalleryModel.xcdatamodeld`` for the entity definition and
/// ``CachedImage+CoreDataProperties`` for its managed properties. Manual
/// codegen is used (rather than Xcode's automatic class generation) so this
/// pair of files can carry documentation and stay under version control.
@objc(CachedImage)
public class CachedImage: NSManagedObject {

}
