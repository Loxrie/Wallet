//
//  BankAccountViewController.swift
//  Wallet
//
//  Created by Duff Neubauer on 12/23/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Cocoa

class BankAccountViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, GraphLabelDelegate, CategoryTableViewCellDelegate {
  
  @IBOutlet weak var accountTitleTextField:     NSTextField!
  @IBOutlet weak var ledgerBalanceTextField:    NSTextField!
  @IBOutlet weak var availableBalanceTextField: NSTextField!
  @IBOutlet weak var tableView:                 NSTableView!
//  @IBOutlet weak var bankAccountGraph: LineGraph!
  var accountNumber:                            String!
  var transactions:                             [Transaction] = []
  var account:                                  Account? {
    return accountNumber != nil ? AccountManager.sharedManager.accountWithAccountNumber(accountNumber) : nil
  }
  
  //========================================================================================
  // MARK: - Lifecycle
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // viewDidLoad()
  //----------------------------------------------------------------------------------------
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set background to white
    let layer = CALayer()
    layer.backgroundColor = NSColor.whiteColor().CGColor
    self.view.wantsLayer = true
    self.view.layer = layer
    
    // Set default NSTableView NSSortDescriptors
    tableView.sortDescriptors = [
      NSSortDescriptor(key: "datePosted", ascending: false, selector: "compare:")
    ]
    
//    bankAccountGraph.delegate = self
  }
  
  //----------------------------------------------------------------------------------------
  // viewWillAppear()
  //----------------------------------------------------------------------------------------
  override func viewWillAppear() {
    super.viewDidLoad()
    
    guard let account = account else { return }
    
    tableView.reloadData()
    
    let numberFormatter                   = NSNumberFormatter()
    numberFormatter.numberStyle           = .CurrencyAccountingStyle
    numberFormatter.currencyCode          = account.currencyCode
    
    accountTitleTextField.stringValue     = account.title
    ledgerBalanceTextField.stringValue    = numberFormatter.stringFromNumber(account.ledgerBalance)!
    availableBalanceTextField.stringValue = numberFormatter.stringFromNumber(account.availBalance)!
    
//    // Load graph values
//    let graphData               = gatherBankAccountGraphData()
//    bankAccountGraph.categories = self.dateCategories(graphData.map({ $0.0 }))
//    bankAccountGraph.values     = self.balanceValues(graphData.map({ $0.1 }))
  }
  
  //========================================================================================
  // MARK: - NSTableViewDataSource
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // numberOfRowsInTableView(tableView: NSTableView) -> Int
  //----------------------------------------------------------------------------------------
  func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    // Sort Transactions
    if let account = account {
      let sortDescriptors = tableView.sortDescriptors
      let unsortedTrans   = account.postedTransactions() as NSArray
      transactions        = unsortedTrans.sortedArrayUsingDescriptors(sortDescriptors) as! [Transaction]
    }
    
    return transactions.count
  }
  
  //----------------------------------------------------------------------------------------
  // tableView(tableView:sortDescriptorsDidChange:)
  //----------------------------------------------------------------------------------------
  /// Called when the user clicks a column header
  func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
    self.tableView.reloadData()
  }

  
  //========================================================================================
  // MARK: - NSTableViewDelegate
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // tableView(tableView:viewForTableColumn:row:) -> NSView?
  //----------------------------------------------------------------------------------------
  func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let columnID  = tableColumn?.identifier,
          let cell      = tableView.makeViewWithIdentifier(columnID, owner: self) as? NSTableCellView
          where transactions.count > row else { return nil }

    let transaction = self.transactions[row]
    
    if columnID == "Date" {
      let dateFormatter         = NSDateFormatter()
      dateFormatter.dateFormat  = "yyyy-MM-dd"
      
      cell.textField?.stringValue = dateFormatter.stringFromDate(transaction.datePosted)
    }
    else if columnID == "Payee" {
      cell.textField?.stringValue = transaction.payee
    }
    else if columnID == "Category" {
      guard let categoryCell = cell as? CategoryTableViewCell else { return nil }
      categoryCell.delegate  = self
      
      let titles = BudgetCategoryManager.sharedManager.budgetTitles()
      
      categoryCell.popUpButton.removeAllItems()
      categoryCell.popUpButton.addItemsWithTitles(titles)
      categoryCell.popUpButton.title = transaction.category != nil ? transaction.category! : ""
    }
    else if columnID == "Amount" {
      let numberFormatter           = NSNumberFormatter()
      numberFormatter.numberStyle   = NSNumberFormatterStyle.CurrencyAccountingStyle
      numberFormatter.currencyCode  = self.account?.currencyCode
      
      cell.textField?.stringValue = numberFormatter.stringFromNumber(transaction.amount)!
    }
    
    return cell
  }
  
  //========================================================================================
  // MARK: - CategoryTableCellView
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // categoryCell(cell:didChangeSelectionFrom:To:)
  //----------------------------------------------------------------------------------------
  func categoryCell(cell: CategoryTableViewCell, didChangeSelectionTo newSelection: String) {
    let transactionIndex  = self.tableView.rowForView(cell)
    transactions[transactionIndex].category = newSelection
  }
  
  //========================================================================================
  // MARK: - Balance Graph
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // labelsForAxis(axis:) -> [(CGFloat, String)]
  //----------------------------------------------------------------------------------------
  func labelsForAxis(axis: GraphAxis) -> [(CGFloat, String)] {
    return axis == .xAxis ? self.dateLabels() : self.balanceAmountLabels()
  }
  
  //----------------------------------------------------------------------------------------
  // <#function#>
  //----------------------------------------------------------------------------------------
  private func dateLabels() -> [(CGFloat, String)] {
    return [(20, "A Date")]
  }
  
  //----------------------------------------------------------------------------------------
  // <#function#>
  //----------------------------------------------------------------------------------------
  private func balanceAmountLabels() -> [(CGFloat, String)] {
    return [(10000, "$10,000")]
  }
  
  //----------------------------------------------------------------------------------------
  // <#function#>
  //----------------------------------------------------------------------------------------
  /// This function takes advantage of an NSDate extension `numberOfDaysSinceDate`
  private func dateCategories(data: [NSDate]) -> [CGFloat] {
    guard data.count > 0 else { return [] }
    
    let minDate = data.minElement({ return $0.compare($1) != .OrderedDescending })!
    return data.map({ CGFloat($0.numberOfDaysSinceDate(minDate)) })
  }
  
  //----------------------------------------------------------------------------------------
  // <#function#>
  //----------------------------------------------------------------------------------------
  private func balanceValues(data: [NSDecimalNumber]) -> [CGFloat] {
    return data.map({ CGFloat($0.floatValue) })
  }
  
  //----------------------------------------------------------------------------------------
  // <#function#>
  //----------------------------------------------------------------------------------------
  private func gatherBankAccountGraphData() -> [(NSDate, NSDecimalNumber)]{
    guard let account = account else { return [] }
    
    var tuples: [(NSDate, NSDecimalNumber)] = []
    var balance = account.availBalance
    var date    = NSDate()
    tuples.append((date, balance))
    
    let sortedTransactions = account.transactionsSortedBy("datePosted", ascending: false)
    for transaction in sortedTransactions {
      balance = balance.decimalNumberByAdding(transaction.amount)
      date    = transaction.datePosted
      tuples.append((date, balance))
    }
    
    return tuples
  }
}
