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
    
    var instagramImages: [InstagramImage?]  = []
    var imageArray:      [UIImage?]?
    
    var searchSection:   [SearchTypes?]     = [nil]
    var searchArray:     [SearchData?]      = []
    var usersSearch:     [UsersSearchData?] = []

    

    
    
    // **************************************************************************************
    //   MARK: View Load Methods
    // **************************************************************************************
    
    override func viewDidLoad() {
        print("Instagram View Loaded")
        
        instagramButton.hidden = true
        searchTableView.hidden = true
        
        setUpSearchBar()

        InstagramClient.sharedInstance.loadImagesOnLogin { (error) in
            guard error == nil else {
                self.displayOneButtonAlert("Alert", message: error)
                print(error)
                return
            }

            print(SearchViewImages.sharedInstance.images.count)

            performOnMain({ 
                self.instagramCollectionView.reloadData()
                self.displayImagesFromURLs()
            })

        }
        
        getData()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)


        print("ViewWillAppear")

    }
    
    func getData() {
        
        print(UserData.sharedInstance.json)
        instagramButton.hidden = false
        printButton.hidden = true
        
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
                
                self.searchArray = []
                self.usersSearch = []
                
                self.searchFor(SearchTypes.Hashtag, query: searchText)
                self.searchFor(SearchTypes.Users, query: searchText)
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
        
        print(UserData.sharedInstance.json)
        
        printButton.hidden = true
        instagramButton.hidden = false
        
    }
    
    
    @IBAction func showImages(sender: UIButton) {
        instagramCollectionView.reloadData()
//        
//        dispatch_async(GlobalQueue.interactive) { () -> Void in
//            self.getInstagramImages(using: SearchTypes.Hashtag, query: "abrilliantlie")
//            self.instagramButton.hidden = true
//        }
//        instagramCollectionView.hidden = false

    }

    func test() {
        dispatch_async(GlobalQueue.interactive) { () -> Void in
            self.getInstagramImages(using: SearchTypes.Hashtag, query: "abrilliantlie")
            //self.instagramButton.hidden = true
        }
        // instagramCollectionView.hidden = false
    }

    
    
    
    // **************************************************************************************
    //   MARK: Get Images Methods
    // **************************************************************************************
    
    func getInstagramImages(using searchType: SearchTypes, query: String) {
        
        print("getInstagramImages called. URL: \(query)")
        
        let accessToken = getAccessToken()
        var urlInsert: String
        
        switch searchType {
        case .Hashtag:
            urlInsert = "tags/\(query)"
        case .Users:
            urlInsert = "users/\(query)"
        }
        
        guard let requestURL = NSURL(string: "https://api.instagram.com/v1/\(urlInsert)/media/recent/?access_token=\(accessToken)") else {
            print("no requestURL")
            return
        }
        
        print("Request URL: \(requestURL)")
        
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
        
        guard let token = UserData.sharedInstance.accessToken else {
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
                    
            }
        }
    }

    func displayImagesFromURLs() {

        for (index, image) in SearchViewImages.sharedInstance.images.enumerate() {

            guard let image = image else {
                return
            }

            guard let url = image.getImageURL() else {
                return
            }

            image.getImageWithURL(url, completionHandler: {
                performOnMain({ 
                    self.instagramCollectionView.reloadData()
                })
            })

        }

    }
    
    
    /// Get Image Data From URL and call function to Display the image.
//    func displayImageFromURL(url: NSURL, index: Int) {
//        
//        print("Display Image From URL called. URL: \(url)")
//        
//        let request = NSURLRequest(URL: url)
//        let imgSession = NSURLSession.sharedSession()
//        let imgTask = imgSession.dataTaskWithRequest(request) {
//            (data, response, error) -> Void in
//            
//            guard let data = data else {
//                return
//            }
//            
//            print("Image Returned: \(index)")
//            
//            self.displayImageWithData(data, index: index)
//            
//        }
//        
//        imgTask.resume()
//        
//    }

    
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
            
            imageViewController.imageData = SearchViewImages.sharedInstance.images[indexPath.row]
            
        }
        
    }
    
}  // End View Controller





// ******************************************************************************************
//   MARK: Collection View Extensions
// ******************************************************************************************

extension InstagramViewController : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return SearchViewImages.sharedInstance.images.count

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("instagramCell", forIndexPath: indexPath) as! InstagramCollectionCell

        if let image = SearchViewImages.sharedInstance.images[indexPath.item]?.image {
            cell.cellImage.image = image
        }

        cell.backgroundColor = UIColor.whiteColor()
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
        
        let screenWidth = CGFloat(screenSize.width)
        let cellSize = (screenWidth - 10) / 3
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
    
}





// ******************************************************************************************
//   MARK: Search Field Extensions
// ******************************************************************************************

// Search Functions
extension InstagramViewController {
    
    func searchFor(type: SearchTypes, query: String) {
        
        let accessToken = getAccessToken()
        var url: String
        
        switch type {
            case .Hashtag: url = "https://api.instagram.com/v1/tags/search?q=\(query)&access_token=\(accessToken)"
            case .Users: url = "https://api.instagram.com/v1/users/search?q=\(query)&access_token=\(accessToken)"
        }
        
        guard let requestURL = NSURL(string: url) else {
            print("Error: No Request URL")
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
                
                switch type {
                    case .Hashtag:
                        
                        self.searchArray = [SearchData?](count: jsonData.count, repeatedValue: nil)
                        
                        for (index, data) in jsonData {
                            
                            guard let index = Int(index) else { return }
                            
                            self.searchArray[index] = SearchData(name: data["name"].stringValue, mediaCount: data["media_count"].intValue)
                            print("Hashtag: \(self.searchArray[index]?.name)")
                            
                        }
                        
                        
                    case .Users:
                        self.usersSearch = [UsersSearchData?](count: jsonData.count, repeatedValue: nil)
                    
                        for (index, data) in jsonData {
                            
                            guard let index = Int(index) else { return }
                            
                            self.usersSearch[index] = UsersSearchData(jsonData: data)
                            print("Username: \(self.usersSearch[index]?.username)")
                            
                        }
                    
                    
                }
                
                
                dispatch_async(GlobalQueue.main, {
                    print("reload")
                    if self.usersSearch.count > 0 && self.searchArray.count > 0 {
                        self.searchSection = [SearchTypes.Users, SearchTypes.Hashtag]
                    } else {
                        self.searchSection = [nil]
                    }
                    
                    print(self.searchSection)
                    
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
        
        // TODO: decided the top value and search that.
        getInstagramImages(using: SearchTypes.Hashtag, query: trimmedHashtag)
        
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // Protects against spaces at front of text.
        if (textField.text == " ") {
            textField.text = ""
            return true
        }
        
        return true
    }
    
}




extension InstagramViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let searchCell: InstagramSearchCell = tableView.dequeueReusableCellWithIdentifier("serachCell")! as! InstagramSearchCell
        
        var type: SearchTypes
        
        print("Counts:")
        print("SearchSection: \(searchSection.count)")
        print("HashArray: \(searchArray.count)")
        print("UserArray: \(usersSearch.count)")
        
        if searchSection[0] != nil {
            type = searchSection[indexPath.section]!
        } else if searchArray.count > 0 {
            type = SearchTypes.Hashtag
        } else if usersSearch.count > 0 {
            type = SearchTypes.Users
        } else {
            return searchCell
        }
        
        if type == SearchTypes.Users {
            
            guard let cellData = usersSearch[indexPath.item] else {
                print("No Data Available for Search Cell")
                return searchCell
            }
            
            searchCell.textLabel?.text = cellData.username
            searchCell.detailTextLabel?.text = cellData.fullName
            
        }
        
        if type == SearchTypes.Hashtag {
            
            guard let cellData = searchArray[indexPath.item] else {
                print("No Data Available for Search Cell")
                return searchCell
            }
            
            if let name = cellData.name {
                searchCell.textLabel?.text = name
            } else {
                searchCell.textLabel?.text = ""
            }
            
            // TODO: Format Number for Display
            if let mediaCount = cellData.mediaCount {
                searchCell.detailTextLabel?.text = String(mediaCount)
            } else {
                searchCell.detailTextLabel?.text = ""
            }
        
        }
        
        searchCell.searchType = type
        
        return searchCell
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchSection.count > 0 {
            return searchSection.count
        } else {
            return 1
        }
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if searchSection[0] != nil {
            return searchSection[section]?.rawValue
        }

        return nil
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchSection[0] != nil {
            if section == 0 {
                if usersSearch.count > 3 {
                    return 3
                } else {
                    return usersSearch.count
                }
            }
            
            if section == 1 {
                return searchArray.count
            }
        } else if searchArray.count > 0 {
            return searchArray.count
        } else if usersSearch.count > 0 {
            return usersSearch.count
        }
        
        // Default
        return 0
        
    }

}



extension InstagramViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchTableView.hidden = true
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! InstagramSearchCell
        print("Search Type: \(cell.searchType)")
        
        guard let searchType = cell.searchType else {
            return
        }
        
        switch searchType {
        case .Hashtag:
            guard let data = searchArray[indexPath.item] else {
                return
            }
            
            getInstagramImages(using: searchType, query: data.name)
        case .Users:
            guard let data = usersSearch[indexPath.item] else {
                return
            }
            
            getInstagramImages(using: searchType, query: data.id)
        }
        
    }
    
}
















