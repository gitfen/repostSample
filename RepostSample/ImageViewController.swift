//
//  ImageViewController.swift
//  RepostSample
//
//  Created by Jason Lemrond on 5/29/16.
//  Copyright © 2016 Jason Lemrond. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ImageViewController : UIViewController {
    
    @IBOutlet weak var repostImage: UIImageView!
    
    var imageData: InstagramImage!
    
    @IBAction func printData(sender: AnyObject) {
        
        print(imageData.json)
        
    }
    
}
