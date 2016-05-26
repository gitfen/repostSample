//
//  InstagramViewController.swift
//  RepostSample
//
//  Created by Jason Lemrond on 5/8/16.
//  Copyright © 2016 Jason Lemrond. All rights reserved.
//

import Foundation
import UIKit

class InstagramViewController: UIViewController {
    
    @IBOutlet weak var printButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    
    override func viewDidLoad() {
        print("Instagram View Loaded")
        print(Model.data)
        
        instagramButton.hidden = true
        
        getData()
    }
    
    func getData() {
        if (Model.data != nil) {
            getData()
        }
        
        print(Model.data)
        
    }
    
    
    @IBAction func printData(sender: UIButton) {
        
        print(Model.data)
        
        printButton.hidden = true
        instagramButton.hidden = false
        
    }
    
    
    @IBAction func showImages(sender: UIButton) {
        
        getInstagramImages("123")
        
    }
    
    
    func getInstagramImages(userId: String) {
        
        print("getInstagramImages called. User \(userId)")
        
        let accessToken = getAccessToken()
        
        print("https://api.instagram.com/v1/users/195305144/media/recent?access_token=\(accessToken)&count=5&callback=?")
    
        guard let requestURL = NSURL(string: "https://api.instagram.com/v1/users/195305144/media/recent?access_token=\(accessToken)&count=5&callback=?") else {
            print("no requestURL")
            return
        }
        
        let urlRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            print(data)
            print(response)
            print(error)
            
        }
        
        task.resume()
        
    }
    
    
    /// Returns the Access Token for the current user from OAuth.
    func getAccessToken() -> String {
        
        guard let token = Model.accessToken else {
            print("Error: No Access Token Available")
            return "Error: No Access Token Available"
        }
        
        return String(token)
        
    }
}
