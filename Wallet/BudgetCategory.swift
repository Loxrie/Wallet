//
//  BudgetCategory.swift
//  Wallet
//
//  Created by Duff Neubauer on 12/13/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Foundation

//========================================================================================
// MARK: - BudgetCategoryManager
//========================================================================================
struct BudgetCategoryManager {
  static var sharedManager = BudgetCategoryManager()
  
  var budgetCategories = [String: BudgetCategory]()
  
  //========================================================================================
  // MARK: - Lifecycle
  //========================================================================================
  
  init() {
    if let budgetCategories = NSKeyedUnarchiver.unarchiveObjectWithFile(self.dataPath()) as? [String: BudgetCategory] {
      self.budgetCategories = budgetCategories
    }
  }
  
  func updatedCategories() -> [BudgetCategory] {
//    // Get all transactions
//    let allAccounts = AccountManager.sharedManager.allAccounts()
//    var allTransactions: [Transaction] = []
//    allAccounts.forEach({ $0.postedTransactions().forEach({ allTransactions.append($0) }) })
//    
//    // Reset Categories
//    let categories = self.budgetCategories
//    categories.forEach({ $0.1.actual = 0 })
//    
//    // Re-calc categories
//    allTransactions.forEach { (transaction) in
//      guard let title     = transaction.category,
//            let category  = categories[title] else { return }
//      
//      category.addTransaction(transaction)
//    }
    
    return budgetCategories.map({ $0.1 })
  }
  
  func budgetTitles() -> [String] {
    return budgetCategories.map({ $0.0 })
  }
  
  mutating func removeCategory(category: BudgetCategory) {
    // Remove category
    budgetCategories.removeValueForKey(category.title)
    
    // Reset transactions whose category matches this one
    let allAccounts = AccountManager.sharedManager.allAccounts()
    var allTransactions: [Transaction] = []
    allAccounts.forEach({ $0.postedTransactions().forEach({ allTransactions.append($0) }) })
    allTransactions.forEach { (transaction) in
      guard let title = transaction.category else { return }
      if title == category.title {
        transaction.category = nil
      }
      
    }
  }
  
  //----------------------------------------------------------------------------------------
  // newCategory() -> BudgetCategory
  //----------------------------------------------------------------------------------------
  mutating func newCategory() -> BudgetCategory {
    let category = BudgetCategory(title: "Category", goal: NSDecimalNumber(double: 0.0))
    
    // Check if default category already exists
    var title       = category.title
    var index       = 0
    let categories  = budgetCategories.keys
    while categories.contains(title) {
      var base = title
      if let range = title.rangeOfString(" \(index)") {
        base = title.substringToIndex(range.startIndex)
      }
      index = index + 1
      title = "\(base) \(index)"
    }
    
    category.title = title
    budgetCategories[category.title] = category
    
    return category
  }

//  //----------------------------------------------------------------------------------------
//  // categoryByRemoving(transaction:fromCategory:)
//  //----------------------------------------------------------------------------------------
//  mutating func categoryByRemoving(transaction: Transaction, fromCategory: BudgetCategory) -> BudgetCategory {
//    Swift.print("Category: \(fromCategory)")
//    guard let category = budgetCategories[fromCategory.title] else { return fromCategory }
//    
//    budgetCategories[category.title] = category.categoryByRemoving(transaction)
//    
//    return budgetCategories[category.title]!
//  }
//  
//  //----------------------------------------------------------------------------------------
//  // categoryByAdding(transaction:toCategory:)
//  //----------------------------------------------------------------------------------------
//  mutating func categoryByAdding(transaction: Transaction, toCategory: BudgetCategory) -> BudgetCategory {
//    guard let category = budgetCategories[toCategory.title] else { return toCategory }
//    
//    budgetCategories[category.title] = category.categoryByAdding(transaction)
//    
//    return budgetCategories[category.title]!
//  }
  
  //----------------------------------------------------------------------------------------
  // categoryWithTitle(title:)
  //----------------------------------------------------------------------------------------
//  func categoryWithTitle(title: String) -> BudgetCategory? {
//    return budgetCategories[title]
//  }
  
  //================================================
  // MARK: Saving / Restoring State
  //================================================
  func dataPath() -> String {
    let fileManager = NSFileManager.defaultManager()
    
    var folder = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)[0].path!
    folder = (folder as NSString).stringByAppendingPathComponent("Wallet")
    
    if !fileManager.fileExistsAtPath(folder) {
      do {
        try fileManager.createDirectoryAtPath(folder, withIntermediateDirectories: false, attributes: nil)
      } catch {}
    }
    
    let fileName = "Categories.WBC"
    return (folder as NSString).stringByAppendingPathComponent(fileName)
  }
  
  func save() {
    print("Data Path: \(self.dataPath())")
    NSKeyedArchiver.archiveRootObject(self.budgetCategories, toFile: self.dataPath())
  }
  
  mutating func changeTitleOfCategory(fromTitle: String, to toTitle: String) -> BudgetCategory? {
    guard let category = budgetCategories[fromTitle] else { return nil }

    // Change title
    category.title = toTitle
    budgetCategories.removeValueForKey(fromTitle)
    budgetCategories[toTitle] = category
    
    // Adjust transactions
    let allAccounts = AccountManager.sharedManager.allAccounts()
    var allTransactions: [Transaction] = []
    allAccounts.forEach({ $0.postedTransactions().forEach({ allTransactions.append($0) }) })
    allTransactions.forEach { (transaction) in
      guard let title = transaction.category else { return }
      if title == fromTitle {
        transaction.category = toTitle
      }
      
    }
    
    return category
  }
}

//========================================================================================
// MARK: - BudgetCategory
//========================================================================================
class BudgetCategory: NSObject, NSCoding {
  var title:  String
  var goal:   NSDecimalNumber
  var actual: NSDecimalNumber
  var net:    NSDecimalNumber {
    return goal.decimalNumberBySubtracting(actual)
  }
  
  init(title: String, goal: NSDecimalNumber) {
    self.title  = title
    self.goal   = goal
    self.actual = NSDecimalNumber(double: 0.0)
  }
  
  //----------------------------------------------------------------------------------------
  // removeTransaction(transaction: Transaction)
  //----------------------------------------------------------------------------------------
  func removeTransaction(transaction: Transaction) {
    actual = actual.decimalNumberByAdding(transaction.amount)
  }
  
  //----------------------------------------------------------------------------------------
  // addTransaction(transaction: Transaction)
  //----------------------------------------------------------------------------------------
  func addTransaction(transaction: Transaction) {
    actual = actual.decimalNumberBySubtracting(transaction.amount)
  }
  
  //================================================
  // MARK: NSCoding
  //================================================
  required init?(coder aDecoder: NSCoder) {
    guard let title   = aDecoder.decodeObjectForKey("title") as? String,
          let goal    = aDecoder.decodeObjectForKey("goal") as? NSDecimalNumber,
          let actual  = aDecoder.decodeObjectForKey("actual") as? NSDecimalNumber else { return nil }
    
    self.title  = title
    self.goal   = goal
    self.actual = actual
    
    super.init()
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(self.title, forKey: "title")
    aCoder.encodeObject(self.goal, forKey: "goal")
    aCoder.encodeObject(self.actual, forKey: "actual")
  }
}