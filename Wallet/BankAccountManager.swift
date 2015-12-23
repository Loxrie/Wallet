//
//  BankAccountManager.swift
//  Wallet
//
//  Created by Duff Neubauer on 12/22/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Foundation

struct BankAccountManager {
  static let sharedManager = BankAccountManager()
  var bankAccounts: [BankAccount] = []
  
  
  //========================================================================================
  // MARK: - Public Methods
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // addBankAccount(bankAccount:)
  //----------------------------------------------------------------------------------------
  func addBankAccount(bankAccount: BankAccount) {}
}