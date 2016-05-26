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
    
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    
    override func viewDidLoad() {
        print("Instagram View Loaded")
        print(Model.data)
        
        instagramButton.hidden = true
        
        getData()
        
        view.addSubview(imageView)
        
        // Example on how to display images.  Need to get 'addSubview' on the Main thread.
        
//        let imageURL = NSURL(string: "https://scontent.cdninstagram.com/t51.2885-15/s640x640/sh0.08/e35/13108620_160355351030656_1854262967_n.jpg?ig_cache_key=MTIzNzM4OTc3Mjk1NjU1MjUzNg%3D%3D.2")
//        let imgRequest = NSURLRequest(URL: imageURL!)
//        let imgSession = NSURLSession.sharedSession()
//        let imgTask = imgSession.dataTaskWithRequest(imgRequest) {
//            (data, response, error) -> Void in
//            
//            let image = UIImage(data: data!)
//            self.imageView.image = image
//
//            self.view.addSubview(self.imageView)
//            
//        }
//        
//        imgTask.resume()
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
    
        guard let requestURL = NSURL(string: "https://api.instagram.com/v1/users/3121949530/media/recent/?access_token=\(accessToken)&count=4") else {
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
            
            guard let httpResponse = response as? NSHTTPURLResponse else {
                print("Error: No Response from server")
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                
                print("Instagram API Request Successful")
                
                guard let data = data else {
                    print("Error: No Data sent by API")
                    return
                }
                
                self.parseJSONData(data)
                
            }
            
            
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
    
    
    /// Get Images from json data.
    func parseJSONData(data: NSData) {
        
        print("parseJSONData Called.")
        
        do {
            
            let json: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            guard let data = json["data"] as? [[String: AnyObject]] else {
                print("Error: No Data Found")
                return
            }
            
            
            for data in data {
                
                guard let type = data["type"] as? String else {
                    print("Error: Type (Image or Video) not found")
                    return
                }
                
                if type == "image" {
                    
                    guard let images = data["images"] as? [String: AnyObject],
                    let standardResolution = images["standard_resolution"] as? [String: AnyObject],
                    let imageURL = standardResolution["url"] as? String else {
                            return
                    }
                    
                    guard let url = NSURL(string: imageURL) else {
                        return
                    }
                    
                    let request = NSURLRequest(URL: url)
                    let imgSession = NSURLSession.sharedSession()
                    let imgTask = imgSession.dataTaskWithRequest(request) {
                        (data, response, error) -> Void in
                        
                        let image = UIImage(data: data!)
                        
                        
                        // Image View needs to be on Main Thread.
                        self.imageView.image = image
                        
                        
                    }
                    
                    imgTask.resume()
                    
                }
                
            }
            
            
            
            
            
        } catch {
            
            print("Error: No JSON Data")
        }
        
    }
}
