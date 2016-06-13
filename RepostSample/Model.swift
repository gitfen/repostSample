//
//  Model.swift
//  RepostSample
//
//  Created by Jason Lemrond on 5/8/16.
//  Copyright © 2016 Jason Lemrond. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class Model {
    
    static var data: AnyObject?
    static var accessToken: String?
    //static let sharedInstance = Model()
    
    func isEmpty() -> Bool {
        if (Model.data != nil) {
            return true
        } else {
            return false
        }
    }
    
    
}

class InstagramImage {
    
    var json: JSON
    var image: UIImage?
    
    init(json: JSON) {
        self.json = json
    }
}


extension InstagramImage {
    
    var attribution: String? {
        guard let attribution = json["attribution"].string else {
            return nil
        }
        return attribution
    }
    
    var type: String? {
        guard let type = json["type"].string else {
            return nil
        }
        return type
    }
    
    var videoViews: Int? {
        guard let videoViews = json["video_views"].int else {
            return nil
        }
        return videoViews
    }
    
    func getImageURL() -> NSURL? {
        
        let images = json["images"]
        
        if let url = images["high_resolution"]["url"].string {
            return NSURL(string: url)
        }
        
        if let url = images["standard_resolution"]["url"].string {
            return NSURL(string: url)
        }
        
        if let url = images["low_resolution"]["url"].string {
            return NSURL(string: url)
        }
        
        return nil
        
    }
    
}

extension InstagramImage: ImageGetter {
    
    func getImageWithURL(url: NSURL, completionHandler: () -> Void) {
            
        let imgSession = NSURLSession.sharedSession()
        let task = imgSession.dataTaskWithURL(url) { (data, response, error) -> Void in
            guard let data = data else {
                return
            }
            
            print("Image Data Returned")
            
            guard let imageWithData = UIImage(data: data) else {
                return
            }
            
            self.image = imageWithData
            
            completionHandler()
            
        }
        
        task.resume()
        
    }
        
    
    
}

protocol ImageGetter {
    
    func getImageWithURL(url: NSURL, completionHandler: () -> Void)
    
}



class SearchData {
    
    var name: String!
    var mediaCount: Int!
    
    init(name: String, mediaCount: Int) {
        self.name = name
        self.mediaCount = mediaCount
    }
    
}


