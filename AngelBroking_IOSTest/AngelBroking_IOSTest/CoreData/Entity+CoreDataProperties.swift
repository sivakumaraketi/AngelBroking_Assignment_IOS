//
//  Entity+CoreDataProperties.swift
//  AngelBroking_IOSTest
//
//  Created by Amsys on 18/02/20.
//  Copyright © 2020 SivaKumarAketi. All rights reserved.
//
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var avatarUrl: Data?
    @NSManaged public var display_name: String?
    @NSManaged public var id: Int16
    @NSManaged public var username: String?
    @NSManaged public var addList: Bool

}
