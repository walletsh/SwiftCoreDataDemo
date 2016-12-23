//
//  Contact+CoreDataProperties.swift
//  SwiftCoreDataDemo
//
//  Created by imwallet on 16/12/20.
//  Copyright © 2016年 imWallet. All rights reserved.
//

import Foundation
import CoreData


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact");
    }

    @NSManaged public var tel: String?
    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var address: String?
    @NSManaged public var sex: Bool
    @NSManaged public var birthday: String?
    @NSManaged public var headImg: String?

}
