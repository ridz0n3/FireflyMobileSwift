//
//  SideMenuTableViewController.swift
//  FireflyMobileApp
//
//  Created by ME-Tech Mac User 1 on 11/17/15.
//  Copyright © 2015 Me-tech. All rights reserved.
//

import UIKit


class SideMenuTableViewController: UITableViewController {

    @IBOutlet var sideMenuTableView: UITableView!
    var menuSections:[String] = ["Home", "Update Information", "Login", "Register", "About", "Terms", "Logout"]
    var hideRow : Bool = false
    var selectedMenuItem : Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshSideMenu:", name: "reloadSideMenu", object: nil)
        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.darkGrayColor()
        tableView.scrollsToTop = false
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedMenuItem, inSection: 0), animated: false, scrollPosition: .Middle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return menuSections.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL")
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.textColor = UIColor.whiteColor()
            let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor(red: 240/255, green: 109/255, blue: 34/255, alpha: 1.0)
            cell!.selectedBackgroundView = selectedBackgroundView
          
        }
        
        cell!.textLabel?.text = menuSections[indexPath.row]
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 1 && hideRow == false) || (indexPath.row == 6 && hideRow == false) || (indexPath.row == 2 && hideRow == true) || (indexPath.row == 3 && hideRow == true){
            return 0.0
        }else {
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView.init(frame: CGRectMake(0, 0, tableView.frame.size.width, 50))
        let label = UILabel.init(frame:CGRectMake(15, 0, tableView.frame.size.width, 50))
        label.font = UIFont(name: "HelveticaNeue-Light", size: 28.0)
        label.tintColor = UIColor.whiteColor()
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = UIColor.clearColor()
        
        
        
        if hideRow == true{
            let defaults = NSUserDefaults.standardUserDefaults()
            let userInfo = defaults.objectForKey("userInfo") as! NSMutableDictionary
            let greetMsg = String(format: "Hi, %@", userInfo["first_name"] as! String)
            
            label.text = greetMsg
        }else{
            label.text = "FIREFLY"
        }
        
        view.addSubview(label)
        view.backgroundColor = UIColor.darkGrayColor()
        
        return view
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("did select row: \(indexPath.row)")
        
        if (indexPath.row == selectedMenuItem) {
            return
        }
        
        selectedMenuItem = indexPath.row
        
        //Present new view controller
        var destViewController : UIViewController
        switch (indexPath.row) {
        case 0:
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("HomeVC")
            break
        case 1:
            let storyboard = UIStoryboard(name: "UpdateInformation", bundle: nil)
            destViewController = storyboard.instantiateViewControllerWithIdentifier("UpdateInformationVC")
            
            break
        case 2:
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            destViewController = storyboard.instantiateViewControllerWithIdentifier("LoginVC")
            break
        case 3:
            let storyboard = UIStoryboard(name: "Register", bundle: nil)
            destViewController = storyboard.instantiateViewControllerWithIdentifier("RegisterVC")
            break
       /* case 4:
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AboutVC")
            break*/
        case 5:
            let storyboard = UIStoryboard(name: "Terms", bundle: nil)
            destViewController = storyboard.instantiateViewControllerWithIdentifier("TermsVC")
            break
        default:
            let storyboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            destViewController = storyboard.instantiateViewControllerWithIdentifier("HomeVC")
            break
        }
       sideMenuController()?.setContentViewController(destViewController)
    }
    
    func refreshSideMenu(notif:NSNotificationCenter){
        hideRow = true
        self.sideMenuTableView.reloadData()
    }
    

}
