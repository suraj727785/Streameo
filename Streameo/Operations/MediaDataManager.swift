//
//  MediaDataManager.swift
//  Streameo
//
//  Created by Suraj Kumar on 04/07/24.
//
import CoreData
import Foundation

class MediaDataManager {
    static let shared = MediaDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Streameo") // Replace with your model name
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func fetchDataFromAPI(completion: @escaping () -> Void) {
        guard let url = URL(string: "https://interview-e18de.firebaseio.com/media.json?print=pretty") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                if let jsonArray = jsonArray {
                    self.saveDataToCoreData(jsonArray: jsonArray)
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func updateLastPlayedDuration(lastPlayed: Int, id: String) {
        let fetchRequest: NSFetchRequest<MediaItem> = MediaItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let mediaItems = try context.fetch(fetchRequest)
            if let mediaItem = mediaItems.first {
                mediaItem.lastPlayedDuration = Int32(lastPlayed)
                
                try context.save()
            }
        } catch {
            print("Failed to update last played duration: \(error.localizedDescription)")
        }
    }
    
    func getMediaItem(by id: String) -> MediaItem? {
        let fetchRequest: NSFetchRequest<MediaItem> = MediaItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let mediaItems = try context.fetch(fetchRequest)
            return mediaItems.first
        } catch {
            print("Failed to fetch media item: \(error.localizedDescription)")
            return nil
        }
    }
    
    func saveDataToCoreData(jsonArray: [[String: Any]]) {
        if !deleteAllValuesFromDB(){
            return
        }
        for item in jsonArray {
            guard let id = item["id"] as? String,
                  let title = item["title"] as? String,
                  let description = item["description"] as? String,
                  let url = item["url"] as? String,
                  let thumb = item["thumb"] as? String else { continue }
            
            let mediaItem = NSEntityDescription.insertNewObject(forEntityName: "MediaItem", into: context) as! MediaItem
            mediaItem.id = id
            mediaItem.title = title
            mediaItem.descriptionText = description
            mediaItem.url = url
            mediaItem.thumb = thumb
            mediaItem.lastPlayedDuration = 0
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save data: \(error.localizedDescription)")
        }
    }
    func deleteAllValuesFromDB() -> Bool {
        let fetchRequest: NSFetchRequest<MediaItem> = MediaItem.fetchRequest()
        do {
            let mediaItems = try context.fetch(fetchRequest)
            for managedObject in mediaItems
            {
                let managedObjectData:NSManagedObject = managedObject as NSManagedObject
                context.delete(managedObjectData)
            }
            return true
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
            return false
        }
    }
    func fetchAllMediaItems() -> [MediaItem] {
        let fetchRequest: NSFetchRequest<MediaItem> = MediaItem.fetchRequest()
        do {
            let mediaItems = try context.fetch(fetchRequest)
            return mediaItems
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
            return []
        }
    }
}
