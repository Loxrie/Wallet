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
  func displayViewController(_ viewController: NSViewController)
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
  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
    guard let sourceItem = item as? SourceListItem else { return self.sourceItems.count }
    
    return sourceItem.children.count
  }
  
  //----------------------------------------------------------------------------------------
  // outlineView(outlineView:isItemExpandable:) -> Bool
  //----------------------------------------------------------------------------------------
  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
    guard let sourceItem = item as? SourceListItem else { return false }
    
    return sourceItem.hasChildren()
  }
  
  //----------------------------------------------------------------------------------------
  // outlineView(outlineView:child:ofItem:) -> AnyObject
  //----------------------------------------------------------------------------------------
  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
    guard let sourceItem = item as? SourceListItem else { return self.sourceItems[index] }
    
    return sourceItem.children[index]
  }
  
  //----------------------------------------------------------------------------------------
  // outlineView(outlineView:objectValueForTableColumn:byItem:) -> AnyObject?
  //----------------------------------------------------------------------------------------
  func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
    guard let sourceItem = item as? SourceListItem else { return nil }
    
    return sourceItem
  }
  
  //----------------------------------------------------------------------------------------
  // outlineView(outlineView:shouldEditTableColumn:item:) -> Bool
  //----------------------------------------------------------------------------------------
  func outlineView(_ outlineView: NSOutlineView, shouldEditTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> Bool {
    return false
  }
  
  //----------------------------------------------------------------------------------------
  // outlineView(outlineView:isGroupItem:) -> Bool
  //----------------------------------------------------------------------------------------
  func outlineView(_ outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
    guard let sourceItem = item as? SourceListItem else { return false }
    
    return sourceItem.isGroupItem
  }
  
  //----------------------------------------------------------------------------------------
  // outlineView(outlineView:shouldSelectItem:) -> Bool
  //----------------------------------------------------------------------------------------
  func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
    guard let sourceItem = item as? SourceListItem else { return false }
    
    return sourceItem.isSelectable
  }
  
  //----------------------------------------------------------------------------------------
  // outlineView(outlineView:viewForTableColumn:item:) -> NSView?
  //----------------------------------------------------------------------------------------
  func outlineView(_ outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
    guard let sourceItem = item as? SourceListItem else { return nil }
    
    if sourceItem.isGroupItem {
      let cell = outlineView.make(withIdentifier: "HeaderCell", owner: self) as? HeaderCellView
      cell?.titleLabel.stringValue    = sourceItem.title.uppercased()
      cell?.subtitleLabel.stringValue = sourceItem.subtitle
      return cell
    } else {
      let cell = outlineView.make(withIdentifier: "DataCell", owner: self) as? DataCellView
      cell?.titleLabel.stringValue    = sourceItem.title
      cell?.subtitleLabel.stringValue = sourceItem.subtitle
      return cell
    }
  }
  
  //----------------------------------------------------------------------------------------
  // outlineViewSelectionDidChange(notification:)
  //----------------------------------------------------------------------------------------
  func outlineViewSelectionDidChange(_ notification: Notification) {
    let index = self.outlineView.selectedRow
    guard let item  = self.outlineView.item(atRow: index) as? SourceListItem else { return }
    
    if let content = item.viewController {
      self.delegate?.displayViewController(content)
    }
  }
}
