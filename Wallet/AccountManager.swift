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
    if let accounts = NSKeyedUnarchiver.unarchiveObject(withFile: self.dataPath()) as? [String: Account] {
      self.accounts = accounts
    }
  }
  
  //========================================================================================
  // MARK: - Add/Edit Bank Accounts
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // addAccount(account:)
  //----------------------------------------------------------------------------------------
  mutating func addAccount(_ account: Account) {
    self.accounts[account.accountNumber] = account
  }
  
  //----------------------------------------------------------------------------------------
  // allAccounts() -> [Account]
  //----------------------------------------------------------------------------------------
  func allAccounts() -> [Account] {
    return accounts.keys.sorted().map({ accounts[$0]! })
  }
  
  //----------------------------------------------------------------------------------------
  // accountWithAccountNumber(accountNumber:) -> Account?
  //----------------------------------------------------------------------------------------
  func accountWithAccountNumber(_ accountNumber: String) -> Account? {
    return accounts[accountNumber]
  }
  
  //----------------------------------------------------------------------------------------
  // updateAccount(accountToUpdate:newAccount:) -> Bool
  //----------------------------------------------------------------------------------------
  mutating func updateAccount(_ accountToUpdate: Account, newAccount: Account) -> Bool {

    // Update transactions
    accountToUpdate.addTransactions(newAccount.postedTransactions())
    
    // Update balance
    if accountToUpdate.dateOfBalance.compare(newAccount.dateOfBalance as Date) == .orderedAscending {
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
    return self.allAccounts().reduce(NSDecimalNumber(value: 0.0), combine: { $0.adding($1.ledgerBalance) })
  }
  
  //================================================
  // MARK: Saving / Restoring State
  //================================================
  
  //----------------------------------------------------------------------------------------
  // dataPath() -> String
  //----------------------------------------------------------------------------------------
  func dataPath() -> String {
    let fileManager = FileManager.default()
    
    var folder = fileManager.urlsForDirectory(.applicationSupportDirectory, inDomains: .userDomainMask)[0].path!
    folder = (folder as NSString).appendingPathComponent("Wallet")
    
    if !fileManager.fileExists(atPath: folder) {
      do {
        try fileManager.createDirectory(atPath: folder, withIntermediateDirectories: false, attributes: nil)
      } catch {}
    }
    
    let fileName = "Accounts.WBA"
    return (folder as NSString).appendingPathComponent(fileName)
  }
  
  //----------------------------------------------------------------------------------------
  // save()
  //----------------------------------------------------------------------------------------
  func save() {
    print("Data Path: \(self.dataPath())")
    NSKeyedArchiver.archiveRootObject(self.accounts, toFile: self.dataPath())
  }
}
