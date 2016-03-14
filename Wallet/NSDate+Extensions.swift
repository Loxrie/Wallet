//
//  NSDate+Extensions.swift
//  Wallet
//
//  Created by Duff Neubauer on 12/30/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Foundation

extension NSDate {
  
  //----------------------------------------------------------------------------------------
  // numberOfDaysSinceDate(anotherDate:) -> Int
  //----------------------------------------------------------------------------------------
  func numberOfDaysSinceDate(anotherDate: NSDate) -> Int {
    let calendar = NSCalendar.currentCalendar()
    var fromDate: NSDate?, toDate: NSDate?
    
    calendar.rangeOfUnit(.Day, startDate: &fromDate, interval: nil, forDate: anotherDate)
    calendar.rangeOfUnit(.Day, startDate: &toDate, interval: nil, forDate: self)
    
    let difference = calendar.components(.Day, fromDate: fromDate!, toDate: toDate!, options: [])
    
    return difference.day
  }
}