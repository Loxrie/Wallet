//
//  Account.swift
//  Wallet
//
//  Created by Duff Neubauer on 11/24/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Cocoa

//================================================
// MARK: Account
//================================================
class Account: NSObject, NSCoding {
  private var transactions: [String: Transaction] = [:]
  var financialInstitution: FinancialInstitution
  var type:                 AccountType
  var accountNumber:        String
  var currencyCode:         String
  var ledgerBalance:        NSDecimalNumber
  var availBalance:         NSDecimalNumber
  var dateOfBalance:        NSDate
  var title:                String {
    return type.description()
  }
  
  //================================================
  // MARK: Lifecycle
  //================================================
  
  /// - paramater statement: A path to an .ofx file on disk
  init?(statement: NSURL) {
    guard let parser = OFXParser(ofxFile: statement) else { return nil }
    
    // Financial Institution
    guard let FIInfo    = parser.financialInstitutionInfo(),
          let FIString  = FIInfo[.Org],
          let FI        = FinancialInstitution(rawValue: FIString) else { return nil }
    self.financialInstitution = FI
    
    // Account Info
    guard let accountInfo   = parser.accountInfo(),
          let typeString    = accountInfo[.AccountType],
          let type          = AccountType(rawValue: typeString),
          let accountNumber = accountInfo[.AccountNumber],
          let currencyCode  = accountInfo[.Currency],
          let ledgerBalStr  = accountInfo[.LedgerBalance],
          let availBalStr   = accountInfo[.AvailableBalance],
          let dateOfBal     = accountInfo[.DateOfBalance] else { return nil }
    self.type                 = type
    self.accountNumber        = accountNumber
    self.currencyCode         = currencyCode
    self.ledgerBalance        = NSDecimalNumber(string: ledgerBalStr)
    self.availBalance         = NSDecimalNumber(string: availBalStr)
    
    let dateFormatter         = NSDateFormatter()
    dateFormatter.dateFormat  = "yyyyMMdd"
    self.dateOfBalance        = dateFormatter.dateFromString(dateOfBal)!
    
    super.init()
    
    // Transactions
    let transactions = parser.transactions()
    for transactionInfo in transactions  {
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
    
    guard let bankRaw       = aDecoder.decodeObjectForKey("financialInstitution") as? String,
          let FI            = FinancialInstitution(rawValue: bankRaw),
          let typeRaw       = aDecoder.decodeObjectForKey("type") as? String,
          let type          = AccountType(rawValue: typeRaw),
          let accountNumber = aDecoder.decodeObjectForKey("accountNumber") as? String,
          let currencyCode  = aDecoder.decodeObjectForKey("currencyCode") as? String,
          let transactions  = aDecoder.decodeObjectForKey("transactions") as? [String: Transaction],
          let ledgerBalance = aDecoder.decodeObjectForKey("ledgerBalance") as? NSDecimalNumber,
          let availBalance  = aDecoder.decodeObjectForKey("availableBalance") as? NSDecimalNumber,
          let dateOfBalance = aDecoder.decodeObjectForKey("dateOfBalance") as? NSDate else { return nil }
    
    self.financialInstitution = FI
    self.type                 = type
    self.accountNumber        = accountNumber
    self.currencyCode         = currencyCode
    self.transactions         = transactions
    self.ledgerBalance        = ledgerBalance
    self.availBalance         = availBalance
    self.dateOfBalance        = dateOfBalance
    
    super.init()
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(self.financialInstitution.rawValue, forKey: "financialInstitution")
    aCoder.encodeObject(self.type.rawValue, forKey: "type")
    aCoder.encodeObject(self.accountNumber, forKey: "accountNumber")
    aCoder.encodeObject(self.currencyCode, forKey: "currencyCode")
    aCoder.encodeObject(self.transactions, forKey: "transactions")
    aCoder.encodeObject(self.ledgerBalance, forKey: "ledgerBalance")
    aCoder.encodeObject(self.availBalance, forKey: "availableBalance")
    aCoder.encodeObject(self.dateOfBalance, forKey: "dateOfBalance")
  }
}
