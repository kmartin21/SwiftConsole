//
//  Result+CoreDataProperties.swift
//  Pods
//
//  Created by Jordan Zucker on 10/5/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Result {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Result> {
        return NSFetchRequest<Result>(entityName: "Result");
    }

    @NSManaged public var authKey: String?
    @NSManaged public var clientRequest: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var isTLSEnabled: Bool
    @NSManaged public var origin: String?
    @NSManaged public var statusCode: Int16
    @NSManaged public var stringifiedOperation: String?
    @NSManaged public var uuid: String?

}
