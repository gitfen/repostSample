//
//  ViewController.swift
//  RepostSample
//
//  Created by Jason Lemrond on 5/8/16.
//  Copyright © 2016 Jason Lemrond. All rights reserved.
//

import UIKit
import OAuthSwift
import SwiftyJSON

let services = Services()
let DocumentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
let FileManager: NSFileManager = NSFileManager.defaultManager()

let Instagram =
[
    "consumerKey": "",
    "consumerSecret": ""
]


class LoginViewController: UIViewController {

    var appDelegate: AppDelegate!
    
    
    // ***********************************
    //   MARK: Instagram Login Methods
    // ***********************************
    
    func doAuthService(service: String) {
        
        guard var parameters = services[service] else {
            displayOneButtonAlert("Miss configuration", message: "\(service) not configured")
            return
        }
        
        if Services.parametersEmpty(parameters) {
            let message = "\(service) seems to have not been well configured. \nPlease fill consumer key and secret info into configuration file \(self.confPath)"
            print(message)
            displayOneButtonAlert("Miss configuration", message: message)
        }
        
        parameters["name"] = service
        
        switch service {
        case "Instagram" : instagramAuth(parameters)
        default: print("\(service) not implemented")
        }
        
    }
    
    func instagramAuth(serviceParameter: [String: String]) {
        appDelegate.oauth = OAuth2Swift(
            consumerKey: serviceParameter["consumerKey"]!,
            consumerSecret: serviceParameter["consumerSecret"]!,
            authorizeUrl: "https://api.instagram.com/oauth/authorize",
            responseType: "token"
        )

        guard let oauth = appDelegate.oauth else {
            return
        }
        
        let state: String = generateStateWithLength(20) as String
        oauth.authorize_url_handler = getURLHandler()
        oauth.authorizeWithCallbackURL(NSURL(string: "repostSample://oauth-callback/instagram")!, scope: "likes+comments+public_content", state: state, success: { (credential, response, parameters) -> Void in
            self.loginInstagram(self.appDelegate.oauth!)
            }, failure: { (error) -> Void in
                self.displayOneButtonAlert("Alert", message: error.localizedDescription)
        })
    }
    

    func loginInstagram(oauth: OAuth2Swift) {
        
        let url: String = "https://api.instagram.com/v1/users/self/?access_token=\(oauth.client.credential.oauth_token)"
        let parameters: Dictionary = [String: AnyObject]()
        oauth.client.get(url, parameters: parameters,
            success: {
                (data, response) -> Void in
                let jsonDict = JSON(data: data)
                UserData.sharedInstance.json = jsonDict
                UserData.sharedInstance.accessToken = oauth.client.credential.oauth_token

                let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let instagramViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier(StoryboardNames.navigationController)
                self.presentViewController(instagramViewController, animated: true, completion: nil)

            }, failure: { (error) -> Void in
                print(error)
        })
    }
    
    
    
    // **************************************
    //     MARK: View Controller Methods
    // **************************************
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Login View Loaded")

        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //Load config from files
        initConfig()
        
        getURLHandler()

                doAuthService("Instagram")
        
    }
    
    
    
    // *****************************
    //     MARK: Button Methods
    // *****************************
    
    @IBAction func InstagramLogin(sender: UIButton) {
        
        doAuthService("Instagram")
        
    }
    
    
    
    // *****************************
    //     MARK: Utility Methods
    // *****************************
    
    func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func initConfig() {
        services["Instagram"] = Instagram
        
        //TODO: Create PLIST
        
        if let path = NSBundle.mainBundle().pathForResource("Services", ofType: "plist") {
            services.loadFromFile(path)
            
            if !FileManager.fileExistsAtPath(confPath) {
                do {
                    try FileManager.copyItemAtPath(path, toPath: confPath)
                } catch {
                    print("Failed to copy empty conf to \(confPath)")
                }
            }
            
        } else {
            print("Services.plist unavailable")
        }
    }

    var confPath: String {
        let appPath = "\(DocumentDirectory)/.oauth/"
        if !FileManager.fileExistsAtPath(appPath) {
            do {
                try FileManager.createDirectoryAtPath(appPath, withIntermediateDirectories: false, attributes: nil)
            }catch {
                print("Failed to create \(appPath)")
            }
        }
        return "\(appPath)Services.plist"
    }
    
    func showTokenAlert(name: String?, credential: OAuthSwiftCredential) {
        var message = "oauth_token:\(credential.oauth_token)"
        print(credential)
        if !credential.oauth_token_secret.isEmpty {
            message += "\n\noauth_token_secret:\(credential.oauth_token_secret)"
        }
        showAlertView(name ?? "Service", message: message)
        
        if let service = name {
            services.updateService(service, dico: ["authentified":"1"])
        }
    }
    
    func createWebViewController() -> WebViewController {
        let controller = WebViewController()
        return controller
    }
    
    func getURLHandler() -> OAuthSwiftURLHandlerType {
        let url_handler = createWebViewController()
        return url_handler
    }

}

