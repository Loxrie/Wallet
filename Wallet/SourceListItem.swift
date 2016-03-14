//
//  SourceListItem.swift
//  Wallet
//
//  Created by Duff Neubauer on 11/24/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Cocoa

class SourceListItem: NSObject {
  let title:          String
  let isGroupItem:    Bool
  
  var viewController: NSViewController?
  var children:       [SourceListItem]
  
  init(title: String, asGroupItem: Bool) {
    self.title          = title
    self.isGroupItem    = asGroupItem
    self.viewController = nil
    self.children       = []
  }
  
  func hasChildren() -> Bool {
    return self.children.count > 0
  }
}
