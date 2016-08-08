//
//  NSDate+Extensions.swift
//  Wallet
//
//  Created by Duff Neubauer on 12/30/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Foundation

extension Date {
  
  //----------------------------------------------------------------------------------------
  // numberOfDaysSinceDate(anotherDate:) -> Int
  //----------------------------------------------------------------------------------------
  func numberOfDaysSinceDate(_ anotherDate: Date) -> Int {
    let calendar = Calendar.current()
    var fromDate: Date?, toDate: Date?
    
    calendar.range(of: .day, start: &fromDate, interval: nil, for: anotherDate)
    calendar.range(of: .day, start: &toDate, interval: nil, for: self)
    
    let difference = calendar.components(.day, from: fromDate!, to: toDate!, options: [])
    
    return difference.day!
  }
}
