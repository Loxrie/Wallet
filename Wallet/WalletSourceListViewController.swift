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
    // Headers
    let accounts  = SourceListItem(title: "Accounts", asGroupItem: true)
    let budgets   = SourceListItem(title: "Budgets", asGroupItem: true)
    
    // Bank Account
    let allAccounts = AccountManager.sharedManager.allAccounts()
    for account in allAccounts {
      let accountItem                   = SourceListItem(title: account.title, asGroupItem: false)
      let bankAccountVC                 = self.storyboard?.instantiateControllerWithIdentifier("BankAccountViewController") as? BankAccountViewController
      bankAccountVC?.accountNumber  = account.accountNumber
      accountItem.viewController        = bankAccountVC
      accounts.children.append(accountItem)
    }
    
    // Budget
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