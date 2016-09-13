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

class SearchViewImages {

    static let sharedInstance = SearchViewImages()

    var images: [InstagramImage?] = []

}

class InstagramImage {
    
    var json: JSON {
        didSet {
            print("JSON Set")
        }
    }
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
            guard error == nil else {
                return
            }

            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 || statusCode <= 299 else {
                return
            }

            guard let image = data else {
                return
            }
            
            print("Image Data Returned")
            
            guard let imageWithData = UIImage(data: image) else {
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

class UsersSearchData {
    
    var fullName: String!
    var username: String!
    var id: String!
    var profilePictureURL: String!
    var bio: String!
    var website: String!
    
    init (jsonData: JSON) {
        self.username = jsonData["username"].string
        self.fullName = jsonData["full_name"].string
        self.id = jsonData["id"].string
        self.profilePictureURL = jsonData["profile_picture"].string
        self.bio = jsonData["bio"].string
        self.website = jsonData["website"].string
    }
    
}

enum SearchTypes: String {
    case Hashtag = "Hashtags"
    case Users = "People"
}


struct StoryboardNames {
    static let navigationController = "NavigationController"
    static let instagramViewController = "InstagramViewController"
    static let imageViewController = "ImageViewController"
}

