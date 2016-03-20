//
//  AccountType.swift
//  Wallet
//
//  Created by Duff Neubauer on 12/22/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Foundation

//================================================
// MARK: AccountType
//================================================
enum AccountType: String {
  case Checking = "CHECKING"
  case Credit   = "CREDIT"
  
  func description() -> String {
    switch(self) {
    case .Checking: return "Checking"
    case .Credit:   return "Credit"
    }
  }
}