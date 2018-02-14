//
//  AppDelegate.swift
//  stockApp
//
//  Created by David Sally on 4/9/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	// MARK: - Properties
	var window: UIWindow?
	
	// Create stock store model
	let stockStore = StockStore()
	
	// App Finished Launching
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		/// initialize the stockModel in the main view to use the same model declared here
		let root = window?.rootViewController as! UINavigationController
		let mainViewController = root.topViewController as! ViewController
		mainViewController.stockStore = stockStore

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		
		
		// when the app enters the background, save all the data
		print(#function)
		
		// return a bool to signify success or failure
		let successfullSave = stockStore.saveChanges()
	
		if (successfullSave) {
			print("Saved all items successfully")
		} else {
			print("ERROR: Did not save successfully")
		}
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

