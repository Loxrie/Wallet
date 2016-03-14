//
//  SplitViewController.swift
//  Wallet
//
//  Created by Duff Neubauer on 12/13/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController, SourceListViewControllerDelegate {
  
  // Storyboard IDs
  let oneViewControllerID   = "ONE"
  let twoViewControllerID   = "TWO"
  let threeViewControllerID = "THREE"
  let budgetViewController  = "BudgetViewController"
  
  lazy var openPanel: NSOpenPanel = {
    let panel = NSOpenPanel()
    panel.title = "Open Quicken file."
    panel.showsResizeIndicator = true
    panel.showsHiddenFiles = false
    panel.canChooseDirectories = false
    panel.allowsMultipleSelection = false
    panel.allowedFileTypes = ["qfx"]
    return panel
  }()
  
  //========================================================================================
  // MARK: - Lifecycle
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // viewDidLoad()
  //----------------------------------------------------------------------------------------
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Budget
    let budget = self.sourceListViewController().budgetSourceListItem()
    let monthly = SourceListItem(title: "Budget", asGroupItem: false)
    monthly.viewController = self.storyboard?.instantiateControllerWithIdentifier(self.budgetViewController) as? BudgetViewController
    budget.children = [monthly]

    self.sourceListViewController().refresh()
    
    // Select the view we are testing
    let index = self.sourceListViewController().outlineView.rowForItem(monthly)
    self.sourceListViewController().outlineView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
  }

  //========================================================================================
  // MARK: - IBActions
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // newBankAccount(sender:)
  //----------------------------------------------------------------------------------------
  @IBAction func newBankAccount(sender: AnyObject) {
    guard let window = NSApplication.sharedApplication().keyWindow else { return }
    self.openPanel.beginSheetModalForWindow(window, completionHandler: { (response:Int) -> Void in
      if response == NSModalResponseOK {
        
        let url = self.openPanel.URLs[0]
        guard let bankAccount = BankAccount(statement: url) else { return }
        
        if let existingAccount = BankAccountManager.sharedManager.bankAccountWithAccountNumber(bankAccount.accountNumber) {
          BankAccountManager.sharedManager.updateBankAccount(existingAccount, newAccount: bankAccount)
          self.detailViewController().childViewControllers.first?.viewWillAppear()
        } else {
          BankAccountManager.sharedManager.addbankAccount(bankAccount)
          self.sourceListViewController().refresh()
        }
      }
    })
  }
  
  //========================================================================================
  // MARK: - Private Methods
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // sourceListViewController()
  //----------------------------------------------------------------------------------------
  private func sourceListViewController() -> WalletSourceListViewController {
    let leftSplitViewItem = self.splitViewItems[0]
    let sourceListVC      = leftSplitViewItem.viewController as! WalletSourceListViewController
    sourceListVC.delegate = self
    
    return sourceListVC
  }
  
  //----------------------------------------------------------------------------------------
  // detailViewController()
  //----------------------------------------------------------------------------------------
  private func detailViewController() -> NSViewController {
    let rightSplitViewItem = self.splitViewItems[1]
    return rightSplitViewItem.viewController
  }
  
  //========================================================================================
  // MARK: - SourceListViewControllerDelegate
  //========================================================================================

  //----------------------------------------------------------------------------------------
  // displayViewController(viewController:)
  //----------------------------------------------------------------------------------------
  func displayViewController(viewController: NSViewController) {
    guard self.detailViewController() != viewController else { return }
    
    let detailViewController = self.detailViewController()
    
    // Remove old view controller
    if detailViewController.childViewControllers.count > 0 {
      detailViewController.removeChildViewControllerAtIndex(0)
      detailViewController.view.subviews[0].removeFromSuperview()
      detailViewController.view.translatesAutoresizingMaskIntoConstraints = true
    }
    
    // Add new view controller
    detailViewController.addChildViewController(viewController)
    detailViewController.view.addSubview(viewController.view)
    
    // Add contraints
    viewController.view.translatesAutoresizingMaskIntoConstraints = false
    let views = ["view": viewController.view]
    
    let horzContraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: views)
    let vertContraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: views)
    
    NSLayoutConstraint.activateConstraints(horzContraint)
    NSLayoutConstraint.activateConstraints(vertContraint)
  }
}
