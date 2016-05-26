//
//  Model.swift
//  RepostSample
//
//  Created by Jason Lemrond on 5/8/16.
//  Copyright © 2016 Jason Lemrond. All rights reserved.
//

import Foundation

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
