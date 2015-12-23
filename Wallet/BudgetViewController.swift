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
  
  @IBOutlet weak var tableView: NSTableView!
  var budgetCategories = [BudgetCategory]()
  lazy var numberFormatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .CurrencyAccountingStyle
    formatter.locale      = NSLocale.currentLocale()
    
    return formatter
  }()
  
  // MARK: - Lifecycle
  
  //----------------------------------------------------------------------------------------
  // awakeFromNib
  //----------------------------------------------------------------------------------------
  override func awakeFromNib() {
    
    // Set background to white
    let layer = CALayer()
    layer.backgroundColor = NSColor.whiteColor().CGColor
    self.view.wantsLayer = true
    self.view.layer = layer
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    
    self.budgetCategories = [
      BudgetCategory(title: "Home", goal: NSDecimalNumber(double: 250.0)),
      BudgetCategory(title: "Groceries", goal: NSDecimalNumber(double: 400.0)),
      BudgetCategory(title: "Food", goal: NSDecimalNumber(double: 100.0)),
      BudgetCategory(title: "Date Night", goal: NSDecimalNumber(double: 100.0)),
      BudgetCategory(title: "Personal Items", goal: NSDecimalNumber(double: 200.0)),
      BudgetCategory(title: "Other", goal: NSDecimalNumber(double: 50.0))
    ]
    
    self.budgetCategories[0].actual = NSDecimalNumber(double: 75.0)
    self.budgetCategories[1].actual = NSDecimalNumber(double: 370.0)
    self.budgetCategories[2].actual = NSDecimalNumber(double: 50.0)
    self.budgetCategories[3].actual = NSDecimalNumber(double: 63.0)
    self.budgetCategories[4].actual = NSDecimalNumber(double: 282.0)
    self.budgetCategories[5].actual = NSDecimalNumber(double: 10.0)
    
    self.tableView.reloadData()
  }
  
  // MARK: - IBActions
  
  @IBAction func addCategory(sender: NSButton) {
    var defaultCategory = BudgetCategory.defaultCategory()
    
    // Check if default category already exists
    var title       = defaultCategory.title
    var index       = 0
    let categories  = self.budgetCategories.map({ $0.title })
    while categories.contains(title) {
      var base = title
      if let range = title.rangeOfString(" \(index)") {
        base = title.substringToIndex(range.startIndex)
      }
      title = "\(base) \(++index)"
    }
    
    defaultCategory.title = title
    self.budgetCategories.append(defaultCategory)
    
    self.tableView.reloadData()
  }
  
  @IBAction func didChangeCategoryTitle(sender: NSTextField) {
    let row = self.tableView.rowForView(sender)
    guard 0 ..< self.budgetCategories.count ~= row,
          let rowView = self.tableView.rowViewAtRow(row, makeIfNecessary: false) else { return }
    
    let newTitle = sender.stringValue.capitalizedString
    self.budgetCategories[row].title = newTitle
    
    // Redraw row
    let range = NSMakeRange(0, rowView.numberOfColumns)
    let columnIndexSet = NSIndexSet(indexesInRange: range)
    self.tableView.reloadDataForRowIndexes(NSIndexSet(index: row), columnIndexes: columnIndexSet)
  }
  
  @IBAction func didChangeGoal(sender: NSTextField) {
    let row = self.tableView.rowForView(sender)
    guard 0 ..< self.budgetCategories.count ~= row,
          let rowView = self.tableView.rowViewAtRow(row, makeIfNecessary: false),
          let number = self.numberFormatter.numberFromString(sender.stringValue) else { return }
    
    self.budgetCategories[row].goal = NSDecimalNumber(string: number.stringValue)
    
    // Redraw row
    let range = NSMakeRange(0, rowView.numberOfColumns)
    let columnIndexSet = NSIndexSet(indexesInRange: range)
    self.tableView.reloadDataForRowIndexes(NSIndexSet(index: row), columnIndexes: columnIndexSet)
  }
  
  // MARK: - NSTableViewDelegate / NSTableViewDataSource
  
  //----------------------------------------------------------------------------------------
  // numberOfRowsInTableView(tableView:) -> Int
  //----------------------------------------------------------------------------------------
  func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    return self.budgetCategories.count
  }
  
  func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let columnID  = tableColumn?.identifier,
          let view      = tableView.makeViewWithIdentifier(columnID, owner: self)
          where row < self.budgetCategories.count else { return nil }

    let category = self.budgetCategories[row]
    
    switch (columnID, view) {
    case (CATEGORY, let cell as NSTableCellView):
      cell.textField?.stringValue = category.title
      cell.textField?.alignment = .Right
      return cell
      
    case (ACTUAL, let cell as ActualBudgetTableCellView):
      let percent = category.goal.floatValue > 0 ? category.actual.decimalNumberByDividingBy(category.goal) : 0.0
      cell.updatePercentFull(CGFloat(percent))
      return cell
      
    case (GOAL, let cell as NSTableCellView):
      cell.textField?.stringValue = self.numberFormatter.stringFromNumber(category.goal)!
      return cell
      
    case (NET, let cell as NSTableCellView):
      cell.textField?.stringValue = self.numberFormatter.stringFromNumber(category.net)!
      return cell
      
    default:
      return view
    }
  }
}
