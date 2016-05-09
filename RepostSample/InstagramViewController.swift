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
//        let loginViewController: ViewController = ViewController()
//        let userInfo = loginViewController.userInfo
//        guard let data = userInfo?.data else {
//            return
//        }
//        
//        print(data)
    }
    
    
    @IBAction func printData(sender: UIButton) {
        
        let loginViewController: ViewController = ViewController()
        let userInfo = loginViewController.userInfo
        let data = userInfo.name
        
        print(data)
        
    }
    
    
}
