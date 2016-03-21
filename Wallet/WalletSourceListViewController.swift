//
//  WalletSourceListViewController.swift
//  Wallet
//
//  Created by Duff Neubauer on 12/23/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Cocoa

class WalletSourceListViewController: SourceListViewController {
  
  //========================================================================================
  // MARK: - Lifecycle
  //========================================================================================
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.refreshSourceItems()
  }
  
  override func refresh() {
    self.refreshSourceItems()
    
    super.refresh()
  }
  
  //========================================================================================
  // MARK: - Public Methods
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // refreshSourceItems()
  //----------------------------------------------------------------------------------------
  func refreshSourceItems() {
    
    let numberFormatter           = NSNumberFormatter()
    numberFormatter.numberStyle   = NSNumberFormatterStyle.CurrencyAccountingStyle
    if let account = AccountManager.sharedManager.allAccounts().first {
      numberFormatter.currencyCode = account.currencyCode
    } else {
      numberFormatter.currencyCode = NSLocale.currentLocale().valueForKey(NSLocaleCurrencyCode) as? String
    }
    
    // Accounts
    let accounts      = SourceListItem(title: "Accounts", asGroupItem: true)
    let allAccounts   = AccountManager.sharedManager.allAccounts()
    for account in allAccounts {
      
      // Create Source Item
      let accountItem               = SourceListItem(title: account.title, asGroupItem: false)
      accountItem.subtitle          = numberFormatter.stringFromNumber(account.ledgerBalance)!
      let bankAccountVC             = self.storyboard?.instantiateControllerWithIdentifier("BankAccountViewController") as? BankAccountViewController
      bankAccountVC?.accountNumber  = account.accountNumber
      accountItem.viewController    = bankAccountVC
      accounts.children.append(accountItem)
    }
    accounts.children = accounts.children.sort({ $0.title.localizedCompare($1.title) != .OrderedDescending })
    
    
    // Budget
    let budgets   = SourceListItem(title: "Budgets", asGroupItem: true)
    budgets.isSelectable = false
    
    let monthly = SourceListItem(title: "Budget", asGroupItem: false)
    monthly.viewController = self.storyboard?.instantiateControllerWithIdentifier("BudgetViewController") as? BudgetViewController
    budgets.children = [monthly]
//    
//    // Select the view we are testing
//    let index = self.sourceListViewController().outlineView.rowForItem(monthly)
//    self.sourceListViewController().outlineView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
    
    self.sourceItems = [accounts, budgets]
  }
  
  
  //----------------------------------------------------------------------------------------
  // accountsSourceListItem() -> SourceListItem
  //----------------------------------------------------------------------------------------
  func accountsSourceListItem() -> SourceListItem {
    return self.sourceItems[0]
  }
  
  //----------------------------------------------------------------------------------------
  // budgetSourceListItem() -> SourceListItem
  //----------------------------------------------------------------------------------------
  func budgetSourceListItem() -> SourceListItem {
    return self.sourceItems[1]
  }
}