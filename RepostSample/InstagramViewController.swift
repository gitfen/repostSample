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
    
    
    // *****************************
    //   MARK: Global Variables
    // *****************************
    
    @IBOutlet weak var printButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    
    @IBOutlet weak var instagramCollectionView: UICollectionView!
    
    var instagramImages = []
    var imageArray: [UIImage?]?
    

    
    // *****************************
    //   MARK: View Load Methods
    // *****************************
    
    override func viewDidLoad() {
        print("Instagram View Loaded")
        //print(Model.data)
        
        instagramButton.hidden = true
        instagramCollectionView.hidden = true
        
        getData()
        
    }
    
    func getData() {
        
        print(Model.data)
        instagramButton.hidden = false
        printButton.hidden = true
        
        
        // TODO: Add KVO or Observe pattern to Model.

//        dispatch_async(GlobalQueue.interactive) { () -> Void in
//            print("STUFF")
//            self.getInstagramImages("123")
//        }

        
    }
    
    
    
    
    // *****************************
    //   MARK: Button Methods
    // *****************************
    
    @IBAction func printData(sender: UIButton) {
        
        instagramImages = ["ONE", "TWO", "THREE", "FOUR"]
        instagramCollectionView.reloadData()
        print(instagramImages)
        instagramCollectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: 2, inSection: 0)])
        
        print(Model.data)
        
        printButton.hidden = true
        instagramButton.hidden = false
        
    }
    
    
    @IBAction func showImages(sender: UIButton) {
        
        dispatch_async(GlobalQueue.interactive) { () -> Void in
            self.getInstagramImages("123")
            self.instagramButton.hidden = true
        }
        instagramCollectionView.hidden = false
        
    }
    
    
    
    
    // *****************************
    //   MARK: Get Image Methods
    // *****************************
    
    func getInstagramImages(userId: String) {
        
        print("getInstagramImages called. User \(userId)")
        
        let accessToken = getAccessToken()
    
        guard let requestURL = NSURL(string: "https://api.instagram.com/v1/users/706215427/media/recent/?access_token=\(accessToken)") else {
            print("no requestURL")
            return
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(requestURL) {
            (data, response, error) -> Void in
            
            guard let httpResponse = response as? NSHTTPURLResponse else {
                print("Error: No Response from server")
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                
                print("Instagram API Request Successful")
                
                guard let data = data else {
                    print("Error: No Data sent by API")
                    return
                }
                
                self.parseJSONData(data)
                
            }
    
        }
        
        task.resume()
        
        
    }
    
    
    /// Returns the Access Token for the current user from OAuth.
    func getAccessToken() -> String {
        
        guard let token = Model.accessToken else {
            print("Error: No Access Token Available")
            return "Error: No Access Token Available"
        }
        
        return String(token)
        
    }
    
    
    /// Get Images from json data.
    func parseJSONData(data: NSData) {
        
        print("parseJSONData Called.")
        
        do {
            
            let json: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            guard let data = json["data"] as? [[String: AnyObject]] else {
                print("Error: No Data Found")
                return
            }
            
            // TODO: Collect Images from data verse from Instagram 
            imageArray = [UIImage?](count: data.count, repeatedValue: nil)
            instagramImages = data
            dispatch_async(GlobalQueue.main, { () -> Void in
                self.instagramCollectionView.reloadData()
            })
            
            print("Data Count: \(instagramImages.count)")
            
            for (index, data) in instagramImages.enumerate() {
                
                dispatch_async(GlobalQueue.initiated) {
                    
//                    let info = InstagramImage(data: data as! [String : AnyObject], index: index)
//                
//                    guard let type = data["type"] as? String else {
//                        print("Error: Type (Image or Video) not found")
//                        return
//                    }
                    
                        
                    guard let images = data["images"] as? [String: AnyObject],
                    let standardResolution = images["standard_resolution"] as? [String: AnyObject],
                    let imageURL = standardResolution["url"] as? String else {
                            return
                    }
                    
                    guard let url = NSURL(string: imageURL) else {
                        return
                    }
                    
                    self.displayImageFromURL(url, index: index)
                        
                }
            }
            
        } catch {
            
            print("Error: No JSON Data")
            
        }
        
    }
    
    
    /// Get Image Data From URL and call function to Display the image.
    func displayImageFromURL(url: NSURL, index: Int) {
        
        print("Display Image From URL called. URL: \(url)")
        
        let request = NSURLRequest(URL: url)
        let imgSession = NSURLSession.sharedSession()
        let imgTask = imgSession.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            guard let data = data else {
                return
            }
            
            print("Image Returned: \(index)")
            
            self.displayImageWithData(data, index: index)
            
        }
        
        imgTask.resume()
        
    }
    
    
    /// Display Images
    func displayImageWithData(data: NSData, index: Int) {
        
        dispatch_async(GlobalQueue.main) {
            let image = UIImage(data: data)
            
            if (self.imageArray != nil) {
                print("Image Updated: \(index)")
                self.imageArray![index] = image
                self.instagramCollectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showImage" {
            
            let indexPaths = self.instagramCollectionView.indexPathsForSelectedItems()
            
            guard let pathArray = indexPaths else {
                return
            }
            
            let indexPath = pathArray[0] as NSIndexPath
            
            let imageViewController = segue.destinationViewController as! ImageViewController
            
            imageViewController.imageData = instagramImages[indexPath.row]
            
            
        }
        
    }
    
}  // End View Controller




extension InstagramViewController : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return instagramImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("instagramCell", forIndexPath: indexPath) as! InstagramCollectionCell
        
        guard let array = imageArray else {
            return cell
        }
        
        if let image = array[indexPath.item] {
            cell.cellImage.image = image
        }

        cell.backgroundColor = UIColor.blackColor()
        return cell
        
        // TODO: Pull images from array of data instead of array of images.
    }
    
}


extension InstagramViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showImage", sender: self)
    }
    
}


extension InstagramViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        let screenWidth = screenSize.width
        let cellSize = (screenWidth - 2) / 3
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
    
}
