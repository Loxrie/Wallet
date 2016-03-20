//
//  AppDelegate.swift
//  Wallet
//
//  Created by Duff Neubauer on 10/18/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  //----------------------------------------------------------------------------------------
  // applicationWillTerminate(notification:)
  //----------------------------------------------------------------------------------------
  func applicationWillTerminate(notification: NSNotification) {
    AccountManager.sharedManager.save()
    BudgetCategoryManager.sharedManager.save()
  }
}

