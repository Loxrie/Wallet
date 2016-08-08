//
//  CategoryTableViewCell.swift
//  Wallet
//
//  Created by Duff Neubauer on 1/3/16.
//  Copyright © 2016 Duff Neubauer. All rights reserved.
//

import Cocoa

//========================================================================================
// MARK: - CategoryTableViewCellDelegate
//========================================================================================
protocol CategoryTableViewCellDelegate {
  func categoryCell(_ cell: CategoryTableViewCell, didChangeSelectionTo newSelection: String)
}

//========================================================================================
// MARK: - CategoryTableViewCell
//========================================================================================
class CategoryTableViewCell: NSTableCellView, NSMenuDelegate {
  @IBOutlet weak var popUpButton: NSPopUpButton!
  var currentCategory:            String? = nil
  var delegate:                   CategoryTableViewCellDelegate? = nil
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
//    NSNotificationCenter.defaultCenter().addObserver(self, selector: "categorySelectionDidChange:", name: NSMenuDidChangeItemNotification, object: popUpButton)
  }
//
//  func categorySelectionDidChange(notification: NSNotification) {
//    Swift.print(notification)
//  }
  

  @IBAction func categorySelectionDidChange(_ sender: NSPopUpButton) {
    delegate?.categoryCell(self, didChangeSelectionTo: sender.title)
    currentCategory = sender.title
  }
  
  
  //========================================================================================
  // MARK: - NSMenuDelegate
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // menu(menu:willHighlightItem:)
  //----------------------------------------------------------------------------------------
  func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
//    guard let newItem = item else { return }
//    
//    let categoryIndex = menu.indexOfItem(newItem)
//    let newCategory   = BudgetCategoryManager.sharedManager.budgetCategories[categoryIndex]
//    let oldCategory   = currentCategory
//    
//    Swift.print("Change: \(oldCategory?.title) -> \(newCategory.title)")
//    delegate?.categoryCell(self, didChangeSelectionFrom: oldCategory, To: newCategory)
//    currentCategory = newCategory
  }

}
