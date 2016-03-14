//
//  Bank.swift
//  Wallet
//
//  Created by Duff Neubauer on 12/22/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Foundation

//================================================
// MARK: Bank
//================================================
enum Bank: String {
  case WellsFargo = "WFB"
  
  func description() -> String {
    switch (self) {
    case .WellsFargo: return "Wells Fargo"
    }
  }
}