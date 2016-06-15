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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayImage()
    }
    
    
    @IBAction func printData(sender: AnyObject) {
        
    }
    
    func displayImage() {
        guard let url = imageData.getImageURL() else {
            return
        }
        
        dispatch_async(GlobalQueue.interactive) { () -> Void in
            self.imageData.getImageWithURL(url) { () -> Void in
                dispatch_async(GlobalQueue.main){ () -> Void in
                    print(self.imageData.image)
                    self.repostImage.image = self.imageData.image
                }
            }
        }
        
    }
    
}
