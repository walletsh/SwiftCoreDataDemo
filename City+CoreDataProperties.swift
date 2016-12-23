//
//  City+CoreDataProperties.swift
//  SwiftCoreDataDemo
//
//  Created by imwallet on 16/12/23.
//  Copyright © 2016年 imWallet. All rights reserved.
//

import Foundation
import CoreData


extension City {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<City> {
        return NSFetchRequest<City>(entityName: "City");
    }

    @NSManaged public var cityName: String?
    @NSManaged public var isCapital: Bool
    @NSManaged public var country: Nationality?

}
