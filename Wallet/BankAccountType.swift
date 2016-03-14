//
//  BankAccountType.swift
//  Wallet
//
//  Created by Duff Neubauer on 12/22/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Foundation

//================================================
// MARK: BankAccountType
//================================================
enum BankAccountType: String {
  case Checking = "CHECKING"
  
  func description() -> String {
    switch(self) {
    case .Checking: return "Checking"
    }
  }
}