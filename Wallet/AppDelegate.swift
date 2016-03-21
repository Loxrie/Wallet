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
  struct UserDefaultKeys {
    static let CurrencyCode = "CurrencyCode"
  }
  
  //----------------------------------------------------------------------------------------
  // applicationWillFinishLaunching(notification:
  //----------------------------------------------------------------------------------------
  func applicationWillFinishLaunching(notification: NSNotification) {
    let currencyCode = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultKeys.CurrencyCode)
    if currencyCode == nil {
      let currencyCode = NSLocale.currentLocale().valueForKey(NSLocaleCurrencyCode)
      NSUserDefaults.standardUserDefaults().setValue(currencyCode, forKey: UserDefaultKeys.CurrencyCode)
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }
  
  //----------------------------------------------------------------------------------------
  // applicationWillTerminate(notification:)
  //----------------------------------------------------------------------------------------
  func applicationWillTerminate(notification: NSNotification) {
    self.save(self)
  }
  
  //----------------------------------------------------------------------------------------
  // save()
  //----------------------------------------------------------------------------------------
  @IBAction func save(sender: AnyObject) {
    AccountManager.sharedManager.save()
    BudgetCategoryManager.sharedManager.save()
  }
}

