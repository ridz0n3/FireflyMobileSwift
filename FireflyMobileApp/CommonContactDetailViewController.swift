//
//  CommonContactDetailViewController.swift
//  FireflyMobileApp
//
//  Created by ME-Tech Mac User 1 on 1/14/16.
//  Copyright © 2016 Me-tech. All rights reserved.
//

import UIKit
import XLForm
import SwiftyJSON
import M13Checkbox

class CommonContactDetailViewController: BaseXLFormViewController {
    
    var stateArray = [Dictionary<String,AnyObject>]()
    var contactData = Dictionary<String,AnyObject>()
    
    @IBOutlet weak var insuranceView: UIView!
    @IBOutlet weak var views: UIView!
    @IBOutlet weak var paragraph1: UITextView!
    @IBOutlet weak var paragraph2: UITextView!
    @IBOutlet weak var paragraph3: UILabel!
    @IBOutlet weak var agreeTerm: M13Checkbox!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    
    var titleArray = defaults.objectForKey("title") as! [Dictionary<String,AnyObject>]
    var countryArray = defaults.objectForKey("country") as! [Dictionary<String,AnyObject>]
    var flightType = String()
    var meals = [AnyObject]()
    var ssrStatus = String()
    
    override func viewDidLoad() {
        
        agreeTerm.strokeColor = UIColor.orangeColor()
        agreeTerm.checkColor = UIColor.orangeColor()
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        super.viewDidLoad()
        setupLeftButton()
        stateArray = defaults.objectForKey("state") as! [Dictionary<String,AnyObject>]
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommonContactDetailViewController.addBusiness(_:)), name: "addBusiness", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommonContactDetailViewController.removeBusiness(_:)), name: "removeBusiness", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommonContactDetailViewController.selectCountry(_:)), name: "selectCountry", object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeForm() {
        
        let form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
        
        form = XLFormDescriptor(title: "")
        
        if flightType == "MH" && ssrStatus == "Available"{
            
            let timeDifference = defaults.objectForKey("timeDifference") as! Int
            
            if timeDifference > 0{
                section = XLFormSectionDescriptor()
                section = XLFormSectionDescriptor.formSectionWithTitle("SPECIAL MEALS REQUEST")
                form.addFormSection(section)
                
                var i = 0
                for mealInfo in meals{
                    
                    section = XLFormSectionDescriptor()
                    section = XLFormSectionDescriptor.formSectionWithTitle(mealInfo["destination_name"] as? String)
                    form.addFormSection(section)
                    
                    let mealList = mealInfo["list_meal"] as! [AnyObject]
                    let passengerList = mealInfo["passenger"] as! [AnyObject]
                    
                    for passengerInfo in passengerList{
                        
                        // Meals
                        row = XLFormRowDescriptor(tag: "\(Tags.ValidationSSRList)(\(i)\(passengerInfo["passenger_number"] as! Int))", rowType:XLFormRowDescriptorTypeFloatLabeled, title:passengerInfo["name"] as? String)
                        
                        var tempArray:[AnyObject] = [AnyObject]()
                        for mealsDetail in mealList{
                            tempArray.append(XLFormOptionsObject(value: mealsDetail["meal_code"], displayText: mealsDetail["name"] as! String))
                            
                            if mealsDetail["meal_code"] as! String == ""{
                                row.value = mealsDetail["name"] as! String
                            }
                        }
                        
                        row.selectorOptions = tempArray
                        section.addFormRow(row)
                        
                    }
                    i += 1
                }
            }
        }
        
        
        section = XLFormSectionDescriptor()
        section = XLFormSectionDescriptor.formSectionWithTitle("CONTACT DETAIL")
        form.addFormSection(section)
        
        // Purpose
        row = XLFormRowDescriptor(tag: Tags.ValidationPurpose, rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Primary Purpose of Your Trip:*")
        
        var tempArray:[AnyObject] = [AnyObject]()
        for purpose in purposeArray{
            tempArray.append(XLFormOptionsObject(value: purpose["purpose_code"], displayText: purpose["purpose_name"] as! String))
            
            if contactData["travel_purpose"] as? String == purpose["purpose_code"] as? String{
                row.value = purpose["purpose_name"]
            }
        }
        
        row.selectorOptions = tempArray
        row.required = true
        section.addFormRow(row)
        
        // Title
        row = XLFormRowDescriptor(tag: Tags.ValidationTitle, rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Title:*")
        
        tempArray = [AnyObject]()
        for title in titleArray {
            tempArray.append(XLFormOptionsObject(value: title["title_code"], displayText: title["title_name"] as? String))
            
            if contactData["title"] as? String == title["title_code"] as? String{
                row.value = title["title_name"]
            }
        }
        
        row.selectorOptions = tempArray
        row.required = true
        section.addFormRow(row)
        
        //first name
        row = XLFormRowDescriptor(tag: Tags.ValidationFirstName, rowType: XLFormRowDescriptorTypeFloatLabeled, title:"First Name/Given Name:*")
        //row.addValidator(XLFormRegexValidator(msg: "First name is invalid.", andRegexString: "^[a-zA-Z ]{0,}$"))
        row.required = true
        row.value = contactData["first_name"]
        section.addFormRow(row)
        
        //last name
        row = XLFormRowDescriptor(tag: Tags.ValidationLastName, rowType: XLFormRowDescriptorTypeFloatLabeled, title:"Last Name/Family Name:*")
        //row.addValidator(XLFormRegexValidator(msg: "Last name is invalid.", andRegexString: "^[a-zA-Z ]{0,}$"))
        row.required = true
        row.value = contactData["last_name"]
        section.addFormRow(row)
        
        //email
        row = XLFormRowDescriptor(tag: Tags.ValidationEmail, rowType: XLFormRowDescriptorTypeFloatLabeled, title:"Email Address:*")
        row.required = true
        row.value = contactData["email"]
        row.addValidator(XLFormValidator.emailValidator())
        section.addFormRow(row)
        
        var dialCode = String()
        // Country
        row = XLFormRowDescriptor(tag: Tags.ValidationCountry, rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Country:*")
        
        tempArray = [AnyObject]()
        
        for country in countryArray{
            tempArray.append(XLFormOptionsObject(value: country["country_code"], displayText: country["country_name"] as! String))
            
            if contactData["country"] as? String == country["country_code"]  as? String{
                row.value = country["country_name"]
                dialCode = country["dialing_code"] as! String
            }
        }
        
        row.selectorOptions = tempArray
        row.required = true
        section.addFormRow(row)
        
        // Mobile Number
        row = XLFormRowDescriptor(tag: Tags.ValidationMobileHome, rowType: XLFormRowDescriptorTypeFloatLabeled, title:"Mobile Number:*")
        row.required = true
        row.addValidator(XLFormRegexValidator(msg: "Mobile phone must start with country code and not less than 7 digits.", andRegexString: "^\(dialCode)[0-9]{7,}$"))
        //row.value = contactData["mobile_phone"]
        if contactData["mobile_phone"] as! String == ""{
            row.value = dialCode
        }else{
            row.value = contactData["mobile_phone"] as! String
        }
        section.addFormRow(row)
        
        // Alternate Number
        row = XLFormRowDescriptor(tag: Tags.ValidationAlternate, rowType: XLFormRowDescriptorTypeFloatLabeled, title:"Alternate Number:*")
        row.addValidator(XLFormRegexValidator(msg: "Alternate phone must start with country code and not less than 7 digits.", andRegexString: "^\(dialCode)[0-9]{7,}$"))
        row.required = true
        //row.value = contactData["alternate_phone"]
        if contactData["alternate_phone"] as! String == ""{
            row.value = dialCode
        }else{
            row.value = contactData["alternate_phone"] as! String
        }
        section.addFormRow(row)
        
        self.form = form
        
        if contactData["travel_purpose"] as? String == "2"{
            addBusinessRow()
        }
    }
    
    func getPurpose(purposeName:String, purposeArr:[Dictionary<String,AnyObject>]) -> String{
        
        var purposeCode = String()
        for purposeData in purposeArr{
            if purposeData["purpose_name"] as! String == purposeName{
                purposeCode = purposeData["purpose_code"] as! String
            }
        }
        return purposeCode
    }
    
    func addBusiness(sender:NSNotification){
        addBusinessRow()
    }
    
    func addBusinessRow(){
        var row : XLFormRowDescriptor
        
        // Company Name
        row = XLFormRowDescriptor(tag: Tags.ValidationCompanyName, rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Company Name:*")
        row.required = true
        row.value = nilIfEmpty(contactData["company_name"])!.xmlSimpleUnescapeString()
        self.form.addFormRow(row, afterRowTag: Tags.ValidationEmail)
        
        // Address 1
        row = XLFormRowDescriptor(tag: Tags.ValidationAddressLine1, rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Address 1:*")
        row.required = true
        row.value = nilIfEmpty(contactData["address1"])!.xmlSimpleUnescapeString()
        self.form.addFormRow(row, afterRowTag: Tags.ValidationCompanyName)
        
        // Address 2
        row = XLFormRowDescriptor(tag: Tags.ValidationAddressLine2, rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Address 2:*")
        row.required = true
        row.value = nilIfEmpty(contactData["address2"])!.xmlSimpleUnescapeString()
        self.form.addFormRow(row, afterRowTag: Tags.ValidationAddressLine1)
        
        // Address 3
        row = XLFormRowDescriptor(tag: Tags.ValidationAddressLine3, rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Address 3:*")
        row.required = true
        row.value = nilIfEmpty(contactData["address3"])!.xmlSimpleUnescapeString()
        self.form.addFormRow(row, afterRowTag: Tags.ValidationAddressLine2)
        
        // City
        row = XLFormRowDescriptor(tag: Tags.ValidationTownCity, rowType:XLFormRowDescriptorTypeFloatLabeled, title:"City:*")
        row.required = true
        row.value = nilIfEmpty(contactData["city"])!.xmlSimpleUnescapeString()
        self.form.addFormRow(row, afterRowTag: Tags.ValidationCountry)
        
        // State
        row = XLFormRowDescriptor(tag: Tags.ValidationState, rowType:XLFormRowDescriptorTypeFloatLabeled, title:"State:*")
        row.selectorOptions = [XLFormOptionsObject(value: "", displayText: "")]
        row.value = contactData["state"]
        row.required = true
        self.form.addFormRow(row, afterRowTag: Tags.ValidationTownCity)
        
        // Postcode
        row = XLFormRowDescriptor(tag: Tags.ValidationPostcode, rowType:XLFormRowDescriptorTypeFloatLabeled, title:"Postcode:*")
        row.required = true
        row.value = contactData["postcode"]
        self.form.addFormRow(row, afterRowTag: Tags.ValidationState)
        
        if nullIfEmpty(self.formValues()["Country"]!) as! String != ""{
            country(getCountryCode(self.formValues()["Country"]! as! String, countryArr: countryArray))
        }
    }
    
    func removeBusiness(sender:NSNotification){
        
        self.form.removeFormRowWithTag(Tags.ValidationCompanyName)
        self.form.removeFormRowWithTag(Tags.ValidationAddressLine1)
        self.form.removeFormRowWithTag(Tags.ValidationAddressLine2)
        self.form.removeFormRowWithTag(Tags.ValidationAddressLine3)
        self.form.removeFormRowWithTag(Tags.ValidationTownCity)
        self.form.removeFormRowWithTag(Tags.ValidationState)
        self.form.removeFormRowWithTag(Tags.ValidationPostcode)
        
    }
    
    var dialingCode = String()
    
    func selectCountry(sender:NSNotification){
        country(sender.userInfo!["countryVal"]! as! String)
        
        self.form.removeFormRowWithTag(Tags.ValidationMobileHome)
        self.form.removeFormRowWithTag(Tags.ValidationAlternate)
        
        var row : XLFormRowDescriptor
        
        if contactData["country"] as? String != sender.userInfo!["countryVal"]! as? String{
            
            // Mobile Number
            row = XLFormRowDescriptor(tag: Tags.ValidationMobileHome, rowType: XLFormRowDescriptorTypeFloatLabeled, title:"Mobile Number:*")
            row.required = true
            row.addValidator(XLFormRegexValidator(msg: "Mobile phone must start with country code and not less than 7 digits.", andRegexString: "^\(sender.userInfo!["dialingCode"]! as! String)[0-9]{7,}$"))
            row.value = sender.userInfo!["dialingCode"]! as! String
            
            self.form.addFormRow(row, afterRowTag: Tags.ValidationCountry)
            
            // Alternate Number
            row = XLFormRowDescriptor(tag: Tags.ValidationAlternate, rowType: XLFormRowDescriptorTypeFloatLabeled, title:"Alternate Number:*")
            row.addValidator(XLFormRegexValidator(msg: "Alternate phone must start with country code and not less than 7 digits.", andRegexString: "^\(sender.userInfo!["dialingCode"]! as! String)[0-9]{7,}$"))
            row.required = true
            row.value = sender.userInfo!["dialingCode"]! as! String
            
            self.form.addFormRow(row, afterRowTag: Tags.ValidationMobileHome)
            
        }else{
            
            // Mobile Number
            row = XLFormRowDescriptor(tag: Tags.ValidationMobileHome, rowType: XLFormRowDescriptorTypeFloatLabeled, title:"Mobile Number:*")
            row.required = true
            row.addValidator(XLFormRegexValidator(msg: "Mobile phone must not less than 7 digits.", andRegexString: "^\(sender.userInfo!["dialingCode"]! as! String)[0-9]{7,}$"))
            
            if contactData["mobile_phone"] as! String == ""{
                row.value = sender.userInfo!["dialingCode"]! as! String
            }else{
                row.value = contactData["mobile_phone"] as! String
            }
            self.form.addFormRow(row, afterRowTag: Tags.ValidationCountry)
            
            // Alternate Number
            row = XLFormRowDescriptor(tag: Tags.ValidationAlternate, rowType: XLFormRowDescriptorTypeFloatLabeled, title:"Alternate Number:*")
            row.addValidator(XLFormRegexValidator(msg: "Alternate phone must not less than 7 digits.", andRegexString: "^\(sender.userInfo!["dialingCode"]! as! String)[0-9]{7,}$"))
            row.required = true
            
            if contactData["alternate_phone"] as! String == ""{
                row.value = sender.userInfo!["dialingCode"]! as! String
            }else{
                row.value = contactData["alternate_phone"] as! String
            }
            
            self.form.addFormRow(row, afterRowTag: Tags.ValidationMobileHome)
            
        }
    }
    
    func country(countryCode:String){
        if self.formValues()[Tags.ValidationState] != nil{
            var stateArr = [NSDictionary]()
            for stateData in stateArray{
                if stateData["country_code"] as! String == countryCode{
                    stateArr.append(stateData as NSDictionary)
                }
            }
            
            self.form.removeFormRowWithTag(Tags.ValidationState)
            var row : XLFormRowDescriptor
            row = XLFormRowDescriptor(tag: Tags.ValidationState, rowType:XLFormRowDescriptorTypeFloatLabeled, title:"State:*")
            
            var tempArray:[AnyObject] = [AnyObject]()
            if stateArr.count != 0{
                for data in stateArr{
                    tempArray.append(XLFormOptionsObject(value: data["state_code"], displayText: data["state_name"] as! String))
                    
                    
                    if nilIfEmpty(contactData["state"]) as! String == data["state_code"] as! String{
                        row.value = data["state_name"]
                    }
                }
            }
            else {
                
                if nilIfEmpty(contactData["state"]) as! String == "OT"{
                    row.value = "Others"
                }
                
                tempArray.append(XLFormOptionsObject(value: "OT", displayText: "Other"))
            }
            
            row.selectorOptions = tempArray
            row.required = true
            
            self.form.addFormRow(row, afterRowTag: Tags.ValidationTownCity)
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if flightType == "MH"{
            
            if meals.count == 2{
                if section == 1 || section == 2{
                    return UITableViewAutomaticDimension
                    
                }else{
                    return 35
                }
                
            }else{
                if section == 1{
                    return UITableViewAutomaticDimension
                    
                }else{
                    return 35
                }
            }
            
        }else{
            return 35
        }
        
        
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionView = NSBundle.mainBundle().loadNibNamed("PassengerHeader", owner: self, options: nil)[0] as! PassengerHeaderView
        
        let index = UInt(section)
        sectionView.sectionLbl.text = form.formSectionAtIndex(index)?.title
        
        if flightType == "MH"{
            
            if meals.count == 2{
                if index == 1 || index == 2{
                    sectionView.views.backgroundColor = UIColor.whiteColor()
                    sectionView.sectionLbl.textColor = UIColor.blackColor()
                    sectionView.sectionLbl.font = UIFont.boldSystemFontOfSize(12.0)
                    sectionView.sectionLbl.textAlignment = NSTextAlignment.Left
                    
                }else{
                    sectionView.views.backgroundColor = UIColor(red: 240.0/255.0, green: 109.0/255.0, blue: 34.0/255.0, alpha: 1.0)
                    sectionView.sectionLbl.textColor = UIColor.whiteColor()
                    sectionView.sectionLbl.textAlignment = NSTextAlignment.Center
                }
                
            }else{
                if index == 1{
                    sectionView.views.backgroundColor = UIColor.whiteColor()
                    sectionView.sectionLbl.textColor = UIColor.blackColor()
                    sectionView.sectionLbl.font = UIFont.boldSystemFontOfSize(12.0)
                    sectionView.sectionLbl.textAlignment = NSTextAlignment.Left
                    
                }else{
                    sectionView.views.backgroundColor = UIColor(red: 240.0/255.0, green: 109.0/255.0, blue: 34.0/255.0, alpha: 1.0)
                    sectionView.sectionLbl.textColor = UIColor.whiteColor()
                    sectionView.sectionLbl.textAlignment = NSTextAlignment.Center
                }
            }
            
        }else{
            sectionView.views.backgroundColor = UIColor(red: 240.0/255.0, green: 109.0/255.0, blue: 34.0/255.0, alpha: 1.0)
            
            sectionView.sectionLbl.textColor = UIColor.whiteColor()
            sectionView.sectionLbl.textAlignment = NSTextAlignment.Center
        }
        
        
        return sectionView
        
    }
    
}
