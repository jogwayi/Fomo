//
// AppDelegate.swift
// ============================


import UIKit
import CoreData
import GoogleMaps
import SCLAlertView

// All Notification Types Here
let userDidLogoutNotification = "kUserDidLogoutNotification"
let userHasOnboardedKey = "user_has_onboarded"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let ITINERARY_USE_CACHE = false

    var window: UIWindow?
    var storyboard = UIStoryboard(name: "Main", bundle: nil)

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        GMSServices.provideAPIKey("AIzaSyC7XVmzjgjsTD6uKRX8Cc7W8W6ewUvXX9w")
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        UILabel.appearance().font = UIFont(name: "AppleSDGothicNeo-Light", size: 20)
        UINavigationBar.appearance().tintColor = UIColor.fomoHighlight()
        UIBarButtonItem.appearance().tintColor = UIColor.fomoHighlight()
        UINavigationBar.appearance().backgroundColor = UIColor.fomoNavBar()
        UINavigationBar.appearance().titleTextAttributes = [ NSFontAttributeName: UIFont.fomoBold(18),NSForegroundColorAttributeName: UIColor.fomoNavBarText()]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidLogout", name: userDidLogoutNotification, object: nil)
        
        // Onboarding
        // ============================
        // Temp: always show onboarding
        // let userHasOnboardedAlready = NSUserDefaults.standardUserDefaults().boolForKey(userHasOnboardedKey)
        
        // Logged in user
        if Cache.currentUser != nil {
            print("Current user detected: \(Cache.currentUser!.name!)")
            let user = Cache.currentUser!
            
            RecommenderClient.sharedInstance.get_itineraries_for_user(user) {
                (response: [Itinerary]?, error: NSError?) -> () in
                if error != nil || response == nil {
                    print("No Itinerary detected")
                    Cache.itinerary = nil
                    let vc = self.storyboard.instantiateViewControllerWithIdentifier("FomoNavigationController") as! UINavigationController
                    let container = vc.topViewController as? ContainerViewController
                    container?.initialVC = self.storyboard.instantiateViewControllerWithIdentifier("CityViewController") as! CityViewController
                    
                    UIView.transitionWithView(self.window!, duration: 0.5, options: .TransitionCrossDissolve, animations: { () -> Void in
                        self.window?.rootViewController = vc
                    }, completion:nil)
                } else {
                    let it = response?.first
                    print("Itinerary \(it!.tripName!) detected")
                    let vc = self.storyboard.instantiateViewControllerWithIdentifier("FomoNavigationController") as UIViewController
                    
                    UIView.transitionWithView(self.window!, duration: 0.5, options: .TransitionCrossDissolve, animations: { () -> Void in
                        self.window?.rootViewController = vc
                        
                    }, completion:nil)
                }
            }
        } else {
            print("No User Detected.")
            
            // Onboarding
            self.window!.rootViewController = self.generateOnboardingViewController()
        }
    
        return true
    }
    
    // Logged out user
    func setupNormalRootVC() {
        UIView.transitionWithView(self.window!, duration: 0.5, options: .TransitionCrossDissolve, animations: { () -> Void in
            self.window?.rootViewController = self.storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as UIViewController
        }, completion:nil)
    }
    

    func userDidLogout() {
        let vc = storyboard.instantiateInitialViewController()
        window?.rootViewController = vc
        print("User did logout")
    }
    
    
    // Onboarding - for logged out users only
    // ============================
    func generateOnboardingViewController() -> OnboardingViewController {
        // Page 1
        let firstPage: OnboardingContentViewController = OnboardingContentViewController(
            page: 1,
            title: "Explore Destinations",
            body: "Browse personalized activity recommendations",
            backgroundImage: UIImage(named: "heartbkgd"),
            gifName: "heartglasses",
            image: nil,
            buttonText: nil) {
            }
        
        // Page 2
        let secondPage: OnboardingContentViewController = OnboardingContentViewController(
            page: 2,
            title: "Invite Friends",
            body: "Automatically aggregate traveller preferences",
            backgroundImage: UIImage(named: "camerabkgd"),
            gifName: "camera",
            image: nil,
            buttonText: nil) {
            }
        
        // Page 3
        let thirdPage: OnboardingContentViewController = OnboardingContentViewController(
            page: 3,
            title: "Generate Itinerary",
            body: "FOMO intelligently generates the optimal group trip itinerary",
            backgroundImage: UIImage(named: "roadtripbkgd"),
            gifName: "roadtrip",
            image: nil,
            buttonText: "Get Started") {
                self.handleOnboardingCompletion()
            }
        
        // Create the onboarding controller with the pages and return it
        let onboardingVC: OnboardingViewController = OnboardingViewController(contents: [firstPage, secondPage, thirdPage])
        
        return onboardingVC
    }
    
    func handleOnboardingCompletion() {
        // Set in NSUserDefaults that we've onboarded so in the future 
        // when we launch the application we won't see the onboarding again.
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: userHasOnboardedKey)
        
        setupNormalRootVC()
    }
    // ============================
    

    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }


    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()

    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "CodePath.Fomo" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Fomo", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

