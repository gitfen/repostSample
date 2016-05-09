//
//  InstagramViewController.swift
//  RepostSample
//
//  Created by Jason Lemrond on 5/8/16.
//  Copyright © 2016 Jason Lemrond. All rights reserved.
//

import Foundation
import UIKit

class InstagramViewController: UIViewController {
    
    override func viewDidLoad() {
        print("Instagram View Loaded")
        print(Model.data)
        
        getData()
    }
    
    func getData() {
        if (Model.data != nil) {
            getData()
        }
        
        print(Model.data)
    }
    
    
    @IBAction func printData(sender: UIButton) {
        
        print(Model.data)
        
    }
    
    
}
