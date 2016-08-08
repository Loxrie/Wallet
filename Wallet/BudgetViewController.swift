//
//  BudgetViewController.swift
//  Wallet
//
//  Created by Duff Neubauer on 12/13/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Cocoa

class BudgetViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
  
  // Column IDs
  private let CATEGORY  = "category"
  private let ACTUAL    = "actual"
  private let GOAL      = "goal"
  private let NET       = "net"
  
  @IBOutlet weak var headerTableView: NSTableView!
  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var dateLabel: NSTextField!
  var budgetCategories = [BudgetCategory]()
  var transactions = [Transaction]()
  var currentComponents: DateComponents!
  lazy var numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currencyAccounting
    formatter.locale      = Locale.current()
    
    return formatter
  }()
  
  //========================================================================================
  // MARK: - Lifecycle
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // viewDidLoad()
  //----------------------------------------------------------------------------------------
  override func viewDidLoad() {
    
    // Set background to white
    let layer = CALayer()
    layer.backgroundColor = NSColor.white().cgColor
    self.view.wantsLayer = true
    self.view.layer = layer
    
    // TableView
    tableView.allowsMultipleSelection = true
    
    // Transactions in this month
    currentComponents = Calendar.current().components([.year, .month], from: Date())
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    
    self.monthDidChange(0)
    self.tableView.reloadData()
  }
  
  //========================================================================================
  // MARK: - IBActions
  //========================================================================================
  
  @IBAction func addCategory(_ sender: NSButton) {
    let defaultCategory = BudgetCategoryManager.sharedManager.newCategory()
    self.budgetCategories.append(defaultCategory)
    
    self.tableView.reloadData()
  }
  
  @IBAction func didChangeCategoryTitle(_ sender: NSTextField) {
    let row = self.tableView.row(for: sender)
    guard 0 ..< self.budgetCategories.count ~= row,
          let rowView = self.tableView.rowView(atRow: row, makeIfNecessary: false) else { return }
    
    let oldTitle = budgetCategories[row].title
    let newTitle = sender.stringValue.capitalizedString
    let category = BudgetCategoryManager.sharedManager.changeTitleOfCategory(oldTitle, to: newTitle)
    if category != nil {
      budgetCategories[row] = category!
    }
    
    // Redraw row
    let range = NSMakeRange(0, rowView.numberOfColumns)
    let columnIndexSet = IndexSet(integersIn: range.toRange() ?? 0..<0)
    self.tableView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: columnIndexSet)
  }
  
  @IBAction func didChangeGoal(_ sender: NSTextField) {
    let row = self.tableView.row(for: sender)
    guard 0 ..< self.budgetCategories.count ~= row,
          let rowView = self.tableView.rowView(atRow: row, makeIfNecessary: false),
          let number = self.numberFormatter.number(from: sender.stringValue) else { return }
    
    self.budgetCategories[row].goal = NSDecimalNumber(string: number.stringValue)
    
    // Redraw row
    let range = NSMakeRange(0, rowView.numberOfColumns)
    let columnIndexSet = IndexSet(integersIn: range.toRange() ?? 0..<0)
    self.tableView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: columnIndexSet)
  }
  
  @IBAction func goToToday(_ sender: AnyObject) {
    currentComponents = Calendar.current().components([.year, .month], from: Date())
    self.monthDidChange(0)
  }
  @IBAction func goToPreviousMonth(_ sender: AnyObject) {
    self.monthDidChange(-1)
  }
  @IBAction func goToNextMonth(_ sender: AnyObject) {
    self.monthDidChange(1)
  }
  
  //========================================================================================
  // MARK: - Private Methods
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // displayDate()
  //----------------------------------------------------------------------------------------
  func displayDate() {
    let month = DateFormatter().monthSymbols[currentComponents.month! - 1]
    dateLabel.stringValue = "\(month) \(currentComponents.year)"
  }
  
  //----------------------------------------------------------------------------------------
  // updateTransactions()
  //----------------------------------------------------------------------------------------
  func updateTransactions() {
    let calendar                = Calendar.current()
    var unfilteredTransactions  = [Transaction]()
    AccountManager.sharedManager.allAccounts().forEach({ unfilteredTransactions.append(contentsOf: $0.postedTransactions()) })
    
    transactions = unfilteredTransactions.filter({ calendar.components([.month, .year], from: $0.datePosted as Date) == currentComponents })
  }
  
  //----------------------------------------------------------------------------------------
  // updateBudgetCategories()
  //----------------------------------------------------------------------------------------
  func updateBudgetCategories() {
    
    // Reset Categories
    let categoryDict = BudgetCategoryManager.sharedManager.budgetCategories
    categoryDict.forEach({ $0.1.actual = 0 })
    
    // Re-calc categories
    transactions.forEach { (transaction) in
      guard let title     = transaction.category,
        let category  = categoryDict[title] else { return }
      
      category.addTransaction(transaction)
    }
    
    budgetCategories = categoryDict.keys.sorted().map({ categoryDict[$0]! })
  }
  
  //----------------------------------------------------------------------------------------
  // monthDidChange(change:)
  //----------------------------------------------------------------------------------------
  ///  0 = no change
  /// +1 = next month
  /// -1 = previous month
  func monthDidChange(_ change: Int) {
    guard change == 0 || change == 1 || change == -1 else { return }
    
    // Normalize month to 1...12
    if currentComponents.month == 12 && change == 1 {
      currentComponents.month = 1
      currentComponents.year = currentComponents.year! + 1
    }
    else if currentComponents.month == 1 && change == -1 {
      currentComponents.month = 12
      currentComponents.year = currentComponents.year! - 1
    }
    else {
      currentComponents.month = currentComponents.month! + change
    }
    
    self.displayDate()
    self.updateTransactions()
    self.updateBudgetCategories()
    self.tableView.reloadData()
  }
  
  //========================================================================================
  // MARK: - NSTableViewDelegate / NSTableViewDataSource
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // numberOfRowsInTableView(tableView:) -> Int
  //----------------------------------------------------------------------------------------
  func numberOfRows(in tableView: NSTableView) -> Int {
    return tableView == headerTableView ? 1 : budgetCategories.count
  }
  
  //----------------------------------------------------------------------------------------
  // tableView(tableView:viewForTableColumn:row:) -> NSView?
  //----------------------------------------------------------------------------------------
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let columnID  = tableColumn?.identifier,
          let view      = tableView.make(withIdentifier: columnID, owner: self)
          where row < self.budgetCategories.count else { return nil }

    let category = self.budgetCategories[row]
    
    switch (columnID, view) {
    case (CATEGORY, let cell as NSTableCellView):
      cell.textField?.stringValue = category.title
      cell.textField?.alignment = .right
      return cell
      
    case (ACTUAL, let cell as ActualBudgetTableCellView):
      var percent: Float = 0.0
      if category.goal.floatValue != 0 {
        percent = category.actual.dividing(by: category.goal).floatValue
      } else if category.goal.floatValue == 0 && category.actual.floatValue > 0 {
        percent = 100.0
      }
      cell.updatePercentFull(CGFloat(percent), withAmount: category.actual)
      return cell
      
    case (GOAL, let cell as NSTableCellView):
      cell.textField?.stringValue = self.numberFormatter.string(from: category.goal)!
      return cell
      
    case (NET, let cell as NSTableCellView):
      cell.textField?.stringValue = self.numberFormatter.string(from: category.net)!
      return cell
      
    default:
      return view
    }
  }
  
  //----------------------------------------------------------------------------------------
  // keyDown(theEvent:)
  //----------------------------------------------------------------------------------------
  /// If the backspace button is pressed when rows are selected, then we
  /// will delete those category objects
  override func keyDown(_ theEvent: NSEvent) {
    guard let key = (theEvent.charactersIgnoringModifiers as NSString?)?.character(at: 0)
          where Int(key) == NSDeleteCharacter else {
            return
    }
    
    let selectedIndexes = tableView.selectedRowIndexes
    selectedIndexes.reversed().forEach { (rowIndex) in
      BudgetCategoryManager.sharedManager.removeCategory(budgetCategories[rowIndex])
      budgetCategories.remove(at: rowIndex)
    }
    
    tableView.removeRows(at: selectedIndexes, withAnimation: NSTableViewAnimationOptions.effectFade)
  }
}
