//
//  BudgetCategory.swift
//  Wallet
//
//  Created by Duff Neubauer on 12/13/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Foundation

// MARK: - BudgetCategoryStore

struct BudgetCategoryStore {
  static let sharedInstance = BudgetCategoryStore()
  
  var categories = [BudgetCategory]()
}

// MARK: - BudgetCategory

struct BudgetCategory {
  var title:  String
  var goal:   NSDecimalNumber
  var actual: NSDecimalNumber
  var net:    NSDecimalNumber {
    return goal.decimalNumberBySubtracting(actual)
  }
  
  static func defaultCategory() -> BudgetCategory {
    return BudgetCategory(title: "category", goal: NSDecimalNumber(double: 0.0))
  }
  
  init(title: String, goal: NSDecimalNumber) {
    self.title  = title
    self.goal   = goal
    self.actual = NSDecimalNumber(double: 0.0)
  }
}