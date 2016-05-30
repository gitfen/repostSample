//
//  Model.swift
//  RepostSample
//
//  Created by Jason Lemrond on 5/8/16.
//  Copyright © 2016 Jason Lemrond. All rights reserved.
//

import Foundation
import SwiftyJSON

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
    
    func getImageURL() -> String? {
        
        let images = json["images"]
        
        if let url = images["high_resolution"]["url"].string {
            return url
        }
        
        if let url = images["standard_resolution"]["url"].string {
            return url
        }
        
        if let url = images["low_resolution"]["url"].string {
            return url
        }
        
        return nil
        
    }
    
}


