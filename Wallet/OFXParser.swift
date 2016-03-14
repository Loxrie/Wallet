//
//  OFXParser.swift
//  Wallet
//
//  Created by Duff Neubauer on 10/18/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Foundation

//========================================================================================
// MARK: - OFXTags
//========================================================================================
private struct OFXTags {
  
  struct BankInfo {
    static let Base           = "FI"
    static let BankOrg        = "ORG"
    static let BankOrgID      = "FID"
  }
  
  struct StatementResponse {
    static let Base           = "STMTRS"
    static let Currency       = "CURDEF"
  }
  
  struct AccountInfo {
    static let Base           = "BANKACCTFROM"
    static let RoutingNumber  = "BANKID"
    static let AccountNumber  = "ACCTID"
    static let AccountType    = "ACCTTYPE"
  }
  
  struct BankTransactions {
    static let Base           = "BANKTRANLIST"
    static let Transaction    = "STMTTRN"
    static let Type           = "TRNTYPE"
    static let DatePosted     = "DTPOSTED"
    static let Amount         = "TRNAMT"
    static let UniqueID       = "FITID"
    static let Name           = "NAME"
    static let Memo           = "MEMO"
    static let CheckNumber    = "CHECKNUM"
  }
  
  struct LedgerBalance {
    static let Base           = "LEDGERBAL"
    static let Balance        = "BALAMT"
    static let Date           = "DTASOF"
  }
  
  struct AvailableBalance {
    static let Base           = "AVAILBAL"
    static let Balance        = "BALAMT"
    static let Date           = "DTASOF"
  }
}


//========================================================================================
// MARK: - OFXParser
//========================================================================================
struct OFXParser {
  let contents: String
  
  enum BankAccountInfo {
    case Org, ID, Currency, RoutingNumber, AccountNumber, AccountType, LedgerBalance, AvailableBalance, DateOfBalance
  }
  
  enum TransactionInfo {
    case TransactionType, DatePosted, Amount, UniqueID, CheckNum, Name, Memo
  }
  
  //========================================================================================
  // MARK: - Lifecycle
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // init?(ofxFile:)
  //----------------------------------------------------------------------------------------
  /// - parameter ofxFile: A NSURL to a file on disk
  init?(ofxFile: NSURL) {
    // Check file exists
    if !NSFileManager.defaultManager().fileExistsAtPath(ofxFile.path!) {
      return nil
    }
    
    do {
      self.contents = try String(contentsOfURL: ofxFile, encoding: NSASCIIStringEncoding)
    } catch {
      return nil
    }
  }
  
  //========================================================================================
  // MARK: - Public Methods
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // bankInformation() -> [BankAccountInfo: String]?
  //----------------------------------------------------------------------------------------
  func bankInformation() -> [BankAccountInfo: String]? {
    guard let bankInfo      = self.blocksWithTag(OFXTags.BankInfo.Base, inString: self.contents)?.first,
          let bankOrg       = self.valueOfTag(OFXTags.BankInfo.BankOrg, inString: bankInfo),
          let bankID        = self.valueOfTag(OFXTags.BankInfo.BankOrgID, inString: bankInfo),
      
          let statement     = self.blocksWithTag(OFXTags.StatementResponse.Base, inString: self.contents)?.first,
          let currency      = self.valueOfTag(OFXTags.StatementResponse.Currency, inString: statement),
      
          let accountInfo   = self.blocksWithTag(OFXTags.AccountInfo.Base, inString: statement)?.first,
          let routingNum    = self.valueOfTag(OFXTags.AccountInfo.RoutingNumber, inString: accountInfo),
          let accountNum    = self.valueOfTag(OFXTags.AccountInfo.AccountNumber, inString: accountInfo),
          let accountType   = self.valueOfTag(OFXTags.AccountInfo.AccountType, inString: accountInfo) else { return nil }
    
          let balanceTuple  = self.accountBalance()
          let ledgerBalance = balanceTuple.0.0
          let availBalance  = balanceTuple.0.1
          let dateOfBal     = balanceTuple.1
    
    return [
      BankAccountInfo.Org:              bankOrg,
      BankAccountInfo.ID:               bankID,
      BankAccountInfo.Currency:         currency,
      BankAccountInfo.RoutingNumber:    routingNum,
      BankAccountInfo.AccountNumber:    accountNum,
      BankAccountInfo.AccountType:      accountType,
      BankAccountInfo.LedgerBalance:    ledgerBalance,
      BankAccountInfo.AvailableBalance: availBalance,
      BankAccountInfo.DateOfBalance:    dateOfBal
    ]
  }
  
  //----------------------------------------------------------------------------------------
  // bankTransactions() -> [[TransactionInfo: String]]
  //----------------------------------------------------------------------------------------
  func bankTransactions() -> [[TransactionInfo: String]] {
    guard let transactionsList  = self.blocksWithTag(OFXTags.BankTransactions.Base, inString: self.contents)?.first,
          let transactions      = self.blocksWithTag(OFXTags.BankTransactions.Transaction, inString: transactionsList) else { return [] }
    
    return transactions.map {
      var transaction: [TransactionInfo: String] = [:]
      
      if let type = self.valueOfTag(OFXTags.BankTransactions.Type, inString: $0) {
        transaction[TransactionInfo.TransactionType] = type
      }
      
      if let date = self.valueOfTag(OFXTags.BankTransactions.DatePosted, inString: $0) {
        transaction[TransactionInfo.DatePosted] = date
      }
      
      if let amount = self.valueOfTag(OFXTags.BankTransactions.Amount, inString: $0) {
        transaction[TransactionInfo.Amount] = amount
      }
      
      if let ID = self.valueOfTag(OFXTags.BankTransactions.UniqueID, inString: $0) {
        transaction[TransactionInfo.UniqueID] = ID
      }
      
      if let name = self.valueOfTag(OFXTags.BankTransactions.Name, inString: $0) {
        transaction[TransactionInfo.Name] = name
      }
      
      if let memo = self.valueOfTag(OFXTags.BankTransactions.Memo, inString: $0) {
        transaction[TransactionInfo.Memo] = memo
      }
      
      if let checkNum = self.valueOfTag(OFXTags.BankTransactions.CheckNumber, inString: $0) {
        transaction[TransactionInfo.CheckNum] = checkNum
      }
      
      return transaction
    }
    
  }
  
  //----------------------------------------------------------------------------------------
  // accountBalance() -> (String, String)
  //----------------------------------------------------------------------------------------
  func accountBalance() -> ((String, String), String) {
    var balance = (("", ""), "")

    guard let legderBalanceBlock  = self.blocksWithTag(OFXTags.LedgerBalance.Base, inString: self.contents)?.first,
          let availBalanceBlock   = self.blocksWithTag(OFXTags.AvailableBalance.Base, inString: self.contents)?.first else { return balance }

    if let ledgerBalance = self.valueOfTag(OFXTags.LedgerBalance.Balance , inString: legderBalanceBlock) {
      balance.0.0 = ledgerBalance
    }

    if let availBalance = self.valueOfTag(OFXTags.AvailableBalance.Balance , inString: availBalanceBlock) {
      balance.0.1 = availBalance
    }
    
    if let dateAsOf = self.valueOfTag(OFXTags.AvailableBalance.Date , inString: availBalanceBlock) {
      let range     = dateAsOf.rangeOfString("\\[[0-9]:[A-Z]{3}\\]", options: .RegularExpressionSearch, range: nil, locale: nil)
      let stripped  = dateAsOf.substringToIndex(range!.startIndex)
      balance.1     = stripped
    }
    
    return balance
  }
  
  //========================================================================================
  // MARK: - Private Methods
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // blocksWithTag(tag:String, inString string:String) -> [String]?
  //----------------------------------------------------------------------------------------
  private func blocksWithTag(tag:String, inString string:String) -> [String]? {
    do {
      let pattern = "<\(tag)>(.+?)</\(tag)>"
      let regex   = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.DotMatchesLineSeparators)
      
      let range   = NSMakeRange(0, string.characters.count)
      let matches = regex.matchesInString(string, options: [], range: range)
      
      return matches.map {
        return (string as NSString).substringWithRange($0.range)
      }
    } catch {
      return nil
    }
  }
  
  //----------------------------------------------------------------------------------------
  // valueOfTag(tag:String, inString string:String) -> String?
  //----------------------------------------------------------------------------------------
  func valueOfTag(tag:String, inString string:String) -> String? {
    guard let matchRange  = string.rangeOfString("<\(tag)>.+", options: .RegularExpressionSearch, range: nil, locale: nil) else { return nil }
    let tagLength         = "<\(tag)>".characters.count
    let stringRange       = matchRange.startIndex.advancedBy(tagLength) ..< matchRange.endIndex
    
    return string.substringWithRange(stringRange)
  }
  
}