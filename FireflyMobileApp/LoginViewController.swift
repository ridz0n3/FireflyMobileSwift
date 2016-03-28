    //
    //  LoginViewController.swift
    //  FireflyMobileApp
    //
    //  Created by ME-Tech Mac User 1 on 11/16/15.
    //  Copyright © 2015 Me-tech. All rights reserved.
    //

    import UIKit
    import Alamofire
    import XLForm
    import SwiftValidator
    import SwiftyJSON
    import SCLAlertView

    class LoginViewController: BaseXLFormViewController {
        
        @IBOutlet var forgotPasswordView: UIView!
        @IBOutlet weak var emailTxtField: UITextField!
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupMenuButton()
            
            // Do any additional setup after loading the view.
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            initializeForm()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            initializeForm()
        }
        
        func initializeForm() {
            
            let form : XLFormDescriptor
            var section : XLFormSectionDescriptor
            var row : XLFormRowDescriptor
            
            let star = [NSForegroundColorAttributeName : UIColor.redColor()]
            var attrString = NSMutableAttributedString()
            
            form = XLFormDescriptor(title: "")
            
            section = XLFormSectionDescriptor()
            form.addFormSection(section)
            
            // username
            row = XLFormRowDescriptor(tag: Tags.ValidationEmail, rowType: XLFormRowDescriptorTypeText, title:"")
            attrString = NSMutableAttributedString(string: "*", attributes: star)
            attrString.appendAttributedString(NSAttributedString(string: "USER ID (Email)"))
            row.cellConfigAtConfigure["textField.attributedPlaceholder"] = attrString
            row.cellConfigAtConfigure["backgroundColor"] = UIColor(patternImage: UIImage(named: "txtField")!)
            row.cellConfigAtConfigure["textField.textAlignment"] =  NSTextAlignment.Left.rawValue
            row.required = true
            section.addFormRow(row)
            
            // Password
            row = XLFormRowDescriptor(tag: Tags.ValidationPassword, rowType: XLFormRowDescriptorTypePassword, title:"")
            attrString = NSMutableAttributedString(string: "*", attributes: star)
            attrString.appendAttributedString(NSAttributedString(string: "Password"))
            row.cellConfigAtConfigure["textField.attributedPlaceholder"] = attrString
            row.cellConfigAtConfigure["backgroundColor"] = UIColor(patternImage: UIImage(named: "txtField")!)
            row.cellConfigAtConfigure["textField.textAlignment"] =  NSTextAlignment.Left.rawValue
            row.required = true
            section.addFormRow(row)
            
            self.form = form
        }
        
        override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return 50
        }
        
        @IBAction func loginButtonPressed(sender: AnyObject) {
            
            validateForm()
            
            if isValidate{
                
                let password = self.formValues()["Password"] as! String
                let encPassword = try! EncryptManager.sharedInstance.aesEncrypt(password, key: key, iv: iv)
                
                let username: String = (self.formValues()["Email"]! as! String).xmlSimpleEscapeString()
                
                showLoading() 
                
                
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
                                let storyBoard = UIStoryboard(name: "Home", bundle: nil)
                                let homeVC = storyBoard.instantiateViewControllerWithIdentifier("HomeVC") as! HomeViewController
                                self.navigationController!.pushViewController(homeVC, animated: true)
                            }else if json["status"].string == "change_password" {
                                
                                
                                showInfo(json["message"].string!)
                                let storyBoard = UIStoryboard(name: "Login", bundle: nil)
                                let homeVC = storyBoard.instantiateViewControllerWithIdentifier("PasswordExpiredVC") as! PasswordExpiredViewController
                                self.navigationController!.pushViewController(homeVC, animated: true)
                            }else{
                                showErrorMessage(json["message"].string!)
                            }
                            hideLoading()
                        }
                        catch {
                            
                        }
                        
                    case .Failure(let failureResult):
                        hideLoading()
                        showErrorMessage(failureResult.nsError.localizedDescription)
                    }
                    })
            }
            
        }
        
        @IBAction func forgotPasswordButtonPressed(sender: AnyObject) {
            
            reloadAlertView("USER ID (Email):*")
        }
        
        var email = UITextField()
        var tempEmail = String()
        
        func reloadAlertView(msg : String){
            
            let alert = SCLAlertView()
            email = alert.addTextField("Enter email")
            email.text = tempEmail
            alert.addButton("Submit", target: self, selector: "loginBtnPressed")
            alert.showEdit("Forgot Password", subTitle: msg, colorStyle: 0xEC581A, closeButtonTitle : "Close")
            
        }
        
        func loginBtnPressed(){
            
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            
            if email.text == ""{
                reloadAlertView("Please fill all field")
            }else{
                validationSuccessful()
            }
            
        }
        
        @IBAction func registerButtonPressed(sender: AnyObject) {
            
            let storyboard = UIStoryboard(name: "Register", bundle: nil)
            let registerVC = storyboard.instantiateViewControllerWithIdentifier("RegisterVC") as! RegisterPersonalInfoViewController
            registerVC.fromLogin = true
            self.navigationController?.pushViewController(registerVC, animated: true)
            
        }
        
        override func validationSuccessful() {
            showLoading() 
            FireFlyProvider.request(.ForgotPassword(email.text!.xmlSimpleEscapeString(), "")) { (result) -> () in
                
                
                switch result {
                case .Success(let successResult):
                    do{
                        let json = try JSON(NSJSONSerialization.JSONObjectWithData(successResult.data, options: .MutableContainers))
                        
                        if json["status"] == "success"{
                            showToastMessage(json["message"].string!)
                        }else if json["status"] == "error"{
                            self.reloadAlertView(json["message"].string!)
                        }
                    }
                    catch{
                        
                    }
                    hideLoading()
                    
                case .Failure(let failureResult):
                    hideLoading()
                    showErrorMessage(failureResult.nsError.localizedDescription)
                    
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


