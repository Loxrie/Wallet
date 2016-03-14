//
//  BankAccount.swift
//  Wallet
//
//  Created by Duff Neubauer on 11/24/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Cocoa

//================================================
// MARK: BankAccount
//================================================
class BankAccount: NSObject, NSCoding {
  private var transactions: [String: Transaction] = [:]
  var bank:                 Bank
  var type:                 BankAccountType
  var accountNumber:        String
  var routingNumber:        String
  var currencyCode:         String
  var ledgerBalance:        NSDecimalNumber
  var availBalance:         NSDecimalNumber
  var dateOfBalance:        NSDate
  var title:                String {
    return "\(bank.description()) - \(type.description())"
  }
  
  //================================================
  // MARK: Lifecycle
  //================================================
  
  /// - paramater statement: A path to an .ofx file on disk
  init?(statement: NSURL) {
    
    guard let parser        = OFXParser(ofxFile: statement),
          let bankInfo      = parser.bankInformation(),
          let bankString    = bankInfo[.Org],
          let bank          = Bank(rawValue: bankString),
          let typeString    = bankInfo[.AccountType],
          let type          = BankAccountType(rawValue: typeString),
          let accountNumber = bankInfo[.AccountNumber],
          let routingNumber = bankInfo[.RoutingNumber],
          let currencyCode  = bankInfo[.Currency],
          let ledgerBalStr  = bankInfo[.LedgerBalance],
          let availBalStr   = bankInfo[.AvailableBalance],
          let dateOfBal     = bankInfo[.DateOfBalance] else { return nil }
    
    // Bank account info
    self.bank           = bank
    self.type           = type
    self.accountNumber  = accountNumber
    self.routingNumber  = routingNumber
    self.currencyCode   = currencyCode
    self.ledgerBalance  = NSDecimalNumber(string: ledgerBalStr)
    self.availBalance   = NSDecimalNumber(string: availBalStr)
    
    let dateFormatter         = NSDateFormatter()
    dateFormatter.dateFormat  = "yyyyMMddhhmmss.sss"
    self.dateOfBalance        = dateFormatter.dateFromString(dateOfBal)!
    
    super.init()
    
    // Transactions
    for transactionInfo in parser.bankTransactions() {
      if let transaction = Transaction(transactionInfo) {
        self.addTransaction(transaction)
      }
    }
  }
  
  //========================================================================================
  // MARK: - Public Methods
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // addTransactions(transactions:)
  //----------------------------------------------------------------------------------------
  func addTransactions(transactions: [Transaction]) {
    for transaction in transactions {
      let existingTransaction = self.transactions[transaction.unique]
      if existingTransaction == nil {
        self.transactions[transaction.unique] = transaction
      }
    }
  }
  
  //----------------------------------------------------------------------------------------
  // addTransaction(transaction:)
  //----------------------------------------------------------------------------------------
  func addTransaction(transaction: Transaction) {
    if self.transactions[transaction.unique] == nil {
      self.transactions[transaction.unique] = transaction
    }
  }
  
  //----------------------------------------------------------------------------------------
  // postedTransactions() -> [Transaction]
  //----------------------------------------------------------------------------------------
  func postedTransactions() -> [Transaction] {
    return Array(self.transactions.values)
  }
  
  //----------------------------------------------------------------------------------------
  // transactionsSortedBy(key:ascending:) -> [Transaction]
  //----------------------------------------------------------------------------------------
  func transactionsSortedBy(key: String, ascending: Bool) -> [Transaction] {
    let sorter = NSSortDescriptor(key: key, ascending: ascending, selector: "compare:")
    let unsortedTransactions = self.postedTransactions() as NSArray
    return unsortedTransactions.sortedArrayUsingDescriptors([sorter]) as! [Transaction]
  }
  
  //================================================
  // MARK: NSCoding
  //================================================
  required init?(coder aDecoder: NSCoder) {
    
    guard let bankRaw       = aDecoder.decodeObjectForKey("bank") as? String,
      let bank          = Bank(rawValue: bankRaw),
      let typeRaw       = aDecoder.decodeObjectForKey("type") as? String,
      let type          = BankAccountType(rawValue: typeRaw),
      let accountNumber = aDecoder.decodeObjectForKey("accountNumber") as? String,
      let routingNumber = aDecoder.decodeObjectForKey("routingNumber") as? String,
      let currencyCode  = aDecoder.decodeObjectForKey("currencyCode") as? String,
      let transactions  = aDecoder.decodeObjectForKey("transactions") as? [String: Transaction],
      let ledgerBalance = aDecoder.decodeObjectForKey("ledgerBalance") as? NSDecimalNumber,
      let availBalance  = aDecoder.decodeObjectForKey("availableBalance") as? NSDecimalNumber,
      let dateOfBalance = aDecoder.decodeObjectForKey("dateOfBalance") as? NSDate else { return nil }
    
    self.bank           = bank
    self.type           = type
    self.accountNumber  = accountNumber
    self.routingNumber  = routingNumber
    self.currencyCode   = currencyCode
    self.transactions   = transactions
    self.ledgerBalance  = ledgerBalance
    self.availBalance   = availBalance
    self.dateOfBalance  = dateOfBalance
    
    super.init()
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(self.bank.rawValue, forKey: "bank")
    aCoder.encodeObject(self.type.rawValue, forKey: "type")
    aCoder.encodeObject(self.accountNumber, forKey: "accountNumber")
    aCoder.encodeObject(self.routingNumber, forKey: "routingNumber")
    aCoder.encodeObject(self.currencyCode, forKey: "currencyCode")
    aCoder.encodeObject(self.transactions, forKey: "transactions")
    aCoder.encodeObject(self.ledgerBalance, forKey: "ledgerBalance")
    aCoder.encodeObject(self.availBalance, forKey: "availableBalance")
    aCoder.encodeObject(self.dateOfBalance, forKey: "dateOfBalance")
  }
}
