//
//  PersistenceService.swift
//  AngelBroking_IOSTest
//
//  Created by Amsys on 17/02/20.
//  Copyright © 2020 SivaKumarAketi. All rights reserved.
//

import Foundation
import CoreData

//this class is responsible for save,delete,fetch coredata
class PersistenceService {
    
    private init() {}
    static let shared = PersistenceService()
    
    var isEmpty: Bool {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
            let count  = try context.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
    
    
    var context:NSManagedObjectContext {return persistentContainer.viewContext}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AngelBroking_IOSTest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                 if let error = error as NSError? {
                     fatalError("Unresolved error \(error), \(error.userInfo)")
                 }
             })
             return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
 
    // MARK: Delete Data Records

    func deleteRecords() -> Void {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")

         let result = try? context.fetch(fetchRequest)
            let resultData = result as! [Entity]

            for object in resultData {
                context.delete(object)
            }

            do {
                try context.save()
            } catch let error as NSError  {
            } catch {

            }





    }
    
    //for update
    func updateData(){
     
         //As we know that container is set up in the AppDelegates so we need to refer that container.
         
         //We need to create a context from this container
         let managedContext = persistentContainer.viewContext
         
         let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Entity")
         fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur1")
         do
         {
             let test = try managedContext.fetch(fetchRequest)
    
                 let objectUpdate = test[0] as! NSManagedObject
                 objectUpdate.setValue(true, forKey: "addList")
                 do{
                     try managedContext.save()
                 }
                 catch
                 {
                     print(error)
                 }
             }
         catch
         {
             print(error)
         }
    
     }
    

    
    func fetch<T: NSManagedObject>(_ type: T.Type, completion: @escaping ([T]) -> Void) {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        do {
           let objects = try context.fetch(request)
            completion(objects)
        } catch {
            print(error)
            completion([])
        }
        
    }
    

}
