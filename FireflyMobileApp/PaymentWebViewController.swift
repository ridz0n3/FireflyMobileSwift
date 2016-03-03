//
//  PaymentWebViewController.swift
//  FireflyMobileApp
//
//  Created by ME-Tech Mac User 1 on 1/6/16.
//  Copyright © 2016 Me-tech. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON

class PaymentWebViewController: BaseViewController, UIScrollViewDelegate, WKScriptMessageHandler, UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate {
    
    @IBOutlet var contentView: UIView! = nil
    
    var paymentType = String()
    var webView: WKWebView?
    var urlString = String()
    var signature = String()
    
    override func loadView() {
        super.loadView()
        
        let contentController = WKUserContentController()
        contentController.addScriptMessageHandler(
            self,
            name: "callbackHandler"
        )
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.webView = WKWebView(frame: self.view.frame, configuration: config)
        self.view = self.webView!
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if paymentType == "CI" || paymentType == "PX"{
            setupLeftButton()
        }else{
           setupMenuButton()
        }
        
        let url = NSURL(string: urlString)
        let req = NSURLRequest(URL: url!)
        self.webView?.navigationDelegate = self
        self.webView!.UIDelegate = self;
        self.webView!.loadRequest(req)
        // Do any additional setup after loading the view.
    }
    
    var count = 0
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        webView.sizeToFit()
        
        if count == 1{
            showHud("close")
        }
        
        count++
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        showHud("close")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        let check = String(navigationAction.request.URL).componentsSeparatedByString("paymentDDProcess")
        
        if check.count == 1{
            
            if ((navigationAction.targetFrame?.mainFrame) == nil){
                
                let url = navigationAction.request.URL
                let app = UIApplication.sharedApplication() as UIApplication
                
                if app.canOpenURL(url!){
                    app.openURL(url!)
                }
                
                //self.webView?.loadRequest(navigationAction.request)
            }
        }else{
            showHud("open")
            self.webView?.loadRequest(navigationAction.request)
        }
        return nil;
    }
    
    func userContentController(userContentController: WKUserContentController,didReceiveScriptMessage message: WKScriptMessage) {
        //showHud("close")
        if(message.name == "callbackHandler") {
            showHud("open")
            FireFlyProvider.request(.FlightSummary(signature), completion: { (result) -> () in
                showHud("close")
                switch result {
                case .Success(let successResult):
                    do {
                        let json = try JSON(NSJSONSerialization.JSONObjectWithData(successResult.data, options: .MutableContainers))
                        
                        if json["status"] == "success"{
                            
                            defaults.setObject(json.object, forKey: "itinerary")
                            defaults.synchronize()
                            
                            let storyboard = UIStoryboard(name: "BookFlight", bundle: nil)
                            let flightSummaryFlightVC = storyboard.instantiateViewControllerWithIdentifier("FlightSummaryVC") as! FlightSummaryViewController
                            self.navigationController!.pushViewController(flightSummaryFlightVC, animated: true)
                            
                        }else if json["status"] == "error"{
                            //showErrorMessage(json["message"].string!)
                            showErrorMessage(json["message"].string!)
                        }
                    }
                    catch {
                        
                    }
                    
                case .Failure(let failureResult):
                    showErrorMessage(failureResult.nsError.localizedDescription)
                }
            })
        }
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
