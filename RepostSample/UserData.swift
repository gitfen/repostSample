//
//  UserData.swift
//  RepostSample
//
//  Created by Jason Lemrond on 9/13/16.
//  Copyright © 2016 Jason Lemrond. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class UserData {

    var json: JSON?
    var accessToken: String?

    static let sharedInstance = UserData()

    var bio: String? {
        print(json)
        guard let data = json,
            let bio = data[DataKeys.data][DataKeys.bio].string else {
                return nil
        }

        return bio
    }

    var followedBy: Int? {
        guard let data = json,
            let followedBy = data[DataKeys.count][DataKeys.followedBy].int else {
                return nil
        }

        return followedBy
    }

    var following: Int? {
        guard let data = json,
            let following = data[DataKeys.count][DataKeys.follows].int else {
                return nil
        }

        return following
    }

    var fullname: String? {
        guard let data = json,
            let name = data[DataKeys.fullName].string else {
                return nil
        }

        return name
    }

    var id: Int? {
        guard let data = json,
            let id = data[DataKeys.id].int else {
                return nil
        }

        return id
    }

    var profilePictureURL: NSURL? {
        guard let data = json,
            let url = data[DataKeys.profilePictureURL].string else {
                return nil
        }

        return NSURL(string: url)
    }

    var username: String? {
        guard let data = json,
            let username = data[DataKeys.username].string else {
                return nil
        }

        return username
    }

    var website: NSURL? {
        guard let data = json,
            let website = data[DataKeys.website].string else {
                return nil
        }

        return NSURL(string: website)
    }

    func isEmpty() -> Bool {
        if (UserData.sharedInstance.json != nil) {
            return true
        } else {
            return false
        }
    }


}

extension UserData {

    struct DataKeys {

        static let data = "data"
        static let bio = "bio"
        static let count = "counts"
        static let followedBy = "followed_by"
        static let follows = "follows"
        static let media = "media"
        static let fullName = "full_name"
        static let id = "id"
        static let profilePictureURL = "profile_picture"
        static let username = "username"
        static let website = "website"
        
    }
    
}
