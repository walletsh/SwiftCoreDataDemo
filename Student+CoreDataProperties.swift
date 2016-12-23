//
//  Student+CoreDataProperties.swift
//  SwiftCoreDataDemo
//
//  Created by imwallet on 16/12/21.
//  Copyright © 2016年 imWallet. All rights reserved.
//

import Foundation
import CoreData


extension Student {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Student> {
        return NSFetchRequest<Student>(entityName: "Student");
    }

    @NSManaged public var name: String?
    @NSManaged public var age: Int16
    @NSManaged public var teacher: Teacher?

}
