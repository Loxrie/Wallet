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
  func applicationWillFinishLaunching(_ notification: Notification) {
    let currencyCode = UserDefaults.standard().string(forKey: UserDefaultKeys.CurrencyCode)
    if currencyCode == nil {
      let currencyCode = Locale.current().value(forKey: Locale.Key.currencyCode.rawValue)
      UserDefaults.standard().setValue(currencyCode, forKey: UserDefaultKeys.CurrencyCode)
      UserDefaults.standard().synchronize()
    }
  }
  
  //----------------------------------------------------------------------------------------
  // applicationWillTerminate(notification:)
  //----------------------------------------------------------------------------------------
  func applicationWillTerminate(_ notification: Notification) {
    self.save(self)
  }
  
  //----------------------------------------------------------------------------------------
  // save()
  //----------------------------------------------------------------------------------------
  @IBAction func save(_ sender: AnyObject) {
    AccountManager.sharedManager.save()
    BudgetCategoryManager.sharedManager.save()
  }
}

