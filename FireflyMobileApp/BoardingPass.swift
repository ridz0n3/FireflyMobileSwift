//
//  BoardingPass.swift
//  FireflyMobileApp
//
//  Created by ME-Tech Mac User 1 on 2/23/16.
//  Copyright © 2016 Me-tech. All rights reserved.
//

import Foundation
import RealmSwift

class BoardingPass: Object {
    
    dynamic var name = ""
    dynamic var departureStation = ""
    dynamic var arrivalStation = ""
    dynamic var departureDate = ""
    dynamic var departureTime = ""
    dynamic var boardingTime = ""
    dynamic var fare = ""
    dynamic var flightNumber = ""
    dynamic var SSR = ""
    dynamic var QRCodeURL = ""
    dynamic var recordLocator = ""
    dynamic var arrivalStationCode = ""
    dynamic var departureStationCode = ""
    /*
    dynamic var arrivalDateTime = ""
    dynamic var arrivalStationCode = ""
    dynamic var arrivalTime = ""
    dynamic var barCodeData = ""
    dynamic var barCodeURL = ""
    dynamic var boardingSequence = ""
    dynamic var departureDateTime = ""
    dynamic var departureDayDate = ""
    dynamic var departureGate = ""
    dynamic var departureStationCode = ""
    dynamic var seat = ""
    */
    
   
    
    
    
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
