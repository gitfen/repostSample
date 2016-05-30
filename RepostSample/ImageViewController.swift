//
//  ImageViewController.swift
//  RepostSample
//
//  Created by Jason Lemrond on 5/29/16.
//  Copyright © 2016 Jason Lemrond. All rights reserved.
//

import Foundation
import UIKit

class ImageViewController : UIViewController {
    
    @IBOutlet weak var repostImage: UIImageView!
    
    var imageData: AnyObject!
    
    @IBAction func printData(sender: AnyObject) {
        
        print(imageData)
        
    }
    
}
