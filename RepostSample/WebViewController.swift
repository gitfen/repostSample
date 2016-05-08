//
//  WebViewController.swift
//  RepostSample
//
//  Created by Jason Lemrond on 5/8/16.
//  Copyright © 2016 Jason Lemrond. All rights reserved.
//

import Foundation
import OAuthSwift
import UIKit

typealias WebView = UIWebView

class WebViewController: OAuthWebViewController {
    
    var targetURL = NSURL()
    var webView : WebView = WebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.frame = UIScreen.mainScreen().bounds
        webView.scalesPageToFit = true
        webView.delegate = self
        view.addSubview(self.webView)
        loadAddressURL()
    }
    
    override func handle(url: NSURL) {
        targetURL = url
        super.handle(url)
        
        loadAddressURL()
    }
    
    func loadAddressURL() {
        let req = NSURLRequest(URL: targetURL)
        webView.loadRequest(req)
    }
    
}

extension WebViewController: UIWebViewDelegate {
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.URL where (url.scheme == "repostSample") {
            dismissWebViewController()
        }
        return true
    }

}
