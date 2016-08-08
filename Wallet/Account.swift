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
  var dateOfBalance:        Date
  var title:                String {
    return type.description()
  }
  
  //================================================
  // MARK: Lifecycle
  //================================================
  
  /// - paramater statement: A path to an .ofx file on disk
  init?(statement: URL) {
    guard let parser = OFXParser(ofxFile: statement) else { return nil }
    
    // Financial Institution
    guard let FIInfo    = parser.financialInstitutionInfo(),
          let FIString  = FIInfo[.org],
          let FI        = FinancialInstitution(rawValue: FIString) else { return nil }
    self.financialInstitution = FI
    
    // Account Info
    guard let accountInfo   = parser.accountInfo(),
          let typeString    = accountInfo[.accountType],
          let type          = AccountType(rawValue: typeString),
          let accountNumber = accountInfo[.accountNumber],
          let currencyCode  = accountInfo[.currency],
          let ledgerBalStr  = accountInfo[.ledgerBalance],
          let availBalStr   = accountInfo[.availableBalance],
          let dateOfBal     = accountInfo[.dateOfBalance] else { return nil }
    self.type                 = type
    self.accountNumber        = accountNumber
    self.currencyCode         = currencyCode
    self.ledgerBalance        = NSDecimalNumber(string: ledgerBalStr)
    self.availBalance         = NSDecimalNumber(string: availBalStr)
    
    let dateFormatter         = DateFormatter()
    dateFormatter.dateFormat  = "yyyyMMdd"
    self.dateOfBalance        = dateFormatter.date(from: dateOfBal)!
    
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
  func addTransactions(_ transactions: [Transaction]) {
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
  func addTransaction(_ transaction: Transaction) {
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
  func transactionsSortedBy(_ key: String, ascending: Bool) -> [Transaction] {
    let sorter = SortDescriptor(key: key, ascending: ascending, selector: "compare:")
    let unsortedTransactions = self.postedTransactions() as NSArray
    return unsortedTransactions.sortedArray(using: [sorter]) as! [Transaction]
  }
  
  //================================================
  // MARK: NSCoding
  //================================================
  required init?(coder aDecoder: NSCoder) {
    
    guard let bankRaw       = aDecoder.decodeObject(forKey: "financialInstitution") as? String,
          let FI            = FinancialInstitution(rawValue: bankRaw),
          let typeRaw       = aDecoder.decodeObject(forKey: "type") as? String,
          let type          = AccountType(rawValue: typeRaw),
          let accountNumber = aDecoder.decodeObject(forKey: "accountNumber") as? String,
          let currencyCode  = aDecoder.decodeObject(forKey: "currencyCode") as? String,
          let transactions  = aDecoder.decodeObject(forKey: "transactions") as? [String: Transaction],
          let ledgerBalance = aDecoder.decodeObject(forKey: "ledgerBalance") as? NSDecimalNumber,
          let availBalance  = aDecoder.decodeObject(forKey: "availableBalance") as? NSDecimalNumber,
          let dateOfBalance = aDecoder.decodeObject(forKey: "dateOfBalance") as? Date else { return nil }
    
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
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(self.financialInstitution.rawValue, forKey: "financialInstitution")
    aCoder.encode(self.type.rawValue, forKey: "type")
    aCoder.encode(self.accountNumber, forKey: "accountNumber")
    aCoder.encode(self.currencyCode, forKey: "currencyCode")
    aCoder.encode(self.transactions, forKey: "transactions")
    aCoder.encode(self.ledgerBalance, forKey: "ledgerBalance")
    aCoder.encode(self.availBalance, forKey: "availableBalance")
    aCoder.encode(self.dateOfBalance, forKey: "dateOfBalance")
  }
}
