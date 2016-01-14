//
//  ManageFlightHomeViewController.swift
//  FireflyMobileApp
//
//  Created by ME-Tech Mac User 1 on 1/11/16.
//  Copyright © 2016 Me-tech. All rights reserved.
//

import UIKit
import SCLAlertView
import CoreData

class ManageFlightHomeViewController: BaseViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var sendItineraryBtn: UIButton!
    @IBOutlet weak var addPaymentBtn: UIButton!
    @IBOutlet weak var changeSeatBtn: UIButton!
    @IBOutlet weak var changePassangerBtn: UIButton!
    @IBOutlet weak var changeFlightBtn: UIButton!
    @IBOutlet weak var changeContactBtn: UIButton!
    
    var contacts = [NSManagedObject]()
    @IBOutlet weak var flightSummarryTableView: UITableView!
    
    var flightDetail = NSArray()
    var totalPrice = String()
    var insuranceDetails = NSDictionary()
    var contactInformation = NSDictionary()
    var itineraryInformation = NSDictionary()
    var paymentDetails = NSArray()
    var passengerInformation = NSArray()
    var totalDue = String()
    var totalPaid = String()
    var priceDetail = NSMutableArray()
    var serviceDetail = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMenuButton()
        
        sendItineraryBtn.layer.borderWidth = 0.5
        sendItineraryBtn.layer.cornerRadius = 10.0
        
        changeContactBtn.layer.borderWidth = 0.5
        changeContactBtn.layer.cornerRadius = 10.0
        
        changeFlightBtn.layer.borderWidth = 0.5
        changeFlightBtn.layer.cornerRadius = 10.0
        
        changePassangerBtn.layer.borderWidth = 0.5
        changePassangerBtn.layer.cornerRadius = 10.0
        
        changeSeatBtn.layer.borderWidth = 0.5
        changeSeatBtn.layer.cornerRadius = 10.0
        
        addPaymentBtn.layer.borderWidth = 0.5
        addPaymentBtn.layer.cornerRadius = 10.0
        
        let itineraryData = defaults.objectForKey("manageFlight") as! NSDictionary
        flightDetail = itineraryData["flight_details"] as! NSArray
        priceDetail = (itineraryData["price_details"]?.mutableCopy())! as! NSMutableArray
        totalPrice = itineraryData["total_price"] as! String
        insuranceDetails = itineraryData["insurance_details"] as! NSDictionary
        contactInformation = itineraryData["contact_information"] as! NSDictionary
        itineraryInformation = itineraryData["itinerary_information"] as! NSDictionary
        paymentDetails = itineraryData["payment_details"] as! NSArray
        passengerInformation = itineraryData["passenger_information"] as! NSArray
        totalDue = itineraryData["total_due"] as! String
        totalPaid = itineraryData["total_paid"] as! String
        
        let service = priceDetail.lastObject as! NSDictionary
        priceDetail.removeLastObject()
        serviceDetail = service["services"] as! NSArray
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if section == 1{
            return flightDetail.count
        }else if section == 2{
            return priceDetail.count
        }else if section == 4{
            return serviceDetail.count
        }else if section == 8{
            return passengerInformation.count
        }else if section == 9{
            return paymentDetails.count + 1
        }else{
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0{
            return 83
        }else if indexPath.section == 1{
            return 137
        }else if indexPath.section == 2{
            return 80
        }else if (indexPath.section == 3 && serviceDetail.count != 0) || indexPath.section == 4{
            return 28
        }else if indexPath.section == 5{
            return 42
        }else if (indexPath.section == 6 && insuranceDetails["status"] as! String != "N"){
            return 59
        }else if indexPath.section == 7{
            return 136
        }else if indexPath.section == 8{
            return 42
        }else if indexPath.section == 9{
            
            if indexPath.row == paymentDetails.count{
                return 80
            }else{
                return 28
            }
            
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let cell = flightSummarryTableView.dequeueReusableCellWithIdentifier("ItineraryCell", forIndexPath: indexPath) as! CustomPaymentSummaryTableViewCell
            
            cell.confirmationLbl.text = "\(itineraryInformation["pnr"]!)"
            cell.reservationLbl.text = "\(itineraryInformation["booking_status"]!)"
            cell.bookDateLbl.text = "Booking Date : \(itineraryInformation["booking_date"]!)"
            
            return cell
        }else if indexPath.section == 1{
            let cell = flightSummarryTableView.dequeueReusableCellWithIdentifier("FlightDetailCell", forIndexPath: indexPath) as! CustomPaymentSummaryTableViewCell
            
            cell.wayLbl.text = flightDetail[indexPath.row]["type"] as? String
            cell.dateLbl.text = flightDetail[indexPath.row]["date"] as? String
            cell.destinationLbl.text = flightDetail[indexPath.row]["station"] as? String
            cell.flightNumberLbl.text = flightDetail[indexPath.row]["flight_number"] as? String
            cell.timeLbl.text = flightDetail[indexPath.row]["time"] as? String
            
            return cell
        }else if indexPath.section == 2{
            
            let detail = priceDetail[indexPath.row] as! NSDictionary
            
            let cell = flightSummarryTableView.dequeueReusableCellWithIdentifier("PriceDetailCell", forIndexPath: indexPath) as! CustomPaymentSummaryTableViewCell
            
            let tax = detail["taxes_or_fees"] as? NSDictionary
            
            let taxData = "Admin Fee : \(tax!["admin_fee"]!)\nAirport Tax: \(tax!["airport_tax"]!)\nFuel Surcharge : \(tax!["fuel_surcharge"]!)\nGood & Service Tax : \(tax!["goods_and_services_tax"]!)\nTotal : \(tax!["total"]!)"
            
            cell.flightDestination.text = detail["title"] as? String
            cell.guestPriceLbl.text = detail["total_guest"] as? String
            cell.guestLbl.text = detail["guest"] as? String
            cell.taxesPrice.text = detail["total_taxes_or_fees"] as? String
            
            cell.detailBtn.addTarget(self, action: "detailBtnPressed:", forControlEvents: .TouchUpInside)
            cell.detailBtn.accessibilityHint = taxData
            
            return cell
            
        }else if indexPath.section == 3{
            let cell = self.flightSummarryTableView.dequeueReusableCellWithIdentifier("ServiceFeeCell", forIndexPath: indexPath) as! CustomPaymentSummaryTableViewCell
            
            return cell
        }else if indexPath.section == 4{
            let cell = self.flightSummarryTableView.dequeueReusableCellWithIdentifier("FeeCell", forIndexPath: indexPath) as! CustomPaymentSummaryTableViewCell
            
            if serviceDetail.count != 0{
                cell.serviceLbl.text = serviceDetail[indexPath.row]["service_name"] as? String
                cell.servicePriceLbl.text = serviceDetail[indexPath.row]["service_price"] as? String
            }
            
            return cell
        }else if indexPath.section == 5{
            let cell = self.flightSummarryTableView.dequeueReusableCellWithIdentifier("TotalCell", forIndexPath: indexPath) as! CustomPaymentSummaryTableViewCell
            
            cell.totalPriceLbl.text = totalPrice
            
            return cell
        }else if indexPath.section == 6{
            let cell = flightSummarryTableView.dequeueReusableCellWithIdentifier("InsuranceCell", forIndexPath: indexPath) as! CustomPaymentSummaryTableViewCell
            
            if insuranceDetails["status"] as! String == "Y"{
                cell.confNumberLbl.text = "\(insuranceDetails["conf_number"]!)"
                cell.rateLbl.text = "\(insuranceDetails["rate"]!)"
            }
            
            return cell
        }else if indexPath.section == 7{
            let cell = flightSummarryTableView.dequeueReusableCellWithIdentifier("ContactDetailCell", forIndexPath: indexPath) as! CustomPaymentSummaryTableViewCell
            
            cell.contactNameLbl.text = "\(contactInformation["title"]!) \(contactInformation["first_name"]!) \(contactInformation["last_name"]!)"
            cell.contactEmail.text = "Email : \(contactInformation["email"]!)"
            cell.contactCountryLbl.text = "Country : \(contactInformation["country"]!)"
            cell.contactMobileLbl.text = "Mobile Phone : \(contactInformation["mobile_phone"]!)"
            cell.contactAlternateLbl.text = "Alternate Phone : \(contactInformation["alternate_phone"]!)"
            
            return cell
        }else if indexPath.section == 8{
            let cell = flightSummarryTableView.dequeueReusableCellWithIdentifier("PassengerDetailCell", forIndexPath: indexPath) as! CustomPaymentSummaryTableViewCell
            let passengerDetail = passengerInformation[indexPath.row] as! NSDictionary
            cell.passengerNameLbl.text = "\(passengerDetail["name"]!)"
            return cell
        }else {
            
            if indexPath.row == paymentDetails.count{
                let cell = flightSummarryTableView.dequeueReusableCellWithIdentifier("PaymentDetailCell", forIndexPath: indexPath) as! CustomPaymentSummaryTableViewCell
                cell.totalDueLbl.text = "Total Due : \(totalDue)"
                cell.totalPaidLbl.text = "Total Paid : \(totalPaid)"
                cell.paymentTotalPriceLbl.text = "Total Price : \(totalPrice)"
                return cell
            }else{
                let cell = flightSummarryTableView.dequeueReusableCellWithIdentifier("CardDetailCell", forIndexPath: indexPath) as! CustomPaymentSummaryTableViewCell
                let cardData = paymentDetails[indexPath.row] as! NSDictionary
                cell.cardPayLbl.text = "\(cardData["payment_amount"]!)"
                cell.cardStatusLbl.text = "\(cardData["payment_status"]!)"
                cell.cardTypeLbl.text = "\(cardData["payment_method"]!)"
                return cell
            }
            
            
            
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 || section == 1 || section == 2 || (section == 6 && insuranceDetails["status"] as! String != "N") || section == 7 || section == 8 || section == 9{
            return 35
        }else{
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionView = NSBundle.mainBundle().loadNibNamed("PassengerHeader", owner: self, options: nil)[0] as! PassengerHeaderView
        
        sectionView.views.backgroundColor = UIColor(red: 240.0/255.0, green: 109.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        
        if section == 0{
            sectionView.sectionLbl.text = "Itinerary Information"
        }else if section == 1{
            sectionView.sectionLbl.text = "Flight Details"
        }else if section == 2{
            sectionView.sectionLbl.text = "Price Details"
        }else if section == 6{
            sectionView.sectionLbl.text = "Insurance Details"
        }else if section == 7{
            sectionView.sectionLbl.text = "Contact Information"
        }else if section == 8{
            sectionView.sectionLbl.text = "Passenger Information"
        }else if section == 9{
            sectionView.sectionLbl.text = "Payment Details"
        }
        
        
        sectionView.sectionLbl.textColor = UIColor.whiteColor()
        sectionView.sectionLbl.textAlignment = NSTextAlignment.Center
        
        return sectionView
        
    }
    
    func detailBtnPressed(sender:UIButton){
        
        SCLAlertView().showSuccess("Taxes/Fee", subTitle: sender.accessibilityHint!, closeButtonTitle: "Close", colorStyle:0xEC581A)
        
    }
    
    @IBAction func changeContactBtnPressed(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "ManageFlight", bundle: nil)
        let manageFlightVC = storyboard.instantiateViewControllerWithIdentifier("ManageContactDetailVC") as! EditContactDetailViewController
        self.navigationController!.pushViewController(manageFlightVC, animated: true)
        
    }
    
    @IBAction func EditPassengerBtnPressed(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "ManageFlight", bundle: nil)
        let editPassengerVC = storyboard.instantiateViewControllerWithIdentifier("EditPassengerDetailVC") as! EditPassengerDetailViewController
        editPassengerVC.passengerInformation = passengerInformation
        self.navigationController!.pushViewController(editPassengerVC, animated: true)
    }
    
    @IBAction func ChangeFlightBtnPressed(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "ManageFlight", bundle: nil)
        let changeFlightVC = storyboard.instantiateViewControllerWithIdentifier("ChangeFlightVC") as! ChangeFlightViewController
        self.navigationController!.pushViewController(changeFlightVC, animated: true)
    }
    
    @IBAction func ChangeSeatBtnPressed(sender: AnyObject) {
        //let storyboard = UIStoryboard(name: "ManageFlight", bundle: nil)
        //let changeFlightVC = storyboard.instantiateViewControllerWithIdentifier("ChangeFlightVC") as! ChangeFlightViewController
        //self.navigationController!.pushViewController(manageFlightVC, animated: true)
    }
    
    @IBAction func AddPaymentBtnPressed(sender: AnyObject) {
        //let storyboard = UIStoryboard(name: "ManageFlight", bundle: nil)
        //let manageFlightVC = storyboard.instantiateViewControllerWithIdentifier("ChangeContactDetailVC") as! ChangeContactDetailViewController
        //self.navigationController!.pushViewController(manageFlightVC, animated: true)
    }
    
    @IBAction func SendItineraryBtnPressed(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "ManageFlight", bundle: nil)
        let sendItineraryVC = storyboard.instantiateViewControllerWithIdentifier("SendItineraryVC") as! SendItineraryViewController
        self.navigationController!.pushViewController(sendItineraryVC, animated: true)
    }
    
}