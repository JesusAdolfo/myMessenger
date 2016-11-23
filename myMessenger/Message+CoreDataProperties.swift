//
//  Message+CoreDataProperties.swift
//  myMessenger
//
//  Created by Jesus Adolfo on 5/8/16.
//  Copyright © 2016 Jesus Adolfo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Message {

    @NSManaged var date: Date?
    @NSManaged var text: String?
    @NSManaged var isSender: NSNumber?
    @NSManaged var friend: Friend?

}
