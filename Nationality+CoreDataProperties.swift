//
//  Nationality+CoreDataProperties.swift
//  SwiftCoreDataDemo
//
//  Created by imwallet on 16/12/23.
//  Copyright © 2016年 imWallet. All rights reserved.
//

import Foundation
import CoreData


extension Nationality {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Nationality> {
        return NSFetchRequest<Nationality>(entityName: "Nationality");
    }

    @NSManaged public var area: Float
    @NSManaged public var countryName: String?
    @NSManaged public var citys: NSSet?

}

// MARK: Generated accessors for citys
extension Nationality {

    @objc(addCitysObject:)
    @NSManaged public func addToCitys(_ value: City)

    @objc(removeCitysObject:)
    @NSManaged public func removeFromCitys(_ value: City)

    @objc(addCitys:)
    @NSManaged public func addToCitys(_ values: NSSet)

    @objc(removeCitys:)
    @NSManaged public func removeFromCitys(_ values: NSSet)

}
