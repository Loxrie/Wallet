//
//  NewBankAccountViewController.swift
//  Wallet
//
//  Created by Duff Neubauer on 12/13/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Cocoa
import Automator

class NewBankAccountViewController: NSViewController {
  
  @IBOutlet weak var accountNameField: NSTextField!
//  @IBOutlet weak var bankStatementPopUpButton: AMPathPopUpButton!
  
  //----------------------------------------------------------------------------------------
  // createBankAccount(sender:)
  //----------------------------------------------------------------------------------------
  @IBAction func createBankAccount(sender: NSButton) {
    self.dismiss()
  }
  
  //----------------------------------------------------------------------------------------
  // cancel(sender:)
  //----------------------------------------------------------------------------------------
  @IBAction func cancel(sender: NSButton) {
    self.dismiss()
  }
  
  //----------------------------------------------------------------------------------------
  // dismiss
  //----------------------------------------------------------------------------------------
  func dismiss() {
    self.dismissController(self)
  }
}
