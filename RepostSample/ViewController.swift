//
//  ViewController.swift
//  RepostSample
//
//  Created by Jason Lemrond on 5/8/16.
//  Copyright © 2016 Jason Lemrond. All rights reserved.
//

import UIKit
import OAuthSwift

let services = Services()
let DocumentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
let FileManager: NSFileManager = NSFileManager.defaultManager()

let Instagram =
[
    "consumerKey": "",
    "consumerSecret": ""
]


class ViewController: UIViewController {
    
    
    // *****************************
    //   MARK: Instagram Methods
    // *****************************
    
    func doAuthService(service: String) {
        
        guard var parameters = services[service] else {
            showAlertView("Miss configuration", message: "\(service) not configured")
            return
        }
        
        if Services.parametersEmpty(parameters) {
            let message = "\(service) seems to have not been well configured. \nPlease fill consumer key and secret info into configuration file \(self.confPath)"
            print(message)
            showAlertView("Miss configuration", message: message)
        }
        
        parameters["name"] = service
        
        switch service {
        case "Instagram" : instagramAuth(parameters)
        default: print("\(service) not implemented")
        }
        
    }
    
    func instagramAuth(serviceParameter: [String: String]) {
        let oauth = OAuth2Swift(
            consumerKey: serviceParameter["consumerKey"]!,
            consumerSecret: serviceParameter["consumerSecret"]!,
            authorizeUrl: "https://api.instagram.com/oauth/authorize",
            responseType: "token"
        )
        
        let state: String = generateStateWithLength(20) as String
        oauth.authorize_url_handler = getURLHandler()
        oauth.authorizeWithCallbackURL(NSURL(string: "repostSample://oauth-callback/instagram")!, scope: "likes+comments", state: state, success: { (credential, response, parameters) -> Void in
            self.showTokenAlert(serviceParameter["name"], credential: credential)
            self.testInstagram(oauth)
            }, failure: { (error) -> Void in
                print(error.localizedDescription)
        })
    }
    
    
    // This is only a test.  You will need to use this info to log them in and view their information.
    func testInstagram(oauth: OAuth2Swift) {
        let url: String = "https://api.instagram.com/v1/users/706215427/?access_token=\(oauth.client.credential.oauth_token)"
        let parameters: Dictionary = [String: AnyObject]()
        oauth.client.get(url, parameters: parameters,
            success: {
                (data, response) -> Void in
                let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                print(jsonDict)
            
            }, failure: { (error) -> Void in
                print(error)
        })
    }
    
    
    // **************************************
    //     MARK: View Controller Methods
    // **************************************
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("loaded")
        
        //Load config from files
        initConfig()
        
        getURLHandler()
        
        let label = UILabel()
        label.text = "THINGS"
        label.textAlignment = .Center
        view.addSubview(label)
        
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

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.keys.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        let service = services.keys[indexPath.row]
        cell.textLabel?.text = service
        
        if let parameters = services[service] where Services.parametersEmpty(parameters) {
            cell.textLabel?.textColor = UIColor.redColor()
        }
        if let parameters = services[service], authentified = parameters["authentified"] where authentified == "1" {
            cell.textLabel?.textColor = UIColor.greenColor()
        }
        print("Test")
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        let service: String = services.keys[indexPath.row]
        
        doAuthService(service)
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
    }
}

