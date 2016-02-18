//
//  LoginBoardingPassViewController.swift
//  FireflyMobileApp
//
//  Created by ME-Tech Mac User 1 on 2/16/16.
//  Copyright © 2016 Me-tech. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class LoginBoardingPassViewController: CommonListViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let bookingList = listBooking[indexPath.row] as! NSDictionary
        
        showHud("open")
        FireFlyProvider.request(.RetrieveBoardingPass(signature, bookingList["pnr"] as! String, bookingList["departure_station_code"] as! String, bookingList["arrival_station_code"] as! String, userId), completion: { (result) -> () in
            switch result {
            case .Success(let successResult):
                do {
                    let json = try JSON(NSJSONSerialization.JSONObjectWithData(successResult.data, options: .MutableContainers))
                    
                    if  json["status"].string == "success"{
                        var i = 0
                        var j = 0
                        let dict = NSMutableDictionary()
                        for info in json["boarding_pass"].arrayObject!{
                            let index = "\(j)"
                            let imageURL = info["QRCodeURL"] as? String
                            
                            Alamofire.request(.GET, imageURL!).response(completionHandler: { (request, response, data, error) -> Void in
                                print(index)
                                dict.setObject(UIImage(data: data!)!, forKey: "\(index)")
                                i++
                                
                                if i == j{
                                    showHud("close")
                                    let storyboard = UIStoryboard(name: "BoardingPass", bundle: nil)
                                    let boardingPassDetailVC = storyboard.instantiateViewControllerWithIdentifier("BoardingPassDetailVC") as! BoardingPassDetailViewController
                                    boardingPassDetailVC.boardingPassData = json["boarding_pass"].arrayObject!
                                    boardingPassDetailVC.imgDict = dict
                                    self.navigationController!.pushViewController(boardingPassDetailVC, animated: true)
                                }
                            })
                            j++
                        }
                    }else{
                        showHud("close")
                        //showToastMessage(json["message"].string!)
                                showErrorMessage(json["message"].string!)
                    }
                }
                catch {
                    
                }
                
            case .Failure(let failureResult):
                print (failureResult)
            }
            
        })
        
    }
    
}