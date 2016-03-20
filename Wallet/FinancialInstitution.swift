//
//  FinancialInstitution.swift
//  Wallet
//
//  Created by Duff Neubauer on 12/22/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Foundation

//================================================
// MARK: FinancialInstitution
//================================================
enum FinancialInstitution: String {
  case WellsFargo = "WFB"
  case CapitalOne = "C1"
  
  func description() -> String {
    switch (self) {
    case .WellsFargo: return "Wells Fargo"
    case .CapitalOne: return "Capital One"
    }
  }
}