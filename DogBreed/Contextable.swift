//
// Created by Ivan Petukhov on 01.08.2022.
//

import Foundation
import CoreData
import UIKit

protocol Contextable {
    var dataContext: NSManagedObjectContext? { get }
}

extension Contextable {
    var dataContext: NSManagedObjectContext? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
}