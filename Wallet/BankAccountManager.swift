//
//  BankAccountManager.swift
//  Wallet
//
//  Created by Duff Neubauer on 10/18/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Foundation

struct BankAccountManager {
  static var sharedManager  = BankAccountManager()
  private var accounts      = [String: BankAccount]() // [AccountNumber: BankAccount]
  
  //========================================================================================
  // MARK: - Lifecycle
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // init()
  //----------------------------------------------------------------------------------------
  init() {
    if let accounts = NSKeyedUnarchiver.unarchiveObjectWithFile(self.dataPath()) as? [String: BankAccount] {
      self.accounts = accounts
    }
  }
  
  //========================================================================================
  // MARK: - Add/Edit Bank Accounts
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // addbankAccount(bankAccount:)
  //----------------------------------------------------------------------------------------
  mutating func addbankAccount(bankAccount: BankAccount) {
    self.accounts[bankAccount.accountNumber] = bankAccount
  }
  
  //----------------------------------------------------------------------------------------
  // allAccounts() -> [BankAccount]
  //----------------------------------------------------------------------------------------
  func allAccounts() -> [BankAccount] {
    return accounts.keys.sort().map({ accounts[$0]! })
  }
  
  //----------------------------------------------------------------------------------------
  // bankAccountWithAccountNumber(accountNumber:) -> BankAccount?
  //----------------------------------------------------------------------------------------
  func bankAccountWithAccountNumber(accountNumber: String) -> BankAccount? {
    return accounts[accountNumber]
  }
  
  //----------------------------------------------------------------------------------------
  // updateBankAccount(accountToUpdate:newAccount:) -> Bool
  //----------------------------------------------------------------------------------------
  mutating func updateBankAccount(accountToUpdate: BankAccount, newAccount: BankAccount) -> Bool {

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
    
    let fileName = "BankAccounts.WBA"
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