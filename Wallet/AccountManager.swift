//
//  AccountManager.swift
//  Wallet
//
//  Created by Duff Neubauer on 10/18/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Foundation

struct AccountManager {
  static var sharedManager  = AccountManager()
  private var accounts      = [String: Account]() // [AccountNumber: Account]
  
  //========================================================================================
  // MARK: - Lifecycle
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // init()
  //----------------------------------------------------------------------------------------
  init() {
    if let accounts = NSKeyedUnarchiver.unarchiveObjectWithFile(self.dataPath()) as? [String: Account] {
      self.accounts = accounts
    }
  }
  
  //========================================================================================
  // MARK: - Add/Edit Bank Accounts
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // addAccount(account:)
  //----------------------------------------------------------------------------------------
  mutating func addAccount(account: Account) {
    self.accounts[account.accountNumber] = account
  }
  
  //----------------------------------------------------------------------------------------
  // allAccounts() -> [Account]
  //----------------------------------------------------------------------------------------
  func allAccounts() -> [Account] {
    return accounts.keys.sort().map({ accounts[$0]! })
  }
  
  //----------------------------------------------------------------------------------------
  // accountWithAccountNumber(accountNumber:) -> Account?
  //----------------------------------------------------------------------------------------
  func accountWithAccountNumber(accountNumber: String) -> Account? {
    return accounts[accountNumber]
  }
  
  //----------------------------------------------------------------------------------------
  // updateAccount(accountToUpdate:newAccount:) -> Bool
  //----------------------------------------------------------------------------------------
  mutating func updateAccount(accountToUpdate: Account, newAccount: Account) -> Bool {

    // Update transactions
    accountToUpdate.addTransactions(newAccount.postedTransactions())
    
    // Update balance
    if accountToUpdate.dateOfBalance.compare(newAccount.dateOfBalance) == .OrderedAscending {
      accountToUpdate.ledgerBalance = newAccount.ledgerBalance
      accountToUpdate.availBalance  = newAccount.availBalance
      accountToUpdate.dateOfBalance = newAccount.dateOfBalance
    }
    
    accounts[accountToUpdate.accountNumber] = accountToUpdate
    
    return true
  }
  
  //----------------------------------------------------------------------------------------
  // totalLedgerBalance() -> NSDecimalNumber
  //----------------------------------------------------------------------------------------
  func totalLedgerBalance() -> NSDecimalNumber {
    return self.allAccounts().reduce(NSDecimalNumber(double: 0.0), combine: { $0.decimalNumberByAdding($1.ledgerBalance) })
  }
  
  //================================================
  // MARK: Saving / Restoring State
  //================================================
  
  //----------------------------------------------------------------------------------------
  // dataPath() -> String
  //----------------------------------------------------------------------------------------
  func dataPath() -> String {
    let fileManager = NSFileManager.defaultManager()
    
    var folder = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)[0].path!
    folder = (folder as NSString).stringByAppendingPathComponent("Wallet")
    
    if !fileManager.fileExistsAtPath(folder) {
      do {
        try fileManager.createDirectoryAtPath(folder, withIntermediateDirectories: false, attributes: nil)
      } catch {}
    }
    
    let fileName = "Accounts.WBA"
    return (folder as NSString).stringByAppendingPathComponent(fileName)
  }
  
  //----------------------------------------------------------------------------------------
  // save()
  //----------------------------------------------------------------------------------------
  func save() {
    print("Data Path: \(self.dataPath())")
    NSKeyedArchiver.archiveRootObject(self.accounts, toFile: self.dataPath())
  }
}