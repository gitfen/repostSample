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
    
//    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    
    override func viewDidLoad() {
        print("Instagram View Loaded")
        print(Model.data)
        
        instagramButton.hidden = true
        
        getData()
        
//        view.addSubview(imageView)
        
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
    
        guard let requestURL = NSURL(string: "https://api.instagram.com/v1/users/706215427/media/recent/?access_token=\(accessToken)") else {
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
            
            for (index, data) in data.enumerate() {
                
                dispatch_async(GlobalQueue.initiated) {
                
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
                        
                        self.displayImageFromURL(url, index: index)
                        
                    }
                }               // End Dispatch
            }                   // End For Loop
            
        } catch {
            
            print("Error: No JSON Data")
        }
        
    }
    
    func displayImageFromURL(url: NSURL, index: Int) {
        
        let request = NSURLRequest(URL: url)
        let imgSession = NSURLSession.sharedSession()
        let imgTask = imgSession.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            guard let data = data else {
                return
            }
            
            self.displayImageWithData(data, index: index)
            
        }
        
        imgTask.resume()
        
    }
    
    
    /// Display Images
    func displayImageWithData(data: NSData, index: Int) {
        
        let image = UIImage(data: data)
        
        let xCoord = index * 50
        
        let imageView = UIImageView(frame: CGRect(x: xCoord, y: 40, width: 50, height: 50))
        imageView.image = image
        
        dispatch_async(GlobalQueue.main) {
            self.view.addSubview(imageView)
        }
    }
    
}  // End View Controller
