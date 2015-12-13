//
//  SourceListViewController.swift
//  Wallet
//
//  Created by Duff Neubauer on 12/13/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Cocoa

//========================================================================================
// MARK: - SourceListViewControllerDelegate
//========================================================================================
protocol SourceListViewControllerDelegate {
  func displayViewController(viewController: NSViewController)
}


//========================================================================================
// MARK: - SourceListViewController
//========================================================================================
class SourceListViewController: NSViewController, NSOutlineViewDataSource {
  
  @IBOutlet weak var outlineView: NSOutlineView!
  var sourceItems = [SourceListItem]()
  var delegate: SourceListViewControllerDelegate?
  
  //----------------------------------------------------------------------------------------
  // refresh
  //----------------------------------------------------------------------------------------
  func refresh() {
    self.outlineView.reloadData()
    self.outlineView.expandItem(nil, expandChildren: true)
  }
  
  // MARK: - NSOutlineViewDataSource
  
  //----------------------------------------------------------------------------------------
  // outlineView(outlineView:numberOfChildrenOfItem:) -> Int
  //----------------------------------------------------------------------------------------
  func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
    guard let sourceItem = item as? SourceListItem else { return self.sourceItems.count }
    
    return sourceItem.children.count
  }
  
  //----------------------------------------------------------------------------------------
  // outlineView(outlineView:isItemExpandable:) -> Bool
  //----------------------------------------------------------------------------------------
  func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
    guard let sourceItem = item as? SourceListItem else { return false }
    
    return sourceItem.hasChildren()
  }
  
  //----------------------------------------------------------------------------------------
  // outlineView(outlineView:child:ofItem:) -> AnyObject
  //----------------------------------------------------------------------------------------
  func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
    guard let sourceItem = item as? SourceListItem else { return self.sourceItems[index] }
    
    return sourceItem.children[index]
  }
  
  //----------------------------------------------------------------------------------------
  // outlineView(outlineView:objectValueForTableColumn:byItem:) -> AnyObject?
  //----------------------------------------------------------------------------------------
  func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
    guard let sourceItem = item as? SourceListItem else { return nil }
    
    return sourceItem
  }
  
  //----------------------------------------------------------------------------------------
  // outlineView(outlineView:shouldEditTableColumn:item:) -> Bool
  //----------------------------------------------------------------------------------------
  func outlineView(outlineView: NSOutlineView, shouldEditTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> Bool {
    return false
  }
  
  //----------------------------------------------------------------------------------------
  // outlineView(outlineView:isGroupItem:) -> Bool
  //----------------------------------------------------------------------------------------
  func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
    guard let sourceItem = item as? SourceListItem else { return false }
    
    return sourceItem.isGroupItem
  }
  
  //----------------------------------------------------------------------------------------
  // outlineView(outlineView:shouldSelectItem:) -> Bool
  //----------------------------------------------------------------------------------------
  func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
    guard let sourceItem = item as? SourceListItem else { return false }
    
    return !sourceItem.isGroupItem
  }
  
  //----------------------------------------------------------------------------------------
  // outlineView(outlineView:viewForTableColumn:item:) -> NSView?
  //----------------------------------------------------------------------------------------
  func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
    guard let sourceItem = item as? SourceListItem else { return nil }
    var cell: NSTableCellView? = nil
    if sourceItem.isGroupItem {
      cell = outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as? NSTableCellView
    } else {
      cell = outlineView.makeViewWithIdentifier("DataCell", owner: self) as? NSTableCellView
    }
    
    cell?.textField?.stringValue = sourceItem.title
    
    return cell
  }
  
  //----------------------------------------------------------------------------------------
  // outlineViewSelectionDidChange(notification:)
  //----------------------------------------------------------------------------------------
  func outlineViewSelectionDidChange(notification: NSNotification) {
    let index = self.outlineView.selectedRow
    guard let item  = self.outlineView.itemAtRow(index) as? SourceListItem else { return }
    
    if let content = item.viewController {
      self.delegate?.displayViewController(content)
    }
  }
}
