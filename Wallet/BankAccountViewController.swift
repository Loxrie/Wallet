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
  @IBOutlet weak var finacialInstitutionField:  NSTextField!
//  @IBOutlet weak var availableBalanceTextField: NSTextField!
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
    layer.backgroundColor = NSColor.white().cgColor
    self.view.wantsLayer = true
    self.view.layer = layer
    
    // Set default NSTableView NSSortDescriptors
    tableView.sortDescriptors = [
      SortDescriptor(key: "datePosted", ascending: false, selector: "compare:")
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
    
    let numberFormatter                   = NumberFormatter()
    numberFormatter.numberStyle           = .currencyAccounting
    numberFormatter.currencyCode          = account.currencyCode
    
    accountTitleTextField.stringValue     = account.title
    finacialInstitutionField.stringValue  = account.financialInstitution.description()
    ledgerBalanceTextField.stringValue    = numberFormatter.string(from: account.ledgerBalance)!
//    availableBalanceTextField.stringValue = numberFormatter.stringFromNumber(account.availBalance)!
    
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
  func numberOfRows(in tableView: NSTableView) -> Int {
    // Sort Transactions
    if let account = account {
      let sortDescriptors = tableView.sortDescriptors
      let unsortedTrans   = account.postedTransactions() as NSArray
      transactions        = unsortedTrans.sortedArray(using: sortDescriptors) as! [Transaction]
    }
    
    return transactions.count
  }
  
  //----------------------------------------------------------------------------------------
  // tableView(tableView:sortDescriptorsDidChange:)
  //----------------------------------------------------------------------------------------
  /// Called when the user clicks a column header
  func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [SortDescriptor]) {
    self.tableView.reloadData()
  }

  
  //========================================================================================
  // MARK: - NSTableViewDelegate
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // tableView(tableView:viewForTableColumn:row:) -> NSView?
  //----------------------------------------------------------------------------------------
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let columnID  = tableColumn?.identifier,
          let cell      = tableView.make(withIdentifier: columnID, owner: self) as? NSTableCellView
          where transactions.count > row else { return nil }

    let transaction = self.transactions[row]
    
    if columnID == "Date" {
      let dateFormatter         = DateFormatter()
      dateFormatter.dateFormat  = "yyyy-MM-dd"
      
      cell.textField?.stringValue = dateFormatter.string(from: transaction.datePosted as Date)
    }
    else if columnID == "Payee" {
      cell.textField?.stringValue = transaction.payee
    }
    else if columnID == "Category" {
      guard let categoryCell = cell as? CategoryTableViewCell else { return nil }
      categoryCell.delegate  = self
      
      let titles = BudgetCategoryManager.sharedManager.budgetTitles()
      
      categoryCell.popUpButton.removeAllItems()
      categoryCell.popUpButton.addItems(withTitles: titles)
      categoryCell.popUpButton.title = transaction.category != nil ? transaction.category! : ""
    }
    else if columnID == "Amount" {
      let numberFormatter           = NumberFormatter()
      numberFormatter.numberStyle   = NumberFormatter.Style.currencyAccounting
      numberFormatter.currencyCode  = self.account?.currencyCode
      
      cell.textField?.stringValue = numberFormatter.string(from: transaction.amount)!
    }
    
    return cell
  }
  
  //========================================================================================
  // MARK: - CategoryTableCellView
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // categoryCell(cell:didChangeSelectionFrom:To:)
  //----------------------------------------------------------------------------------------
  func categoryCell(_ cell: CategoryTableViewCell, didChangeSelectionTo newSelection: String) {
    let transactionIndex  = self.tableView.row(for: cell)
    transactions[transactionIndex].category = newSelection
  }
  
  //========================================================================================
  // MARK: - Balance Graph
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // labelsForAxis(axis:) -> [(CGFloat, String)]
  //----------------------------------------------------------------------------------------
  func labelsForAxis(_ axis: GraphAxis) -> [(CGFloat, String)] {
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
  private func dateCategories(_ data: [Date]) -> [CGFloat] {
    guard data.count > 0 else { return [] }
    
    let minDate = data.min(isOrderedBefore: { return $0.compare($1) != .orderedDescending })!
    return data.map({ CGFloat($0.numberOfDaysSinceDate(minDate)) })
  }
  
  //----------------------------------------------------------------------------------------
  // <#function#>
  //----------------------------------------------------------------------------------------
  private func balanceValues(_ data: [NSDecimalNumber]) -> [CGFloat] {
    return data.map({ CGFloat($0.floatValue) })
  }
  
  //----------------------------------------------------------------------------------------
  // <#function#>
  //----------------------------------------------------------------------------------------
  private func gatherBankAccountGraphData() -> [(Date, NSDecimalNumber)]{
    guard let account = account else { return [] }
    
    var tuples: [(Date, NSDecimalNumber)] = []
    var balance = account.availBalance
    var date    = Date()
    tuples.append((date, balance))
    
    let sortedTransactions = account.transactionsSortedBy("datePosted", ascending: false)
    for transaction in sortedTransactions {
      balance = balance.adding(transaction.amount)
      date    = transaction.datePosted
      tuples.append((date, balance))
    }
    
    return tuples
  }
}
