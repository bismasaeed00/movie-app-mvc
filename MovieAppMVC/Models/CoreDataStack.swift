//
//  CoreDataStack.swift
//  MovieAppMVC
//
//  Created by Bisma Saeed on 15.05.26.
//

import CoreData
import Foundation

final class CoreDataStack {
    static let shared = CoreDataStack()
    private init() { /* restrict re-init of singeltons */ }

    // MARK: - Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MovieAppMVC")
        container.loadPersistentStores { _, error in
            guard let error else { return }
            fatalError("Core Data failed to load: \(error.localizedDescription)")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Save
    func saveContext() {
        let ctx = context
        guard ctx.hasChanges else { return }
        do {
            try ctx.save()
        } catch {
            print("Core Data save error: \(error.localizedDescription)")
        }
    }
}
