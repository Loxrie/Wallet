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
  var datePosted: Date!
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
    
    let dateFormatter         = DateFormatter()
    dateFormatter.timeZone    = TimeZone.default()
    dateFormatter.dateFormat  = "yyyyMMddhhmmss.SSS"
    
    // Check we have all the necessary values
    guard let name          = info[.name],
          let amountString  = info[.amount],
          let typeString    = info[.transactionType],
          let type          = TransactionType(rawValue: typeString),
          let dateString    = info[.datePosted],
          let datePosted    = dateFormatter.date(from: dateString),
          let unique        = info[.uniqueID] else { return nil }
    
    // For every transaction
    self.payee       = name
    self.amount     = NSDecimalNumber(string: amountString)
    self.type       = type
    self.datePosted = datePosted
    self.unique     = unique
    
    // For some transactions
    self.memo       = info[.memo]
    if let checkNum = info[.checkNum] {
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
    
    guard let payee       = aDecoder.decodeObject(forKey: "payee")       as? String,
          let amount      = aDecoder.decodeObject(forKey: "amount")     as? NSDecimalNumber,
          let typeRaw     = aDecoder.decodeObject(forKey: "type")       as? String,
          let type        = TransactionType(rawValue: typeRaw),
          let datePosted  = aDecoder.decodeObject(forKey: "datePosted") as? Date,
          let unique      = aDecoder.decodeObject(forKey: "unique")     as? String else { return nil }
    
    self.payee      = payee
    self.amount     = amount
    self.type       = type
    self.datePosted = datePosted
    self.unique     = unique
    
    if let memo = aDecoder.decodeObject(forKey: "memo") as? String {
      self.memo = memo
    }
    
    if let checkNum = aDecoder.decodeObject(forKey: "checkNum") as? NSDecimalNumber {
      self.checkNum = checkNum
    }
    
    if let category = aDecoder.decodeObject(forKey: "category") as? String {
      self.category = category
    }
  }
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(self.payee, forKey: "payee")
    aCoder.encode(self.amount, forKey: "amount")
    aCoder.encode(self.type.rawValue, forKey: "type")
    aCoder.encode(self.datePosted, forKey: "datePosted")
    aCoder.encode(self.unique, forKey: "unique")
    aCoder.encode(self.memo, forKey: "memo")
    aCoder.encode(self.checkNum, forKey: "checkNum")
    aCoder.encode(self.category, forKey: "category")
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
