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
    if let budgetCategories = NSKeyedUnarchiver.unarchiveObject(withFile: self.dataPath()) as? [String: BudgetCategory] {
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
  
  mutating func removeCategory(_ category: BudgetCategory) {
    // Remove category
    budgetCategories.removeValue(forKey: category.title)
    
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
    let category = BudgetCategory(title: "Category", goal: NSDecimalNumber(value: 0.0))
    
    // Check if default category already exists
    var title       = category.title
    var index       = 0
    let categories  = budgetCategories.keys
    while categories.contains(title) {
      var base = title
      if let range = title.range(of: " \(index)") {
        base = title.substring(to: range.lowerBound)
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
    let fileManager = FileManager.default()
    
    var folder = fileManager.urlsForDirectory(.applicationSupportDirectory, inDomains: .userDomainMask)[0].path!
    folder = (folder as NSString).appendingPathComponent("Wallet")
    
    if !fileManager.fileExists(atPath: folder) {
      do {
        try fileManager.createDirectory(atPath: folder, withIntermediateDirectories: false, attributes: nil)
      } catch {}
    }
    
    let fileName = "Categories.WBC"
    return (folder as NSString).appendingPathComponent(fileName)
  }
  
  func save() {
    print("Data Path: \(self.dataPath())")
    NSKeyedArchiver.archiveRootObject(self.budgetCategories, toFile: self.dataPath())
  }
  
  mutating func changeTitleOfCategory(_ fromTitle: String, to toTitle: String) -> BudgetCategory? {
    guard let category = budgetCategories[fromTitle] else { return nil }

    // Change title
    category.title = toTitle
    budgetCategories.removeValue(forKey: fromTitle)
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
    return goal.subtracting(actual)
  }
  
  init(title: String, goal: NSDecimalNumber) {
    self.title  = title
    self.goal   = goal
    self.actual = NSDecimalNumber(value: 0.0)
  }
  
  //----------------------------------------------------------------------------------------
  // removeTransaction(transaction: Transaction)
  //----------------------------------------------------------------------------------------
  func removeTransaction(_ transaction: Transaction) {
    actual = actual.adding(transaction.amount)
  }
  
  //----------------------------------------------------------------------------------------
  // addTransaction(transaction: Transaction)
  //----------------------------------------------------------------------------------------
  func addTransaction(_ transaction: Transaction) {
    actual = actual.subtracting(transaction.amount)
  }
  
  //================================================
  // MARK: NSCoding
  //================================================
  required init?(coder aDecoder: NSCoder) {
    guard let title   = aDecoder.decodeObject(forKey: "title") as? String,
          let goal    = aDecoder.decodeObject(forKey: "goal") as? NSDecimalNumber,
          let actual  = aDecoder.decodeObject(forKey: "actual") as? NSDecimalNumber else { return nil }
    
    self.title  = title
    self.goal   = goal
    self.actual = actual
    
    super.init()
  }
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(self.title, forKey: "title")
    aCoder.encode(self.goal, forKey: "goal")
    aCoder.encode(self.actual, forKey: "actual")
  }
}
