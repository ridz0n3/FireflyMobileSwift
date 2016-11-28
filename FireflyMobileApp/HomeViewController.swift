//
//  HomeViewController.swift
//  FireflyMobileApp
//
//  Created by ME-Tech Mac User 1 on 11/16/15.
//  Copyright © 2015 Me-tech. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SCLAlertView
import RealmSwift
import SlideMenuControllerSwift
import Crashlytics


class HomeViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, SlideMenuControllerDelegate {
    
    @IBOutlet weak var homeMenuTableView: UITableView!
    
    var menuTitle:[String] = ["","LabelHomeBookFlight".localized, "LabelHomeManageFlight".localized, "LabelHomeMobileCheckIn".localized, "LabelHomeBoardingPass".localized,""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHomeButton()
        
        if defaults.object(forKey: "notif") != nil{
            if (defaults.object(forKey: "notif") as AnyObject).classForCoder != NSString.classForCoder(){
                let userInfo = defaults.object(forKey: "notif") as! NSDictionary
                let alert = userInfo["aps"]! as! NSDictionary
                let message = alert["alert"]! as! NSDictionary
                
                showNotif(message["title"] as! String, message : message["body"] as! String)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.refreshTable(_:)), name: NSNotification.Name(rawValue: "reloadHome"), object: nil)
        AnalyticsManager.sharedInstance.logScreen(GAConstants.homeScreen)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //TODO: Get the URL from Backend
    func facebookSelected(_ sender: UIGestureRecognizer) {
        //Crashlytics.sharedInstance().crash()
        //AnalyticsManager.sharedInstance.logScreen(GAConstants.facebookScreen)
        let facebookHooks = "fb://profile/\(defaults.object(forKey: "facebook") as! String)"
        let facebookURL = URL(string: facebookHooks)
        if UIApplication.shared.canOpenURL(facebookURL!)
        {
            UIApplication.shared.openURL(facebookURL!)
            
        } else {
            //redirect to safari because the user doesn't have Instagram
            UIApplication.shared.openURL(URL(string: "https://www.facebook.com/\(defaults.object(forKey: "facebook") as! String)")!)
        }
    }
    
    func instaSelected(_ sender: UIGestureRecognizer) {
        //AnalyticsManager.sharedInstance.logScreen(GAConstants.instagramScreen)
        let instagramHooks = "instagram://user?username=\(defaults.object(forKey: "instagram") as! String)"
        let instagramUrl = URL(string: instagramHooks)
        if UIApplication.shared.canOpenURL(instagramUrl!)
        {
            UIApplication.shared.openURL(instagramUrl!)
            
        } else {
            //redirect to safari because the user doesn't have Instagram
            UIApplication.shared.openURL(URL(string: "https://www.instagram.com/\(defaults.object(forKey: "instagram") as! String)")!)
        }
    }
    
    func twitterSelected(_ sender: UIGestureRecognizer) {
        //AnalyticsManager.sharedInstance.logScreen(GAConstants.twitterScreen)
        let twitterHooks = "twitter:///user?screen_name=\(defaults.object(forKey: "twitter") as! String)"
        let twitterUrl = URL(string: twitterHooks)
        if UIApplication.shared.canOpenURL(twitterUrl!)
        {
            UIApplication.shared.openURL(twitterUrl!)
            
        } else {
            //redirect to safari because the user doesn't have Instagram
            UIApplication.shared.openURL(URL(string: "https://twitter.com/\(defaults.object(forKey: "twitter") as! String)")!)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0
        {
            return self.view.frame.size.width
            
        }
        else if indexPath.row == 5 {
            
            return 38
            
        }else {
            
            return 55
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! CustomHomeMenuTableViewCell
            if (defaults.object(forKey: "banner") != nil){
                let imageURL = defaults.object(forKey: "banner") as! String
                
                Alamofire.request(imageURL).response(completionHandler: { response in
                    cell.banner.image = UIImage(data: response.data!)
                    //self.rule1Img.image = UIImage(data: response.data!)
                })
            }
            return cell
        }
        else if indexPath.row == 5{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SocialCell", for: indexPath)
            let facebookView = cell.viewWithTag(1)
            let facebookSelected = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.facebookSelected(_:)))
            facebookView?.addGestureRecognizer(facebookSelected)
            let twitterSelected = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.twitterSelected(_:)))
            let twitterView = cell.viewWithTag(2)
            twitterView?.addGestureRecognizer(twitterSelected)
            let instaView = cell.viewWithTag(3)
            let instaSelected = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.instaSelected(_:)))
            instaView?.addGestureRecognizer(instaSelected)
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomHomeMenuTableViewCell
            
            let replaced = menuTitle[indexPath.row].replacingOccurrences(of: " ", with: "bg.png")//.stringByReplacingOccurrencesOfString(" ", withString: "")
            
            cell.bgView.backgroundColor = UIColor(patternImage: UIImage(named: "bg.png")!)
            cell.menuLbl?.text = menuTitle[indexPath.row]
            cell.menuIcon.image = UIImage(named: replaced)
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0{
            
            if (defaults.object(forKey: "url") != nil){
                
                if defaults.object(forKey: "url") as! String != ""{
                    
                    let url = URL(string: defaults.object(forKey: "url") as! String)!
                    UIApplication.shared.openURL(url)
                    
                }else if (defaults.object(forKey: "module") != nil){
                    if defaults.object(forKey: "module") as! String == "faq"{
                        let storyboard = UIStoryboard(name: "Home", bundle: nil)
                        let FAQVC = storyboard.instantiateViewController(withIdentifier: "FAQVC") as! FAQViewController
                        FAQVC.secondLevel = true
                        self.navigationController!.pushViewController(FAQVC, animated: true)
                    }else{
                        let storyboard = UIStoryboard(name: "BookFlight", bundle: nil)
                        let bookFlightVC = storyboard.instantiateViewController(withIdentifier: "BookFlightVC") as! SearchFlightViewController
                        self.navigationController!.pushViewController(bookFlightVC, animated: true)
                    }
                }
                
            }else if (defaults.object(forKey: "module") != nil){
                if defaults.object(forKey: "module") as! String == "faq"{
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    let FAQVC = storyboard.instantiateViewController(withIdentifier: "FAQVC") as! FAQViewController
                    FAQVC.secondLevel = true
                    self.navigationController!.pushViewController(FAQVC, animated: true)
                }else{
                    let storyboard = UIStoryboard(name: "BookFlight", bundle: nil)
                    let bookFlightVC = storyboard.instantiateViewController(withIdentifier: "BookFlightVC") as! SearchFlightViewController
                    self.navigationController!.pushViewController(bookFlightVC, animated: true)
                }
            }
           // let url = NSURL(string: "https://google.com")!
           // UIApplication.sharedApplication().openURL(url)
            
        }else if indexPath.row == 1{
            
            let storyboard = UIStoryboard(name: "BookFlight", bundle: nil)
            let bookFlightVC = storyboard.instantiateViewController(withIdentifier: "BookFlightVC") as! SearchFlightViewController
            self.navigationController!.pushViewController(bookFlightVC, animated: true)
            
        }else if indexPath.row == 2{
            if try! LoginManager.sharedInstance.isLogin(){
                let userinfo = defaults.object(forKey: "userInfo") as! NSDictionary//[String: String]
                showLoading()
                
                FireFlyProvider.request(.RetrieveBookingList(userinfo["username"]! as! String, userinfo["password"]! as! String, "manage_booking", defaults.object(forKey: "customer_number") as! String), completion: { (result) -> () in
                    switch result {
                    case .success(let successResult):
                        do {
                            
                            let json = try JSON(JSONSerialization.jsonObject(with: successResult.data, options: .mutableContainers))
                            
                            var activeFlight = [AnyObject]()
                            var notActiveFlight = [AnyObject]()
                            if json["status"] == "success"{
                                if json["list_booking"].count != 0{
                                    
                                    for tempData in json["list_booking"].arrayObject!{
                                        let data = tempData as! NSDictionary
                                        let formater = DateFormatter()
                                        formater.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
                                        
                                        let twentyFour = Locale(identifier: "en_GB")
                                        formater.locale = twentyFour
                                        let newDate = formater.date(from: data["departure_datetime"] as! String)
                                        let today = Date()
                                        if today.compare(newDate!) == ComparisonResult.orderedAscending{
                                            activeFlight.append(data as AnyObject)
                                        }else{
                                            notActiveFlight.append(data as AnyObject)
                                        }
                                    }
                                    
                                    var newFormatedBookingList = [String : AnyObject]()
                                    newFormatedBookingList.updateValue(activeFlight as AnyObject, forKey: "Active")
                                    newFormatedBookingList.updateValue(notActiveFlight as AnyObject, forKey: "notActive")
                                    /*
                                    if activeFlight.count != 0 && notActiveFlight.count != 0{
                                        newFormatedBookingList.updateValue(activeFlight, forKey: "Active")
                                        newFormatedBookingList.updateValue(notActiveFlight, forKey: "notActive")
                                    }else if activeFlight.count != 0 && notActiveFlight.count == 0{
                                        newFormatedBookingList.updateValue(activeFlight, forKey: "Active")
                                    }else if activeFlight.count == 0 && notActiveFlight.count != 0{
                                        newFormatedBookingList.updateValue(activeFlight, forKey: "notActive")
                                    }*/
                                    //print(newFormatedBookingList)
                                    
                                    let storyboard = UIStoryboard(name: "ManageFlight", bundle: nil)
                                    let manageFlightVC = storyboard.instantiateViewController(withIdentifier: "LoginManageFlightVC") as! LoginManageFlightViewController
                                    manageFlightVC.userId = "\(json["user_id"])"
                                    manageFlightVC.signature = json["signature"].string!
                                    manageFlightVC.listBooking = json["list_booking"].arrayObject! as NSArray
                                    manageFlightVC.groupBookingList = newFormatedBookingList
                                    self.navigationController!.pushViewController(manageFlightVC, animated: true)
                                }else{
                                    
                                    // Create custom Appearance Configuration
                                    let appearance = SCLAlertView.SCLAppearance(
                                        kCircleIconHeight: 40,
                                        kTitleFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                                        kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                                        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                                        showCircularIcon: true
                                    )
                                    let alertViewIcon = UIImage(named: "alertIcon")
                                    let alert = SCLAlertView(appearance:appearance)
                                    alert.showInfo("Manage Flight", subTitle: "You have no flight record. Please booking your flight to proceed", closeButtonTitle : "Continue", colorStyle:0xEC581A, circleIconImage: alertViewIcon)
                                }
                            }else if json["status"] == "error"{
                                
                                showErrorMessage(json["message"].string!)
                            }
                            hideLoading()
                        }
                        catch {
                            
                        }
                        
                    case .failure(let failureResult):
                        
                        hideLoading()
                        showErrorMessage(failureResult.localizedDescription)
                    }
                })
                
            }else{
                
                let storyboard = UIStoryboard(name: "ManageFlight", bundle: nil)
                let manageFlightVC = storyboard.instantiateViewController(withIdentifier: "ManageFlightVC") as! ManageFlightViewController
                self.navigationController!.pushViewController(manageFlightVC, animated: true)
            }
        }else if indexPath.row == 3{
            
            if try! LoginManager.sharedInstance.isLogin(){
                
                showLoading()
                retrieveCheckInList(false)
                /*
                let userInfo = defaults.object(forKey: "userInfo") as! NSDictionary
                var userData : Results<UserList>! = nil
                userData = realm.objects(UserList)
                let mainUser = userData.filter("userId == %@", userInfo["username"]! as! String)
                
                if mainUser.count != 0{
                    
                    if mainUser[0].checkinList.count == 0{
                        
                    }else{
                        let storyboard = UIStoryboard(name: "MobileCheckIn", bundle: nil)
                        let mobileCheckinVC = storyboard.instantiateViewController(withIdentifier: "LoginMobileCheckinVC") as! LoginMobileCheckinViewController
                        mobileCheckinVC.module = "checkIn"
                        mobileCheckinVC.userId = mainUser[0].id
                        mobileCheckinVC.signature = mainUser[0].signature
                        mobileCheckinVC.checkInList = mainUser[0].checkinList.sorted("departureDateTime", ascending: false)
                        self.navigationController!.pushViewController(mobileCheckinVC, animated: true)
                        retrieveCheckInList(true)
                    }
                    
                }else{
                    showLoading()
                    retrieveCheckInList(false)
                }*/
                
            }else{
                
                let storyboard = UIStoryboard(name: "MobileCheckIn", bundle: nil)
                let manageFlightVC = storyboard.instantiateViewController(withIdentifier: "MobileCheckInVC") as! MobileCheckinViewController
                self.navigationController!.pushViewController(manageFlightVC, animated: true)
                
            }
            
            
        }else if indexPath.row == 4{
            
            if try! LoginManager.sharedInstance.isLogin(){
                
                let userInfo = defaults.object(forKey: "userInfo") as! NSDictionary
                //var userData : Results<UserList>! = nil
                let userData = realm.objects(UserList.self)
                let mainUser = userData.filter("userId == %@", userInfo["username"]! as! String)
                
                if mainUser.count != 0{
                    
                    if mainUser[0].pnr.count == 0{
                        showLoading()
                        retrieveBoardingList(false)
                    }else{
                        let storyboard = UIStoryboard(name: "BoardingPass", bundle: nil)
                        let mobileCheckinVC = storyboard.instantiateViewController(withIdentifier: "LoginBoardingPassVC") as! LoginBoardingPassViewController
                        mobileCheckinVC.module = "boardingPass"
                        mobileCheckinVC.userId = mainUser[0].id
                        mobileCheckinVC.signature = mainUser[0].signature
                        mobileCheckinVC.pnrList = mainUser[0].pnr.sorted(byProperty: "departureDateTime", ascending: false)
                        self.navigationController!.pushViewController(mobileCheckinVC, animated: true)
                        retrieveBoardingList(true)
                    }
                }else{
                    showLoading()
                    retrieveBoardingList(false)
                }
                
            }else{
                
                let storyboard = UIStoryboard(name: "BoardingPass", bundle: nil)
                let boardingPassVC = storyboard.instantiateViewController(withIdentifier: "BoardingPassVC") as! BoardingPassViewController
                self.navigationController!.pushViewController(boardingPassVC, animated: true)
            }
        }
    }
    
    func retrieveBoardingList(_ isExist : Bool){
        let userinfo = defaults.object(forKey: "userInfo") as! NSDictionary
        //showLoading()
        FireFlyProvider.request(.RetrieveBookingList(userinfo["username"]! as! String, userinfo["password"]! as! String, "boarding_pass", defaults.object(forKey: "customer_number") as! String), completion: { (result) -> () in
            switch result {
            case .success(let successResult):
                do {
                    
                    let json = try JSON(JSONSerialization.jsonObject(with: successResult.data, options: .mutableContainers))
                    
                    if json["status"] == "success"{
                        
                        if json["list_booking"].count != 0{
                            self.saveBoardingPassList(json["list_booking"].arrayObject! as [AnyObject], userId: "\(json["user_id"])", signature: json["signature"].string!)
                            
                            if !isExist{
                                let storyboard = UIStoryboard(name: "BoardingPass", bundle: nil)
                                let mobileCheckinVC = storyboard.instantiateViewController(withIdentifier: "LoginBoardingPassVC") as! LoginBoardingPassViewController
                                mobileCheckinVC.indicator = true
                                mobileCheckinVC.module = "boardingPass"
                                self.navigationController!.pushViewController(mobileCheckinVC, animated: true)
                            }else{
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadBoardingPassList"), object: nil)
                            }
                        }else{
                            // Create custom Appearance Configuration
                            let appearance = SCLAlertView.SCLAppearance(
                                kCircleIconHeight: 40,
                                kTitleFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                                kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                                showCircularIcon: true
                            )
                            let alertViewIcon = UIImage(named: "alertIcon")
                            let alert = SCLAlertView(appearance:appearance)
                            alert.showInfo("Boarding Pass", subTitle: "You have no boarding pass record. Please check-in your flight ticket to proceed", closeButtonTitle : "Continue", colorStyle:0xEC581A, circleIconImage: alertViewIcon)
                        }
                    }else if json["status"] == "error"{
                        
                        showErrorMessage(json["message"].string!)
                    }
                    hideLoading()
                }
                catch {
                    
                }
                
            case .failure(let _):
                
                hideLoading()
                
                if !isExist{
                    let userInfo = defaults.object(forKey: "userInfo") as! NSDictionary
                    //var userData : Results<UserList>! = nil
                    let userData = realm.objects(UserList.self)
                    let mainUser = userData.filter("userId == %@", userInfo["username"]! as! String)
                    
                    if mainUser.count != 0{
                        
                        if mainUser[0].pnr.count != 0{
                            let storyboard = UIStoryboard(name: "BoardingPass", bundle: nil)
                            let mobileCheckinVC = storyboard.instantiateViewController(withIdentifier: "LoginBoardingPassVC") as! LoginBoardingPassViewController
                            mobileCheckinVC.indicator = true
                            mobileCheckinVC.module = "boardingPass"
                            //mobileCheckinVC.pnrList = mainUser[0].pnr.sorted("departureDateTime", ascending: false)
                            self.navigationController!.pushViewController(mobileCheckinVC, animated: true)
                        }else{
                            // Create custom Appearance Configuration
                            let appearance = SCLAlertView.SCLAppearance(
                                kCircleIconHeight: 40,
                                kTitleFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                                kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                                showCircularIcon: true
                            )
                            let alertViewIcon = UIImage(named: "alertIcon")
                            let alert = SCLAlertView(appearance:appearance)
                            alert.showInfo("Boarding Pass", subTitle: "You have no boarding pass record. Please check-in your flight ticket to proceed", closeButtonTitle : "Continue", colorStyle:0xEC581A, circleIconImage: alertViewIcon)
                        }
                    }else{
                        // Create custom Appearance Configuration
                        let appearance = SCLAlertView.SCLAppearance(
                            kCircleIconHeight: 40,
                            kTitleFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                            showCircularIcon: true
                        )
                        let alertViewIcon = UIImage(named: "alertIcon")
                        let alert = SCLAlertView(appearance:appearance)
                        alert.showInfo("Boarding Pass", subTitle: "You have no boarding pass record. Please check-in your flight ticket to proceed", closeButtonTitle : "Continue", colorStyle:0xEC581A, circleIconImage:alertViewIcon)
                    }
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadBoardingPassList"), object: nil)
                }
                
            }
        })
        
    }
    
    func saveBoardingPassList(_ list : [AnyObject], userId : String, signature : String){
        
        let userInfo = defaults.object(forKey: "userInfo") as! NSDictionary
        //var userList = Results<UserList>!()
        let userList = realm.objects(UserList.self)
        
        for listInfo in list{
            
            let mainUser = userList.filter("userId == %@", "\(userInfo["username"] as! String)")
            let pnr = PNRList()
            pnr.pnr = listInfo["pnr"] as! String
            
            let formater = DateFormatter()
            formater.dateFormat = "yyyy-MM-dd"
            let twentyFour = Locale(identifier: "en_GB")
            formater.locale = twentyFour
            let date = (listInfo["date"] as! String).components(separatedBy: " ")
            let new = "\(date[2])-\(date[1])-\(date[0])"
            let newdate = formater.date(from: new)
            
            pnr.departureStationCode = listInfo["departure_station_code"] as! String
            pnr.arrivalStationCode = listInfo["arrival_station_code"] as! String
            pnr.departureDateTime = newdate!
            pnr.departureDayDate = listInfo["date"] as! String
            
            if mainUser.count == 0{
                let user = UserList()
                user.userId = userInfo["username"] as! String
                user.pnr.append(pnr)
                
                try! realm.write({ () -> Void in
                    realm.add(user)
                })
            }else{
                let mainPNR = mainUser[0].pnr.filter("pnr == %@", pnr.pnr)
                if mainPNR.count != 0{
                    
                    for pnrData in mainPNR{
                        
                        if (pnrData.pnr == pnr.pnr) && pnrData.departureStationCode == pnr.departureStationCode{
                            
                            if pnrData.boardingPass.count != 0{
                                
                                for boardingInfo in pnrData.boardingPass{
                                    let boardingPass = BoardingPassList()
                                    boardingPass.name = boardingInfo.name
                                    boardingPass.departureStation = boardingInfo.departureStation
                                    boardingPass.arrivalStation = boardingInfo.arrivalStation
                                    boardingPass.departureDate = boardingInfo.departureDate
                                    boardingPass.departureTime = boardingInfo.departureTime
                                    boardingPass.boardingTime = boardingInfo.boardingTime
                                    boardingPass.fare = boardingInfo.fare
                                    boardingPass.flightNumber = boardingInfo.flightNumber
                                    boardingPass.SSR = boardingInfo.SSR
                                    boardingPass.QRCodeURL = boardingInfo.QRCodeURL
                                    boardingPass.recordLocator = boardingInfo.recordLocator
                                    boardingPass.arrivalStationCode = boardingInfo.arrivalStationCode
                                    boardingPass.departureStationCode = boardingInfo.departureStationCode
                                    
                                    pnr.boardingPass.append(boardingPass)
                                }
                                
                            }
                            
                            realm.beginWrite()
                            realm.delete(pnrData)
                            try! realm.commitWrite()
                        }
                        
                    }
                    
                }
                
                try! realm.write({ () -> Void in
                    mainUser[0].pnr.append(pnr)
                    mainUser[0].id = userId
                    mainUser[0].signature = signature
                })
                
            }
            
        }
    }
    
    func refreshTable(_ sender: NSNotification){
        self.homeMenuTableView.reloadData()
    }
    
    func retrieveCheckInList(_ isExist : Bool){
        
        let userinfo = defaults.object(forKey: "userInfo") as! NSDictionary
        FireFlyProvider.request(.RetrieveBookingList(userinfo["username"]! as! String, userinfo["password"]! as! String, "check_in", defaults.object(forKey: "customer_number") as! String), completion: { (result) -> () in
            switch result {
            case .success(let successResult):
                do {
                    
                    let json = try JSON(JSONSerialization.jsonObject(with: successResult.data, options: .mutableContainers))
                    
                    if json["status"] == "success"{
                        if json["list_booking"].count != 0{
                            
                            self.saveCheckInList(json["list_booking"].arrayObject! as NSArray, userId: "\(json["user_id"])", signature: json["signature"].string!)
                            
                            if !isExist{
                                let storyboard = UIStoryboard(name: "MobileCheckIn", bundle: nil)
                                let mobileCheckinVC = storyboard.instantiateViewController(withIdentifier: "LoginMobileCheckinVC") as! LoginMobileCheckinViewController
                                mobileCheckinVC.indicator = true
                                mobileCheckinVC.module = "checkIn"
                                self.navigationController!.pushViewController(mobileCheckinVC, animated: true)
                                hideLoading()
                            }else{
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCheckInList"), object: nil)
                            }
                        }else{
                            hideLoading()
                            
                            let userInfo = defaults.object(forKey: "userInfo") as! NSDictionary
                            //var userList = Results<UserList>!()
                            let userList = realm.objects(UserList.self)
                            let mainUser = userList.filter("userId == %@", "\(userInfo["username"] as! String)")
                            
                            if mainUser.count != 0{
                                if mainUser[0].checkinList.count != 0{
                                    realm.beginWrite()
                                    realm.delete(mainUser[0].checkinList)
                                    try! realm.commitWrite()
                                }
                            }
                            
                            // Create custom Appearance Configuration
                            let appearance = SCLAlertView.SCLAppearance(
                                kCircleIconHeight: 40,
                                kTitleFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                                kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                                showCloseButton: false,
                                showCircularIcon: true
                            )
                            let alertViewIcon = UIImage(named: "alertIcon")
                            let errorView = SCLAlertView(appearance: appearance)
                            errorView.addButton("Continue") { () -> Void in
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                            errorView.showInfo("Mobile Check-In", subTitle: "You have no flight record. Please booking your flight to proceed", colorStyle:0xEC581A, circleIconImage: alertViewIcon)
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCheckInList"), object: nil)
                        }
                    }else if json["status"] == "error"{
                        hideLoading()
                        showErrorMessage(json["message"].string!)
                    }
                    
                }
                catch {
                    
                }
                
            case .failure(let failureResult):
                
                if !isExist{
                    hideLoading()
                    showErrorMessage(failureResult.localizedDescription)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCheckInList"), object: nil)
                }
                //
            }
        })
        
    }
    
    func saveCheckInList(_ list : NSArray, userId : String, signature : String){
        
        let userInfo = defaults.object(forKey: "userInfo") as! NSDictionary
        //var userList = Results<UserList>!()
        let userList = realm.objects(UserList.self)
        let mainUser = userList.filter("userId == %@", "\(userInfo["username"] as! String)")
        
        if mainUser.count != 0{
            if mainUser[0].checkinList.count != 0{
                realm.beginWrite()
                realm.delete(mainUser[0].checkinList)
                try! realm.commitWrite()
            }
        }
        
        for tempListInfo in list{
            
            let listInfo = tempListInfo as! NSDictionary
            let checkIn = CheckInList()
            checkIn.pnr = listInfo["pnr"] as! String
            
            let formater = DateFormatter()
            formater.dateFormat = "yyyy-MM-dd"
            let twentyFour = Locale(identifier: "en_GB")
            formater.locale = twentyFour
            let date = (listInfo["date"] as! String).components(separatedBy: " ")
            let new = "\(date[2])-\(date[1])-\(date[0])"
            let newdate = formater.date(from: new)
            //print(newdate)
            
            checkIn.departureStationCode = listInfo["departure_station_code"] as! String
            checkIn.arrivalStationCode = listInfo["arrival_station_code"] as! String
            checkIn.departureDateTime = newdate!
            checkIn.departureDayDate = listInfo["date"] as! String
            
            if mainUser.count == 0{
                let user = UserList()
                user.userId = userInfo["username"] as! String
                user.checkinList.append(checkIn)
                
                try! realm.write({ () -> Void in
                    realm.add(user)
                })
            }else{
                
                try! realm.write({ () -> Void in
                    mainUser[0].checkinList.append(checkIn)
                    mainUser[0].id = userId
                    mainUser[0].signature = signature
                })
                
            }
        }
        
    }
    
}
