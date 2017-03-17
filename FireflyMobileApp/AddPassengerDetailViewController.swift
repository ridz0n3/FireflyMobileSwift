//
//  AddPassengerDetailViewController.swift
//  FireflyMobileApp
//
//  Created by ME-Tech Mac User 1 on 1/14/16.
//  Copyright © 2016 Me-tech. All rights reserved.
//

import UIKit
import SwiftyJSON
import XLForm
import RealmSwift
import Crashlytics

class AddPassengerDetailViewController: CommonPassengerDetailViewController {
    
    var status = String()
    var isContinue = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isContinue = false
        adultArray = [Dictionary<String,AnyObject>]()
        flightType = defaults.object(forKey: "flightType") as! String
        adultCount = ((defaults.object(forKey: "adult") as AnyObject).integerValue)!
        infantCount = ((defaults.object(forKey: "infants") as AnyObject).integerValue)!
        module = "addPassenger"
        loadFamilyAndFriendData()
        initializeForm()
        AnalyticsManager.sharedInstance.logScreen("\(GAConstants.passengerDetailsScreen) (\(flightType))")
        NotificationCenter.default.addObserver(self, selector: #selector(AddPassengerDetailViewController.reload(_:)), name: NSNotification.Name(rawValue: "reloadPicker"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isContinue{
            loadFamilyAndFriendData()
            initializeForm()
        }
        
    }
    
    func reload(_ sender : NSNotification){
        loadFamilyAndFriendData()
        initializeForm()
    }
    
    func loadFamilyAndFriendData(){
        
        if try! LoginManager.sharedInstance.isLogin(){
            
            let userInfo = defaults.object(forKey: "userInfo") as! NSDictionary
            let dateArr = (userInfo["DOB"] as! String).components(separatedBy: "-")
            //var userList = Results<FamilyAndFriendList>!()
            let userList = realm.objects(FamilyAndFriendList.self)
            let mainUser = userList.filter("email == %@", "\(userInfo["username"] as! String)")
            
            if mainUser.count != 0{
                if mainUser[0].familyList.count != 0{
                    familyAndFriendList = mainUser[0].familyList
                    rearrangeFamily()
                }
                
                if !isContinue{
                    CLSLogv("Parameter: %i", getVaList([familyAndFriendList.count]))
                    if familyAndFriendList.count == 0{
                        data = ["title" : userInfo["title"]! as AnyObject,
                                "first_name" : userInfo["first_name"]! as AnyObject,
                                "last_name" : userInfo["last_name"]! as AnyObject,
                                "dob2" : "\(dateArr[2])-\(dateArr[1])-\(dateArr[0])" as AnyObject,
                                "issuing_country" : userInfo["contact_country"]! as AnyObject,
                                "bonuslink" : userInfo["bonuslink"]! as AnyObject,
                                "enrich" : "" as AnyObject,
                                "Save" : false as AnyObject]
                        adultInfo.updateValue(data as AnyObject, forKey: "0")
                    }else{
                        var countExist = 0
                        for tempInfo in familyAndFriendList{
                            
                            if (tempInfo.title == userInfo["title"]! as! String) && (tempInfo.firstName == userInfo["first_name"]! as! String) && (tempInfo.lastName == userInfo["last_name"]! as! String) {
                                data = ["id" : tempInfo.id as AnyObject,
                                        "title" : tempInfo.title as AnyObject,
                                        "gender" : tempInfo.gender as AnyObject,
                                        "first_name" : tempInfo.firstName as AnyObject,
                                        "last_name" : tempInfo.lastName as AnyObject,
                                        "dob2" : tempInfo.dob as AnyObject,
                                        "issuing_country" : tempInfo.country as AnyObject,
                                        "bonuslink" : tempInfo.bonuslink as AnyObject,
                                        "enrich" : tempInfo.enrich as AnyObject,
                                        "type" : tempInfo.type as AnyObject,
                                        "Save" : false as AnyObject]
                                adultInfo.updateValue(data as AnyObject, forKey: "0")
                                countExist += 1
                            }
                        }
                        
                        if countExist == 0{
                            data = ["title" : userInfo["title"]! as AnyObject,
                                    "first_name" : userInfo["first_name"]! as AnyObject,
                                    "last_name" : userInfo["last_name"]! as AnyObject,
                                    "dob2" : "\(dateArr[2])-\(dateArr[1])-\(dateArr[0])" as AnyObject,
                                    "issuing_country" : userInfo["contact_country"]! as AnyObject,
                                    "bonuslink" : userInfo["bonuslink"]! as AnyObject,
                                    "enrich" : "" as AnyObject,
                                    "Save" : false as AnyObject]
                            adultInfo.updateValue(data as AnyObject, forKey: "0")
                        }
                    }
                }
            }else{
                
                familyAndFriendList = nil
                rearrangeFamily()
                data = ["title" : userInfo["title"]! as AnyObject,
                        "first_name" : userInfo["first_name"]! as AnyObject,
                        "last_name" : userInfo["last_name"]! as AnyObject,
                        "dob2" : "\(dateArr[2])-\(dateArr[1])-\(dateArr[0])" as AnyObject,
                        "issuing_country" : userInfo["contact_country"]! as AnyObject,
                        "bonuslink" : userInfo["bonuslink"]! as AnyObject,
                        "enrich" : "" as AnyObject,
                        "Save" : false as AnyObject]
                adultInfo.updateValue(data as AnyObject, forKey: "0")
            }
        }
        
    }
    
    func rearrangeFamily(){
        infantList = [AnyObject]()
        infantName = [String]()
        
        adultList = [AnyObject]()
        adultName = [String]()
        
        if familyAndFriendList != nil{
            for familyInfo in familyAndFriendList{
                
                if familyInfo.type == "Infant"{
                    infantList.append(familyInfo)
                    infantName.append("\(familyInfo.firstName) \(familyInfo.lastName)".capitalized)
                }else{
                    adultList.append(familyInfo)
                    adultName.append("\(familyInfo.title) \(familyInfo.firstName) \(familyInfo.lastName)".capitalized)
                }
                
            }
        }
        
    }
    
    let tempData = ["id" : "",
                    "title" : "",
                    "gender" : "",
                    "first_name" : "",
                    "last_name" : "",
                    "dob2" : "",
                    "issuing_country" : "",
                    "bonuslink" : "",
                    "enrich" : "",
                    "type" : "",
                    "Save" : false,
                    "traveling_with" : ""] as [String : Any]
    
    func initializeForm() {
        
        let form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
        
        form = XLFormDescriptor(title: "")
        
        if try! LoginManager.sharedInstance.isLogin(){
            // Basic Information - Section
            section = XLFormSectionDescriptor()
            section = XLFormSectionDescriptor.formSection(withTitle: "Family & Friends")
            form.addFormSection(section)
        }
        
        for adult in 1...adultCount{
            
            var i = adult
            i -= 1
            
            if status != "select"{
                let adultData:[String:String] = ["passenger_code":"\(i)", "passenger_name":"Adult \(adult)"]
                adultArray.append(adultData as [String : AnyObject])
                adultSelect.updateValue(0 as AnyObject, forKey: "\(adult)")
            }
            // Basic Information - Section
            section = XLFormSectionDescriptor()
            section = XLFormSectionDescriptor.formSection(withTitle: "ADULT \(adult)")
            form.addFormSection(section)
            
            
            if try! LoginManager.sharedInstance.isLogin() && adult == 1 {
                
                let info = adultInfo["\(i)"]!
                // Title
                row = XLFormRowDescriptor(tag: String(format: "%@(adult%i)", Tags.ValidationTitle, adult), rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Title:*")
                
                var tempArray:[AnyObject] = [AnyObject]()
                for title in titleArray{
                    tempArray.append(XLFormOptionsObject(value: title["title_code"], displayText: title["title_name"] as! String))
                    
                    if title["title_code"] as! String == info["title"] as! String{
                        row.value = title["title_name"] as! String
                    }
                }
                
                row.selectorOptions = tempArray
                row.isRequired = true
                section.addFormRow(row)
                
                //first name
                row = XLFormRowDescriptor(tag: String(format: "%@(adult%i)", Tags.ValidationFirstName, adult), rowType: XLFormRowDescriptorTypeFloatLabeled, title:"First Name/Given Name:*")
                //row.addValidator(XLFormRegexValidator(msg: "First name is invalid.", andRegexString: "^[a-zA-Z ]{0,}$"))
                row.isRequired = true
                row.value = "\(info["first_name"]! as! String)"
                section.addFormRow(row)
                
                //last name
                row = XLFormRowDescriptor(tag: String(format: "%@(adult%i)", Tags.ValidationLastName, adult), rowType: XLFormRowDescriptorTypeFloatLabeled, title:"Last Name/Family Name:*")
                //row.addValidator(XLFormRegexValidator(msg: "Last name is invalid.", andRegexString: "^[a-zA-Z ]{0,}$"))
                row.isRequired = true
                row.value = "\(info["last_name"]! as! String)"
                section.addFormRow(row)
                
                // Date
                row = XLFormRowDescriptor(tag: String(format: "%@(adult%i)", Tags.ValidationDate, adult), rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Date of Birth:*")
                row.value = formatDate(stringToDate(info["dob2"] as! String))//"\(userInfo["DOB"]!)"
                row.isRequired = true
                section.addFormRow(row)
                
                // Country
                row = XLFormRowDescriptor(tag: String(format: "%@(adult%i)", Tags.ValidationCountry, adult), rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Nationality:*")
                
                tempArray = [AnyObject]()
                for country in countryArray{
                    tempArray.append(XLFormOptionsObject(value: country["country_code"], displayText: country["country_name"] as! String))
                    
                    if country["country_code"] as! String == info["issuing_country"] as! String{
                        row.value = country["country_name"] as! String
                    }
                }
                
                row.selectorOptions = tempArray
                row.isRequired = true
                section.addFormRow(row)
                
                if flightType == "FY"{
                    
                    // Bonuslink Loyalty No
                    row = XLFormRowDescriptor(tag: String(format: "%@(adult%i)", Tags.ValidationBonuslinkNo, adult), rowType: XLFormRowDescriptorTypeFloatLabeled, title:"BonusLink Card No:")
                    //row.addValidator(XLFormRegexValidator(msg: "Bonuslink number is invalid", andRegexString: "^6018[0-9]{12}$"))
                    row.value = "\(info["bonuslink"]! as! String)"
                    section.addFormRow(row)
                    
                    // Enrich Loyalty Number
                    row = XLFormRowDescriptor(tag: String(format: "%@(adult%i)", Tags.ValidationEnrichLoyaltyNo, adult), rowType: XLFormRowDescriptorTypeFloatLabeled, title:"Enrich Loyalty Number:")
                    //row.addValidator(XLFormRegexValidator(msg: "Bonuslink number is invalid", andRegexString: "^6018[0-9]{12}$"))
                    row.value = "\(info["enrich"]! as! String)"
                    section.addFormRow(row)
                }
                
                if try! LoginManager.sharedInstance.isLogin() && module == "addPassenger"{
                    // Save family and friend
                    row = XLFormRowDescriptor(tag: String(format: "%@(adult%i)", Tags.SaveFamilyAndFriend, adult), rowType: XLFormRowDescriptorCheckbox, title:"Save as family & friends")
                    row.value =  [
                        CustomCheckBoxCell.kSave.status.description(): info["Save"] as! Bool
                    ]
                    section.addFormRow(row)
                }
                
            }else{
                // Title
                //
                if status != "select"{
                    adultInfo.updateValue(tempData as AnyObject, forKey: "\(i)")
                }
                
                let info = adultInfo["\(i)"]!
                
                row = XLFormRowDescriptor(tag: String(format: "%@(adult%i)", Tags.ValidationTitle, adult), rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Title:*")
                
                var tempArray:[AnyObject] = [AnyObject]()
                for title in titleArray{
                    tempArray.append(XLFormOptionsObject(value: title["title_code"], displayText: title["title_name"] as! String))
                    
                    if title["title_code"] as! String == info["title"] as! String{
                        row.value = title["title_name"] as! String
                    }
                }
                
                row.selectorOptions = tempArray
                row.isRequired = true
                section.addFormRow(row)
                
                //first name
                row = XLFormRowDescriptor(tag: String(format: "%@(adult%i)", Tags.ValidationFirstName, adult), rowType: XLFormRowDescriptorTypeFloatLabeled, title:"First Name/Given Name:*")
                //row.addValidator(XLFormRegexValidator(msg: "First name is invalid.", andRegexString: "^[a-zA-Z ]{0,}$"))
                row.isRequired = true
                row.value = "\(info["first_name"]! as! String)"
                section.addFormRow(row)
                
                //last name
                row = XLFormRowDescriptor(tag: String(format: "%@(adult%i)", Tags.ValidationLastName, adult), rowType: XLFormRowDescriptorTypeFloatLabeled, title:"Last Name/Family Name:*")
                //row.addValidator(XLFormRegexValidator(msg: "Last name is invalid.", andRegexString: "^[a-zA-Z ]{0,}$"))
                row.isRequired = true
                row.value = "\(info["last_name"]! as! String)"
                section.addFormRow(row)
                
                // Date
                row = XLFormRowDescriptor(tag: String(format: "%@(adult%i)", Tags.ValidationDate, adult), rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Date of Birth:*")
                row.isRequired = true
                if info["dob2"] as! String != ""{
                    row.value = formatDate(stringToDate(info["dob2"] as! String))
                }
                section.addFormRow(row)
                
                // Country
                row = XLFormRowDescriptor(tag: String(format: "%@(adult%i)", Tags.ValidationCountry, adult), rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Nationality:*")
                
                tempArray = [AnyObject]()
                for country in countryArray{
                    tempArray.append(XLFormOptionsObject(value: country["country_code"], displayText: country["country_name"] as! String))
                    
                    if country["country_code"] as! String == info["issuing_country"] as! String{
                        row.value = country["country_name"] as! String
                    }
                }
                
                row.selectorOptions = tempArray
                row.isRequired = true
                section.addFormRow(row)
                
                if flightType == "FY"{
                    // Bonuslink Number
                    row = XLFormRowDescriptor(tag: String(format: "%@(adult%i)", Tags.ValidationBonuslinkNo, adult), rowType: XLFormRowDescriptorTypeFloatLabeled, title:"BonusLink Card No:")
                    //row.addValidator(XLFormRegexValidator(msg: "Bonuslink number is invalid", andRegexString: "^6018[0-9]{12}$"))
                    row.value = "\(info["bonuslink"]! as! String)"
                    section.addFormRow(row)
                    
                    // Enrich Loyalty Number
                    row = XLFormRowDescriptor(tag: String(format: "%@(adult%i)", Tags.ValidationEnrichLoyaltyNo, adult), rowType: XLFormRowDescriptorTypeFloatLabeled, title:"Enrich Loyalty Number:")
                    //row.addValidator(XLFormRegexValidator(msg: "Bonuslink number is invalid", andRegexString: "^6018[0-9]{12}$"))
                    row.value = "\(info["enrich"]! as! String)"
                    section.addFormRow(row)
                }
                
                if try! LoginManager.sharedInstance.isLogin() && module == "addPassenger"{
                    // Save family and friend
                    row = XLFormRowDescriptor(tag: String(format: "%@(adult%i)", Tags.SaveFamilyAndFriend, adult), rowType: XLFormRowDescriptorCheckbox, title:"Save as family & friends")
                    row.value =  [
                        CustomCheckBoxCell.kSave.status.description(): info["Save"] as! Bool
                    ]
                    section.addFormRow(row)
                }
                
            }
            
        }
        
        for i in 0..<infantCount{
            var j = i
            j = j + 1
            
            if status != "select"{
                infantSelect.updateValue(0 as AnyObject, forKey: "\(j)")
                infantInfo.updateValue(tempData as AnyObject, forKey: "\(j)")
            }
            
            let info = infantInfo["\(j)"]!
            
            // Basic Information - Section
            section = XLFormSectionDescriptor()
            section = XLFormSectionDescriptor.formSection(withTitle: "INFANT \(j)")
            form.addFormSection(section)
            
            // Title
            row = XLFormRowDescriptor(tag: String(format: "%@(infant%i)", Tags.ValidationTravelWith, j), rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Traveling with:*")
            row.value = adultArray[i]["passenger_name"] as! String
            var tempArray:[AnyObject] = [AnyObject]()
            for passenger in adultArray{
                tempArray.append(XLFormOptionsObject(value: passenger["passenger_code"], displayText: passenger["passenger_name"] as! String))
                
                if passenger["passenger_code"] as! String == info["traveling_with"] as! String{
                    row.value = passenger["passenger_name"] as! String
                }
            }
            
            row.selectorOptions = tempArray
            row.isRequired = true
            section.addFormRow(row)
            
            // Gender
            row = XLFormRowDescriptor(tag: String(format: "%@(infant%i)", Tags.ValidationGender, j), rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Gender:*")
            
            tempArray = [AnyObject]()
            for gender in genderArray{
                tempArray.append(XLFormOptionsObject(value: gender["gender_code"]!, displayText: gender["gender_name"]!))
                
                if gender["gender_code"]! == info["gender"] as! String{
                    row.value = gender["gender_name"]!
                }
                
            }
            
            row.selectorOptions = tempArray
            row.isRequired = true
            section.addFormRow(row)
            
            // First name
            row = XLFormRowDescriptor(tag: String(format: "%@(infant%i)", Tags.ValidationFirstName, j), rowType: XLFormRowDescriptorTypeFloatLabeled, title:"First Name/Given Name:*")
            //row.addValidator(XLFormRegexValidator(msg: "First name is invalid.", andRegexString: "^[a-zA-Z ]{0,}$"))
            row.isRequired = true
            row.value = info["first_name"] as! String
            section.addFormRow(row)
            
            // Last Name
            row = XLFormRowDescriptor(tag: String(format: "%@(infant%i)", Tags.ValidationLastName, j), rowType: XLFormRowDescriptorTypeFloatLabeled, title:"Last Name/Family Name:*")
            //row.addValidator(XLFormRegexValidator(msg: "Last name is invalid.", andRegexString: "^[a-zA-Z ]{0,}$"))
            row.isRequired = true
            row.value = info["last_name"] as! String
            section.addFormRow(row)
            
            // Date
            row = XLFormRowDescriptor(tag: String(format: "%@(infant%i)", Tags.ValidationDate, j), rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Date of Birth:*")
            row.isRequired = true
            if info["dob2"] as! String != ""{
                row.value = formatDate(stringToDate(info["dob2"] as! String))
            }
            section.addFormRow(row)
            
            // Country
            row = XLFormRowDescriptor(tag: String(format: "%@(infant%i)", Tags.ValidationCountry, j), rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Nationality:*")
            
            tempArray = [AnyObject]()
            for country in countryArray{
                tempArray.append(XLFormOptionsObject(value: country["country_code"], displayText: country["country_name"] as! String))
                
                if country["country_code"] as! String == info["issuing_country"] as! String{
                    row.value = country["country_name"] as! String
                }
            }
            
            row.selectorOptions = tempArray
            row.isRequired = true
            section.addFormRow(row)
            
            if try! LoginManager.sharedInstance.isLogin() && module == "addPassenger"{
                // Save family and friend
                row = XLFormRowDescriptor(tag: String(format: "%@(infant%i)", Tags.SaveFamilyAndFriend, j), rowType: XLFormRowDescriptorCheckbox, title:"Save as family & friends")
                row.value =  [
                    CustomCheckBoxCell.kSave.status.description(): info["Save"] as! Bool
                ]
                section.addFormRow(row)
            }
        }
        
        self.form = form
    }
    
    @IBAction func continueBtnPressed(_ sender: AnyObject) {
        validateForm()
        isContinue = true
        if isValidate{
            let params = getFormData()
            
            if params.4{
                showErrorMessage("Passenger name is duplicated.")
            }else if !params.5 && params.1.count != 0{
                showErrorMessage("You can only assign one infant to one guest.")
            }else if params.8{
                showErrorMessage("Bonuslink number \(params.9)is invalid.")
            }else if params.6{
                showErrorMessage("Enrich loyalty number \(params.7)is invalid.")
            }else{
                var email = String()
                
                if try! LoginManager.sharedInstance.isLogin(){
                    let userInfo = defaults.object(forKey: "userInfo") as! NSDictionary
                    email = userInfo["contact_email"] as! String
                }
                
                showLoading()
                FireFlyProvider.request(.PassengerDetail(params.0 as AnyObject,params.1 as AnyObject,params.2, params.3, flightType, email), completion: { (result) -> () in
                    
                    switch result {
                    case .success(let successResult):
                        do {
                            
                            let json = try JSON(JSONSerialization.jsonObject(with: successResult.data, options: .mutableContainers))
                            
                            if json["status"] == "success"{
                                
                                if try! LoginManager.sharedInstance.isLogin(){
                                    self.saveFamilyAndFriends(json["family_and_friend"].arrayObject! as [AnyObject])
                                }
                                if json["insurance"].dictionaryValue["status"]!.string == "N"{
                                    defaults.set("", forKey: "insurance_status")
                                }else{
                                    defaults.set(json["insurance"].object, forKey: "insurance_status")
                                    defaults.synchronize()
                                }
                                
                                let storyboard = UIStoryboard(name: "BookFlight", bundle: nil)
                                let contactDetailVC = storyboard.instantiateViewController(withIdentifier: "ContactDetailVC") as! AddContactDetailViewController
                                if let ssrStatus = json["ssr_status"].string{
                                    contactDetailVC.ssrStatus = ssrStatus
                                }
                                
                                if let meal = json["meal"].arrayObject{
                                    contactDetailVC.meals = meal as [AnyObject]
                                }
                                
                                self.navigationController!.pushViewController(contactDetailVC, animated: true)
                            }else if json["status"] == "error"{
                                
                                showErrorMessage(json["message"].string!)
                            }else if json["status"].string == "401"{
                                hideLoading()
                                showErrorMessage(json["message"].string!)
                                InitialLoadManager.sharedInstance.load()
                                
                                for views in (self.navigationController?.viewControllers)!{
                                    if views.classForCoder == HomeViewController.classForCoder(){
                                        _ = self.navigationController?.popToViewController(views, animated: true)
                                        AnalyticsManager.sharedInstance.logScreen(GAConstants.homeScreen)
                                    }
                                }
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
            }
        }
        
    }
    
    override func adultSelected(_ index: NSNumber, element: AnyObject) {
        status = "select"
        let btn = element as! UIButton
        adultSelect.updateValue(Int(index) as AnyObject, forKey: "\(btn.tag)")
        let tempInfo = adultList[Int(index)] as! FamilyAndFriendData
        data = ["id" : tempInfo.id as AnyObject,
                "title" : tempInfo.title as AnyObject,
                "gender" : tempInfo.gender as AnyObject,
                "first_name" : tempInfo.firstName as AnyObject,
                "last_name" : tempInfo.lastName as AnyObject,
                "dob2" : tempInfo.dob as AnyObject,
                "issuing_country" : tempInfo.country as AnyObject,
                "bonuslink" : tempInfo.bonuslink as AnyObject,
                "enrich" : tempInfo.enrich as AnyObject,
                "type" : tempInfo.type as AnyObject,
                "Save" : false as AnyObject]
        adultInfo.updateValue(data as AnyObject, forKey: "\(btn.tag - 1)")
        initializeForm()
    }
    
    override func infantSelected(_ index: NSNumber, element: AnyObject) {
        status = "select"
        let btn = element as! UIButton
        infantSelect.updateValue(Int(index) as AnyObject, forKey: "\(btn.tag)")
        let tempInfo = infantList[Int(index)] as! FamilyAndFriendData
        data = ["id" : tempInfo.id as AnyObject,
                "title" : tempInfo.title as AnyObject,
                "gender" : tempInfo.gender as AnyObject,
                "first_name" : tempInfo.firstName as AnyObject,
                "last_name" : tempInfo.lastName as AnyObject,
                "dob2" : tempInfo.dob as AnyObject,
                "issuing_country" : tempInfo.country as AnyObject,
                "bonuslink" : tempInfo.bonuslink as AnyObject,
                "enrich" : tempInfo.enrich as AnyObject,
                "type" : tempInfo.type as AnyObject,
                "traveling_with" : "" as AnyObject,
                "Save" : false as AnyObject]
        infantInfo.updateValue(data as AnyObject, forKey: "\(btn.tag)")
        initializeForm()
    }
    
}
