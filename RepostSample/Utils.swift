//
//  Utils.swift
//  RepostSample
//
//  Created by Jason Lemrond on 5/27/16.
//  Copyright © 2016 Jason Lemrond. All rights reserved.
//

import Foundation
import UIKit

struct GlobalQueue {
    static var main: dispatch_queue_t {
        return dispatch_get_main_queue()
    }
    
    static var interactive: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
    }
    
    static var initiated: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
    }
    
    static var utility: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)
    }
    
    static var background: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
    }
    
    static var defaultQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_DEFAULT.rawValue), 0)
    }
}

class InstagramSearchCell : UITableViewCell {
    
    var searchType: SearchTypes?
    
}