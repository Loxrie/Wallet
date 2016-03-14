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
  
  //========================================================================================
  // MARK: - Lifecycle
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // viewDidLoad()
  //----------------------------------------------------------------------------------------
  override func viewDidLoad() {
    
    // Set background to white
    let layer = CALayer()
    layer.backgroundColor = NSColor.whiteColor().CGColor
    self.view.wantsLayer = true
    self.view.layer = layer
    
    // TableView
    tableView.allowsMultipleSelection = true
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    
    self.budgetCategories = BudgetCategoryManager.sharedManager.updatedCategories()
    
    self.budgetCategories.forEach({ print($0) })
    
    self.tableView.reloadData()
  }
  
  //========================================================================================
  // MARK: - IBActions
  //========================================================================================
  
  @IBAction func addCategory(sender: NSButton) {
    let defaultCategory = BudgetCategoryManager.sharedManager.newCategory()
    self.budgetCategories.append(defaultCategory)
    
    self.tableView.reloadData()
  }
  
  @IBAction func didChangeCategoryTitle(sender: NSTextField) {
    let row = self.tableView.rowForView(sender)
    guard 0 ..< self.budgetCategories.count ~= row,
          let rowView = self.tableView.rowViewAtRow(row, makeIfNecessary: false) else { return }
    
    let oldTitle = budgetCategories[row].title
    let newTitle = sender.stringValue.capitalizedString
    let category = BudgetCategoryManager.sharedManager.changeTitleOfCategory(oldTitle, to: newTitle)
    if category != nil {
      budgetCategories[row] = category!
    }
    
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
  
  //========================================================================================
  // MARK: - NSTableViewDelegate / NSTableViewDataSource
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // numberOfRowsInTableView(tableView:) -> Int
  //----------------------------------------------------------------------------------------
  func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    return self.budgetCategories.count
  }
  
  //----------------------------------------------------------------------------------------
  // tableView(tableView:viewForTableColumn:row:) -> NSView?
  //----------------------------------------------------------------------------------------
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
      var percent: Float = 0.0
      if category.goal.floatValue != 0 {
        percent = category.actual.decimalNumberByDividingBy(category.goal).floatValue
      } else if category.goal.floatValue == 0 && category.actual.floatValue > 0 {
        percent = 100.0
      }
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
  
  //----------------------------------------------------------------------------------------
  // keyDown(theEvent:)
  //----------------------------------------------------------------------------------------
  /// If the backspace button is pressed when rows are selected, then we
  /// will delete those category objects
  override func keyDown(theEvent: NSEvent) {
    guard let key = (theEvent.charactersIgnoringModifiers as NSString?)?.characterAtIndex(0)
          where Int(key) == NSDeleteCharacter else {
            return
    }
    
    let selectedIndexes = tableView.selectedRowIndexes
    selectedIndexes.reverse().forEach { (rowIndex) in
      BudgetCategoryManager.sharedManager.removeCategory(budgetCategories[rowIndex])
      budgetCategories.removeAtIndex(rowIndex)
    }
    
    tableView.removeRowsAtIndexes(selectedIndexes, withAnimation: NSTableViewAnimationOptions.EffectFade)
  }
}
