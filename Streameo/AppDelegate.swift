//
//  AppDelegate.swift
//  Streameo
//
//  Created by Suraj Kumar on 03/07/24.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UIGestureRecognizerDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let rootViewController = storyboard.instantiateViewController(withIdentifier: "loginVC") as? LoginViewController {
            let navigationController = UINavigationController(rootViewController: rootViewController)
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        } else {
            print("Failed to instantiate RootViewController")
            return false
        }
        
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

    // Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Streameo")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    // Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
