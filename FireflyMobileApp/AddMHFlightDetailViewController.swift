//
//  AddMHFlightDetailViewController.swift
//  FireflyMobileApp
//
//  Created by ME-Tech Mac User 1 on 2/28/16.
//  Copyright © 2016 Me-tech. All rights reserved.
//

import UIKit
import SCLAlertView
import SwiftyJSON

class AddMHFlightDetailViewController: CommonMHFlightDetailViewController {

    var email = UITextField()
    var password = UITextField()
    
    var tempEmail = String()
    var tempPassword = String()
    
    var type = Int()
    var username = String()
    var departure_station = String()
    var arrival_station = String()
    var departure_date = String()
    var arrival_time_1 = String()
    var departure_time_1 = String()
    var fare_sell_key_1 = String()
    var flight_number_1 = String()
    var journey_sell_key_1 = String()
    
    var return_date = String()
    var arrival_time_2 = String()
    var departure_time_2 = String()
    var fare_sell_key_2 = String()
    var flight_number_2 = String()
    var journey_sell_key_2 = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func continueBtnPressed(sender: AnyObject) {
        
        var userInfo = NSMutableDictionary()
        var planGo = String()
        var planBack = String()
        
        if try! LoginManager.sharedInstance.isLogin(){
            userInfo = defaults.objectForKey("userInfo") as! NSMutableDictionary
        }
        
        let date = flightDetail[0]["departure_date"].string!
        var dateArr = date.componentsSeparatedByString(" ")
        var isReturn = Bool()
        
        if flightDetail.count == 2{
            isReturn = true
        }
        
        if checkGoingIndex == ""{
            showErrorMessage("LabelErrorGoingFlight".localized)
        }else if isReturn && checkReturnIndex == ""{
            showErrorMessage("LabelErrorReturnFlight".localized)
        }else{
            
            if defaults.objectForKey("type") as! Int == 1{
                let dateReturn = flightDetail[1]["departure_date"].string!
                var dateReturnArr = dateReturn.componentsSeparatedByString(" ")
                
                if checkReturnIndex == "1"{
                    planBack = "economy_promo_class"
                }else if checkReturnIndex == "2"{
                    planBack = "economy_class"
                }else{
                    planBack = "business_class"
                }
                
                return_date = formatDate(stringToDate("\(dateReturnArr[2])-\(dateReturnArr[1])-\(dateReturnArr[0])"))
                flight_number_2 = flightDetail[1]["flights"][checkReturnIndexPath.row]["flight_number"].string!
                departure_time_2 = flightDetail[1]["flights"][checkReturnIndexPath.row]["departure_time"].string!
                arrival_time_2 = flightDetail[1]["flights"][checkReturnIndexPath.row]["arrival_time"].string!
                journey_sell_key_2 = flightDetail[1]["flights"][checkReturnIndexPath.row]["journey_sell_key"].string!
                fare_sell_key_2 = flightDetail[1]["flights"][checkReturnIndexPath.row][planBack]["fare_sell_key"].string!
                
            }
            
            if checkGoingIndex == "1"{
                planGo = "economy_promo_class"
            }else if checkGoingIndex == "2"{
                planGo = "economy_class"
            }else{
                planGo = "business_class"
            }
            
            type = defaults.objectForKey("type")! as! Int
            
            if userInfo["username"] != nil{
                username = userInfo["username"]! as! String
            }
            
            departure_station = flightDetail[0]["departure_station_code"].string!
            arrival_station = flightDetail[0]["arrival_station_code"].string!
            departure_date = formatDate(stringToDate("\(dateArr[2])-\(dateArr[1])-\(dateArr[0])"))
            adult = defaults.objectForKey("adult")! as! String
            infant = defaults.objectForKey("infant")! as! String
            flight_number_1 = flightDetail[0]["flights"][checkGoingIndexPath.row]["flight_number"].string!
            departure_time_1 = flightDetail[0]["flights"][checkGoingIndexPath.row]["departure_time"].string!
            arrival_time_1 = flightDetail[0]["flights"][checkGoingIndexPath.row]["arrival_time"].string!
            journey_sell_key_1 = flightDetail[0]["flights"][checkGoingIndexPath.row]["journey_sell_key"].string!
            fare_sell_key_1 = flightDetail[0]["flights"][checkGoingIndexPath.row][planGo]["fare_sell_key"].string!
            
            if try! LoginManager.sharedInstance.isLogin(){
                showHud("open")
                sentData()
                
            }else{
                
                reloadAlertView("Please insert your detail")
                
            }
        }
        
    }

    func loginBtnPressed(sender : SCLAlertView){
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        tempEmail = email.text!
        tempPassword = password.text!
        
        if email.text == "" || password.text == ""{
            reloadAlertView("Please fill all field")
        }else if !emailTest.evaluateWithObject(self.email.text){
            reloadAlertView("Email is invalid")
        }else{
            let encPassword = try! EncryptManager.sharedInstance.aesEncrypt(password.text!, key: key, iv: iv)
            
            let username: String = email.text!
            
            showHud("open")
            
            FireFlyProvider.request(.Login(username, encPassword), completion: { (result) -> () in
                
                switch result {
                case .Success(let successResult):
                    do {
                        let json = try JSON(NSJSONSerialization.JSONObjectWithData(successResult.data, options: .MutableContainers))
                        
                        if  json["status"].string == "success"{
                            
                            defaults.setObject(json["user_info"]["signature"].string, forKey: "signatureLoad")
                            defaults.setObject(json["user_info"].object , forKey: "userInfo")
                            defaults.synchronize()
                            
                            NSNotificationCenter.defaultCenter().postNotificationName("reloadSideMenu", object: nil)
                            
                            self.sentData()
                        }else{
                            showHud("close")
                            self.reloadAlertView(json["message"].string!)
                        }
                    }
                    catch {
                        
                    }
                    
                case .Failure(let failureResult):
                    showHud("close")
                    showErrorMessage(failureResult.nsError.localizedDescription)
                }
                //var success = error == nil
                }
            )
        }
        
    }
    
    func reloadAlertView(msg : String){
        
        let alert = SCLAlertView()
        email = alert.addTextField("Enter email")
        email.text = tempEmail
        password = alert.addTextField("Password")
        password.secureTextEntry = true
        password.text = tempPassword
        alert.addButton("Login", target: self, selector: "loginBtnPressed:")
        //alert.showCloseButton = false
        alert.addButton("Continue as guest") {
            showHud("open")
            self.sentData()
        }
        alert.showEdit("Login", subTitle: msg, colorStyle: 0xEC581A, closeButtonTitle : "Close")
        
    }
    
    func sentData(){
        
        FireFlyProvider.request(.SelectFlight(adult, infant, username, type, departure_date, arrival_time_1, departure_time_1, fare_sell_key_1, flight_number_1, journey_sell_key_1, return_date, arrival_time_2, departure_time_2, fare_sell_key_2, flight_number_2, journey_sell_key_2, departure_station, arrival_station), completion: { (result) -> () in
            switch result {
            case .Success(let successResult):
                do {
                    showHud("close")
                    
                    let json = try JSON(NSJSONSerialization.JSONObjectWithData(successResult.data, options: .MutableContainers))
                    
                    if json["status"] == "success"{
                        defaults.setObject(json["booking_id"].int , forKey: "booking_id")
                        let storyboard = UIStoryboard(name: "BookFlight", bundle: nil)
                        let personalDetailVC = storyboard.instantiateViewControllerWithIdentifier("PassengerDetailVC") as! AddPassengerDetailViewController
                        self.navigationController!.pushViewController(personalDetailVC, animated: true)
                    }else if json["status"] == "error"{
                        //showErrorMessage(json["message"].string!)
                        showErrorMessage(json["message"].string!)
                    }
                }
                catch {
                    
                }
                
            case .Failure(let failureResult):
                showHud("close")
                showErrorMessage(failureResult.nsError.localizedDescription)
            }
            
        })
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