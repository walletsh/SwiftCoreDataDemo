//
//  Teacher+CoreDataProperties.swift
//  SwiftCoreDataDemo
//
//  Created by imwallet on 16/12/21.
//  Copyright © 2016年 imWallet. All rights reserved.
//

import Foundation
import CoreData


extension Teacher {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Teacher> {
        return NSFetchRequest<Teacher>(entityName: "Teacher");
    }

    @NSManaged public var name: String?
    @NSManaged public var subject: String?
    @NSManaged public var students: NSSet?

}

// MARK: Generated accessors for students
extension Teacher {

    @objc(addStudentsObject:)
    @NSManaged public func addToStudents(_ value: Student)

    @objc(removeStudentsObject:)
    @NSManaged public func removeFromStudents(_ value: Student)

    @objc(addStudents:)
    @NSManaged public func addToStudents(_ values: NSSet)

    @objc(removeStudents:)
    @NSManaged public func removeFromStudents(_ values: NSSet)

}
