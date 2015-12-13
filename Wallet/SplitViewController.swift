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
  
  //----------------------------------------------------------------------------------------
  // sourceListViewController()
  //----------------------------------------------------------------------------------------
  func sourceListViewController() -> SourceListViewController {
    let leftSplitViewItem = self.splitViewItems[0]
    let sourceListVC      = leftSplitViewItem.viewController as! SourceListViewController
    sourceListVC.delegate = self
    
    return sourceListVC
  }
  
  //----------------------------------------------------------------------------------------
  // detailViewController()
  //----------------------------------------------------------------------------------------
  func detailViewController() -> NSViewController {
    let rightSplitViewItem = self.splitViewItems[1]
    return rightSplitViewItem.viewController
  }
  
  // MARK: - Lifecycle
  
  //----------------------------------------------------------------------------------------
  // viewDidLoad()
  //----------------------------------------------------------------------------------------
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set up source list
    let numbers = SourceListItem(title: "Numbers", asGroupItem: true)
    
    let one     = SourceListItem(title: "One", asGroupItem: false)
    let two     = SourceListItem(title: "Two", asGroupItem: false)
    let three   = SourceListItem(title: "Three", asGroupItem: false)
    
    one.viewController    = self.storyboard?.instantiateControllerWithIdentifier(self.oneViewControllerID) as? NSViewController
    two.viewController    = self.storyboard?.instantiateControllerWithIdentifier(self.twoViewControllerID) as? NSViewController
    three.viewController  = self.storyboard?.instantiateControllerWithIdentifier(self.threeViewControllerID) as? NSViewController
    
    numbers.children = [one, two, three]
    
    self.sourceListViewController().sourceItems = [numbers]
    self.sourceListViewController().refresh()
  }

  // MARK: - IBActions
  
  //----------------------------------------------------------------------------------------
  // newBankAccount(sender:)
  //----------------------------------------------------------------------------------------
  @IBAction func newBankAccount(sender: AnyObject) {
    guard let window = NSApplication.sharedApplication().keyWindow else { return }
    self.openPanel.beginSheetModalForWindow(window, completionHandler: { (response:Int) -> Void in
      if response == NSModalResponseOK {
        
        let url = self.openPanel.URLs[0]
        print("Add bank account from \(url.path!)")
//        BankAccountManager.sharedManager.addBankAccountFromStatement(url)
//        self.refreshSourceList()
      }
    })
  }
  
  // MARK: - SourceListViewControllerDelegate

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
