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
    monthly.viewController = self.storyboard?.instantiateController(withIdentifier: self.budgetViewController) as? BudgetViewController
    budget.children = [monthly]

    self.sourceListViewController().refresh()
    
    // Select the view we are testing
    let index = self.sourceListViewController().outlineView.row(forItem: monthly)
    self.sourceListViewController().outlineView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
  }

  //========================================================================================
  // MARK: - IBActions
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // newBankAccount(sender:)
  //----------------------------------------------------------------------------------------
  @IBAction func newBankAccount(_ sender: AnyObject) {
    guard let window = NSApplication.shared().keyWindow else { return }
    self.openPanel.beginSheetModal(for: window, completionHandler: { (response:Int) -> Void in
      if response == NSModalResponseOK {
        
        let url = self.openPanel.urls[0]
        guard let account = Account(statement: url) else { return }
        
        if let existingAccount = AccountManager.sharedManager.accountWithAccountNumber(account.accountNumber) {
          AccountManager.sharedManager.updateAccount(existingAccount, newAccount: account)
          self.detailViewController().childViewControllers.first?.viewWillAppear()
        } else {
          AccountManager.sharedManager.addAccount(account)
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
  func displayViewController(_ viewController: NSViewController) {
    guard self.detailViewController() != viewController else { return }
    
    let detailViewController = self.detailViewController()
    
    // Remove old view controller
    if detailViewController.childViewControllers.count > 0 {
      detailViewController.removeChildViewController(at: 0)
      detailViewController.view.subviews[0].removeFromSuperview()
      detailViewController.view.translatesAutoresizingMaskIntoConstraints = true
    }
    
    // Add new view controller
    detailViewController.addChildViewController(viewController)
    detailViewController.view.addSubview(viewController.view)
    
    // Add contraints
    viewController.view.translatesAutoresizingMaskIntoConstraints = false
    let views = ["view": viewController.view]
    
    let horzContraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views)
    let vertContraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: views)
    
    NSLayoutConstraint.activate(horzContraint)
    NSLayoutConstraint.activate(vertContraint)
  }
}
