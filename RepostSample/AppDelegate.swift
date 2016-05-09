//
//  AppDelegate.swift
//  RepostSample
//
//  Created by Jason Lemrond on 5/8/16.
//  Copyright © 2016 Jason Lemrond. All rights reserved.
//

import UIKit
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
//    let viewController: ViewController = ViewController()
//    let naviController: UINavigationController = UINavigationController(rootViewController: viewController)
//    self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//    self.window!.rootViewController = naviController
//    self.window!.makeKeyAndVisible()
    return true
  }
  
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    applicationHandleOpenURL(url)
    return true
  }
  
  @available(iOS 9.0, *)
  func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    applicationHandleOpenURL(url)
    return true
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
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

}


extension AppDelegate {
  
    func applicationHandleOpenURL(url: NSURL) {
        if (url.host == "oauth-callback") {
            OAuthSwift.handleOpenURL(url)
            
            let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let instagramViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("InstagramViewController") 
            window = UIWindow(frame: UIScreen.mainScreen().bounds)
            window?.rootViewController = instagramViewController
            window?.makeKeyAndVisible()
            
        } else {
            OAuthSwift.handleOpenURL(url)
        }
    }
  
}

