//
//  EditPaymentViewController.swift
//  FireflyMobileApp
//
//  Created by ME-Tech Mac User 1 on 1/19/16.
//  Copyright © 2016 Me-tech. All rights reserved.
//

import UIKit
import SwiftyJSON

class EditPaymentViewController: CommonPaymentViewController {

    var bookingId = String()
    var signature = String()
    
    var totalDueStr = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        totalDueLbl.text = "\(totalDueStr)"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func continueBtnPressed(sender: AnyObject) {
        
        if paymentMethod == "Card"{
            
            validateForm()
            
            if isValidate{
                let cardNumber = self.formValues()[Tags.ValidationCardNumber] as! String
                
                if !luhnCheck(cardNumber){
                    self.showToastMessage("Invalid credit card")
                }else if !checkDate(self.formValues()[Tags.ValidationCardExpiredDate] as! String){
                    self.showToastMessage("Invalid Date")
                }else{
                    
                    let channelType = "1"
                    let channelCode = getCardTypeCode(self.formValues()[Tags.ValidationCardType] as! String, cardArr: cardType)
                    let cardHolderName = self.formValues()[Tags.ValidationHolderName] as! String
                    let cvv = self.formValues()[Tags.ValidationCcvNumber] as! String
                    let expiredDate = (self.formValues()[Tags.ValidationCardExpiredDate] as! String).componentsSeparatedByString("/")
                    let issuingBank = self.formValues()[Tags.ValidationCardType] as! String
                    let expirationDateMonth = expiredDate[0]
                    let expirationDateYear = expiredDate[1]
                    
                    
                    showHud()
                    FireFlyProvider.request(.PaymentProcess(signature, channelType, channelCode, cardNumber, expirationDateMonth, expirationDateYear, cardHolderName, issuingBank, cvv, bookingId), completion: { (result) -> () in
                        
                        self.hideHud()
                        switch result {
                        case .Success(let successResult):
                            do {
                                self.hideHud()
                                let json = try JSON(NSJSONSerialization.JSONObjectWithData(successResult.data, options: .MutableContainers))
                                
                                if json["status"] == "Redirect"{
                                    self.showToastMessage(json["status"].string!)
                                    
                                    let urlString = String(format: "%@/ios/%@", json["link"].string!,json["pass"].string!)
                                    
                                    let storyboard = UIStoryboard(name: "BookFlight", bundle: nil)
                                    let manageFlightVC = storyboard.instantiateViewControllerWithIdentifier("PaymentWebVC") as! PaymentWebViewController
                                    manageFlightVC.urlString = urlString
                                    manageFlightVC.signature = self.signature
                                    self.navigationController!.pushViewController(manageFlightVC, animated: true)
                                    
                                }else{
                                    self.showToastMessage(json["message"].string!)
                                }
                            }
                            catch {
                                
                            }
                            print (successResult.data)
                        case .Failure(let failureResult):
                            print (failureResult)
                        }
                        
                        
                    })
                    
                }
                
            }
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
