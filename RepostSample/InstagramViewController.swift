//
//  InstagramViewController.swift
//  RepostSample
//
//  Created by Jason Lemrond on 5/8/16.
//  Copyright © 2016 Jason Lemrond. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class InstagramViewController: UIViewController {
    
    
    // **************************************************************************************
    //   MARK: Global Variables
    // **************************************************************************************
    
    @IBOutlet weak var printButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    
    @IBOutlet weak var instagramCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var searchTableView: UITableView!
    
    var instagramImages: [InstagramImage?] = []
    var imageArray: [UIImage?]?
    
    var searchArray: [SearchData?] = []

    

    
    
    // **************************************************************************************
    //   MARK: View Load Methods
    // **************************************************************************************
    
    override func viewDidLoad() {
        print("Instagram View Loaded")
        //print(Model.data)
        
        instagramButton.hidden = true
        instagramCollectionView.hidden = true
        searchTableView.hidden = true
        
        setUpSearchBar()
        
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
    
    
    
    
    // **************************************************************************************
    //   MARK: UI Setup Methods
    // **************************************************************************************
    
    func setUpSearchBar() {
        
        // Search Bar Set Up
        
        searchBar.delegate = self
        searchBar.borderStyle = UITextBorderStyle.None
        searchBar.placeholder = "Search"
        
        
        // There may be a better way to do this
        NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: searchBar, queue: nil) { (UITextFieldTextDidChangeNotification) in
            
            guard let searchText = self.searchBar.text else {
                return
            }
            
            dispatch_async(GlobalQueue.interactive, {
                self.searchFor(searchText)
            })
            
            print(self.searchArray.count)
            
        }
        
        
        // Table View Set Up
        
        searchTableView.delegate = self
        searchTableView.dataSource = self

    }
    
    
    
    // **************************************************************************************
    //   MARK: Button Methods
    // **************************************************************************************
    
    @IBAction func printData(sender: UIButton) {
        
        instagramCollectionView.reloadData()
        print(instagramImages)
        instagramCollectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: 2, inSection: 0)])
        
        print(Model.data)
        
        printButton.hidden = true
        instagramButton.hidden = false
        
    }
    
    
    @IBAction func showImages(sender: UIButton) {
        
        dispatch_async(GlobalQueue.interactive) { () -> Void in
            self.getInstagramImages("abrilliantlie")
            self.instagramButton.hidden = true
        }
        instagramCollectionView.hidden = false
        
    }
    
    
    
    
    // **************************************************************************************
    //   MARK: Get Images Methods
    // **************************************************************************************
    
    func getInstagramImages(hashtag: String) {
        
        print("getInstagramImages called. User \(hashtag)")
        
        let accessToken = getAccessToken()
    
        guard let requestURL = NSURL(string: "https://api.instagram.com/v1/tags/\(hashtag)/media/recent/?access_token=\(accessToken)") else {
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
        
            
        let json = JSON(data: data)
        let data = json["data"]
        
        if data.count == 0 {
            // TODO: Add screen letting user know there is no data and to try seraching for something.
            print("No Data")
            return
        }
        
        // TODO: Collect Images from data verse from Instagram 
        imageArray = [UIImage?](count: data.count, repeatedValue: nil)
        instagramImages = [InstagramImage?](count: data.count, repeatedValue: nil)
        dispatch_async(GlobalQueue.main, { () -> Void in
            self.instagramCollectionView.reloadData()
        })
        
        print("Data Count: \(data.count)")
        
        for (index, data) in data {
            
            dispatch_async(GlobalQueue.initiated) {
                
                guard let index = Int(index) else {
                    return
                }
                
                self.instagramImages[index] = InstagramImage(json: data)
                
                let imageURL = data["images"]["thumbnail"]["url"].stringValue
                
                guard let url = NSURL(string: imageURL) else {
                    return
                }
                
                self.displayImageFromURL(url, index: index)
                    
            }
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
    
    
    
    
    
    // **************************************************************************************
    //   MARK: Segue Methods
    // **************************************************************************************
   
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





// ******************************************************************************************
//   MARK: Collection View Extensions
// ******************************************************************************************

extension InstagramViewController : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if instagramImages.count > 0 {
            return instagramImages.count
        } else {
            return 20
        }
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
        
        // TODO: Combine arrays into dictionary.
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
        let cellSize = (screenWidth - 10) / 3
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
    
}





// ******************************************************************************************
//   MARK: Search Field Extensions
// ******************************************************************************************

// Search Functions
extension InstagramViewController {
    
    func searchFor(string: String) {
        
        let accessToken = getAccessToken()
        
        guard let requestURL = NSURL(string: "https://api.instagram.com/v1/tags/search?q=\(string)&access_token=\(accessToken)") else {
            print("no requestURL")
            return
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(requestURL) {
            (data, response, error) in
            
            guard let httpResponse = response as? NSHTTPURLResponse else {
                print("Error: No Response from server")
                return
            }
            
            if httpResponse.statusCode == 200 {
                guard let data = data else {
                    return
                }
                
                let json = JSON(data: data)
                let jsonData = json["data"]
                self.searchArray = [SearchData?](count: jsonData.count, repeatedValue: nil)
                
                for (index, data) in jsonData {
                    
                    guard let index = Int(index) else { return }
                    
                    self.searchArray[index] = SearchData(name: data["name"].stringValue, mediaCount: data["media_count"].intValue)
                    
                }
                
                dispatch_async(GlobalQueue.main, {
                    print("reload")
                    self.searchTableView.reloadData()
                })
                
            }
            
        }
        task.resume()
    }
    
}



extension InstagramViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == searchBar {
            searchTableView.hidden = false
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == searchBar {
            searchTableView.hidden = true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        guard let hashtag = textField.text else {
            print("No Data in search field")
            return true
        }
        
        let trimmedHashtag = hashtag.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        print(trimmedHashtag)
        
        getInstagramImages(trimmedHashtag)
        
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.text == " ") {
            textField.text = ""
            return true
        }
        
        return true
    }
    
}




extension InstagramViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let searchCell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("serachCell")! as UITableViewCell
        
        guard let cellData = searchArray[indexPath.item] else {
            print("No Data Available for Search Cell")
            return UITableViewCell()
        }
        
        if let name = cellData.name {
            searchCell.textLabel?.text = name
        } else {
            searchCell.textLabel?.text = ""
        }
        
        if let mediaCount = cellData.mediaCount {
            searchCell.detailTextLabel?.text = String(mediaCount)
        } else {
            searchCell.detailTextLabel?.text = ""
        }
        
        return searchCell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchArray.count
    }
    
    
}
















