//
//  FAQViewController.swift
//  FireflyMobileApp
//
//  Created by ME-Tech MacPro User 2 on 2/2/16.
//  Copyright © 2016 Me-tech. All rights reserved.
//

import UIKit
import SwiftyJSON
import WebKit

class FAQViewController: BaseViewController, UIScrollViewDelegate, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //If you want to implement the delegate
        
        self.setupLeftButton()
        webView.scrollView.delegate = self
        webView.scrollView.showsHorizontalScrollIndicator = false
        showHud("open")
        
        FireFlyProvider.request(.GetTerm) { (result) -> () in
            switch result {
            case .Success(let successResult):
                do {
                    
                    let json = try JSON(NSJSONSerialization.JSONObjectWithData(successResult.data, options: .MutableContainers))
                    
                    if json["status"] == "success"{
                        print(json["url"])
                        
                        if let url = NSURL(string: json["url"].stringValue){
                            let request = NSURLRequest(URL: url)
                            self.webView.loadRequest(request)
                        }
                    }else if json["status"] == "error"{
                        //showToastMessage(json["message"].string!)
                                showErrorMessage(json["message"].string!)
                        showHud("close")
                    }
                }
                catch {
                    
                }
            case .Failure(let failureResult):
                print (failureResult)
                showHud("close")
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.sizeToFit()
        showHud("close")
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        showHud("close")
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.x > 0)
        {
            scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y)
        }
    }
    
}