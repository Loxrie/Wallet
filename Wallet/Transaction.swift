//
//  Transaction.swift
//  Wallet
//
//  Created by Duff Neubauer on 11/24/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Foundation


//================================================
// MARK: Transaction
//================================================
class Transaction: NSObject, NSCoding {
  var payee:       String!
  var amount:     NSDecimalNumber!
  var type:       TransactionType!
  var datePosted: NSDate!
  var unique:     String!
  
  var memo:       String?   = nil
  var checkNum:   NSDecimalNumber? = nil
  var category:   String? = nil
    
  init?(_ info: [OFXParser.TransactionInfo: String]) {
    super.init()
//    
//    // Formatters
//    let numberFormatter         = NSNumberFormatter()
//    numberFormatter.numberStyle = .DecimalStyle
    
    let dateFormatter         = NSDateFormatter()
    dateFormatter.timeZone    = NSTimeZone.defaultTimeZone()
    dateFormatter.dateFormat  = "yyyyMMddhhmmss.SSS"
    
    // Check we have all the necessary values
    guard let name          = info[.Name],
          let amountString  = info[.Amount],
          let typeString    = info[.TransactionType],
          let type          = TransactionType(rawValue: typeString),
          let dateString    = info[.DatePosted],
          let datePosted    = dateFormatter.dateFromString(dateString),
          let unique        = info[.UniqueID] else { return nil }
    
    // For every transaction
    self.payee       = name
    self.amount     = NSDecimalNumber(string: amountString)
    self.type       = type
    self.datePosted = datePosted
    self.unique     = unique
    
    // For some transactions
    self.memo       = info[.Memo]
    if let checkNum = info[.CheckNum] {
      self.checkNum = NSDecimalNumber(string: checkNum)
    } else {
      self.checkNum = nil
    }
  }
  
  
  //================================================
  // MARK: NSCoding
  //================================================
  required init?(coder aDecoder: NSCoder) {
    super.init()
    
    guard let payee       = aDecoder.decodeObjectForKey("payee")       as? String,
          let amount      = aDecoder.decodeObjectForKey("amount")     as? NSDecimalNumber,
          let typeRaw     = aDecoder.decodeObjectForKey("type")       as? String,
          let type        = TransactionType(rawValue: typeRaw),
          let datePosted  = aDecoder.decodeObjectForKey("datePosted") as? NSDate,
          let unique      = aDecoder.decodeObjectForKey("unique")     as? String else { return nil }
    
    self.payee      = payee
    self.amount     = amount
    self.type       = type
    self.datePosted = datePosted
    self.unique     = unique
    
    if let memo = aDecoder.decodeObjectForKey("memo") as? String {
      self.memo = memo
    }
    
    if let checkNum = aDecoder.decodeObjectForKey("checkNum") as? NSDecimalNumber {
      self.checkNum = checkNum
    }
    
    if let category = aDecoder.decodeObjectForKey("category") as? String {
      self.category = category
    }
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(self.payee, forKey: "payee")
    aCoder.encodeObject(self.amount, forKey: "amount")
    aCoder.encodeObject(self.type.rawValue, forKey: "type")
    aCoder.encodeObject(self.datePosted, forKey: "datePosted")
    aCoder.encodeObject(self.unique, forKey: "unique")
    aCoder.encodeObject(self.memo, forKey: "memo")
    aCoder.encodeObject(self.checkNum, forKey: "checkNum")
    aCoder.encodeObject(self.category, forKey: "category")
  }
}


//================================================
// MARK: TransactionType
//================================================
enum TransactionType: String {
  case Credit           = "CREDIT"
  case Debit            = "DEBIT"
  case Interest         = "INT"
  case Dividend         = "DIV"
  case Fee              = "FEE"
  case ServiceCharge    = "SRVCHG"
  case Deposit          = "DEP"
  case ATM              = "ATM"
  case PointOfSale      = "POS"
  case Transfer         = "XFER"
  case Check            = "CHECK"
  case Payment          = "PAYMENT"
  case Cash             = "CASH"
  case DirectDeposit    = "DIRECTDEP"
  case DirectDebit      = "DIRECTDEBIT"
  case RepeatedPayment  = "REPEATPMT"
  case Other            = "OTHER"
}