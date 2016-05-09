//
//  Model.swift
//  RepostSample
//
//  Created by Jason Lemrond on 5/8/16.
//  Copyright © 2016 Jason Lemrond. All rights reserved.
//

import Foundation

struct Model {
    
    var name: String
    var data: AnyObject
    
    init(name: String, data: AnyObject) {
        self.name = name
        self.data = data
    }
    
}
