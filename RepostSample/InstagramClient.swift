//
//  InstagramClient.swift
//  RepostSample
//
//  Created by Jason Lemrond on 9/13/16.
//  Copyright © 2016 Jason Lemrond. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct InstagramClient: Networkable {

    static let sharedInstance = InstagramClient()

    func loadImagesOnLogin(completion: (error: String?) -> Void) {

        getInstagramImages(.likedImages, query: nil) { (error) in
            guard error == nil else {
                return
            }

            completion(error: nil)

        }
    }


    func getInstagramImages(method: Methods, query: String?, completionHandler: (error: String?) -> Void) {

        guard let url = buildInstagramURL(method, parameter: query) else {
            completionHandler(error: "Unable to create URL")
            return
        }

        let request = NSMutableURLRequest(URL: url)

        makeAPIRequest(request) { (result, error) in
            guard error == nil else {
                completionHandler(error: error?.localizedDescription)
                return
            }

            guard let data = result as? NSData else {
                return
            }

            self.parseReturnedData(data, completionHandler: { (error) in
                completionHandler(error: error)
            })

        }

    }

    func parseReturnedData(data: NSData, completionHandler: (error: String?) -> Void) {

        let json = JSON(data: data)
        let jsonData = json["data"]


        if jsonData.count == 0 {
            completionHandler(error: "No Images Returned")
            return
        }

        SearchViewImages.sharedInstance.images = [InstagramImage?](count: jsonData.count, repeatedValue: nil)

        performHighPriority { 
            for (index, image) in jsonData {

                guard let index = Int(index) else {
                    return
                }

                SearchViewImages.sharedInstance.images[index] = InstagramImage(json: image)


            }

            completionHandler(error: nil)
        }

    }


    func buildInstagramURL(method: Methods, parameter: String?) -> NSURL? {

        let accessToken = getAccessToken()

        var endPath: String
        var query: String
        switch method {
        case .getUserInfo:
            endPath = "self/"
            query = "access_token=\(accessToken)"
        case .likedImages:
            endPath = "self/media/liked"
            query = "access_token=\(accessToken)"
        default:
            print("Unable to create URL")
            return nil
        }

        let components = NSURLComponents()
        components.scheme = URL.scheme
        components.host = URL.host
        components.path = URL.basePath + endPath
        components.query = query

        print(components.URL!)

        return components.URL!
        
    }


    /// Returns the Access Token for the current user from OAuth.
    func getAccessToken() -> String {

        guard let token = UserData.sharedInstance.accessToken else {
            print("Error: No Access Token Available")
            return "Error: No Access Token Available"
        }

        return String(token)

    }

}


extension InstagramClient {

    struct URL {
        static let scheme = "https"
        static let host = "api.instagram.com"
        static let basePath = "/v1/users/"
    }

    enum Methods: String {
        case getUserInfo = "UserInfo"
        case searchHashtags = "Hashtags"
        case searchUsers = "People"
        case likedImages = "like images"
    }



}


