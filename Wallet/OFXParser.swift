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
  
  struct FIInfo {
    static let Base           = "FI"
    static let Org            = "ORG"
    static let OrgID          = "FID"
  }
  
  struct BankStatementResponse {
    static let Base           = "STMTRS"
    static let Currency       = "CURDEF"
  }
  
  struct BankAccountInfo {
    static let Base           = "BANKACCTFROM"
    static let RoutingNumber  = "BANKID"
    static let AccountNumber  = "ACCTID"
    static let AccountType    = "ACCTTYPE"
  }
  
  struct CreditStatementResponse {
    static let Base           = "CCSTMTRS"
    static let Currency       = "CURDEF"
  }
  
  struct CreditAccountInfo {
    static let Base           = "CCACCTFROM"
    static let AccountNumber  = "ACCTID"
  }
  
  struct Transactions {
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
  
  enum FinancialInstitutionInfo {
    case Org
  }
  
  enum AccountInfo {
    case AccountNumber, AccountType, Currency, LedgerBalance, AvailableBalance, DateOfBalance
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
  // financialInstitutionInfo() -> [FinancialInstitutionInfo: String]?
  //----------------------------------------------------------------------------------------
  func financialInstitutionInfo() -> [FinancialInstitutionInfo: String]? {
    guard let FIInfo  = self.blocksWithTag(OFXTags.FIInfo.Base, inString: self.contents)?.first,
          let FIOrg   = self.valueOfTag(OFXTags.FIInfo.Org, inString: FIInfo) else { return nil }
    
    return [
      FinancialInstitutionInfo.Org: FIOrg,
    ]
  }
  
  //----------------------------------------------------------------------------------------
  // accountInfo() -> [AccountInfo: String]?
  //----------------------------------------------------------------------------------------
  func accountInfo() -> [AccountInfo: String]? {
    if self.isBankAccount() {
      return self.bankAccountInfo()
    }
    if self.isCreditAccount() {
      return self.creditAccountInfo()
    }
    
    return nil
  }
  
  //----------------------------------------------------------------------------------------
  // bankAccountInfo
  //----------------------------------------------------------------------------------------
  func bankAccountInfo() -> [AccountInfo: String]? {
    guard let statement     = self.blocksWithTag(OFXTags.BankStatementResponse.Base, inString: self.contents)?.first,
          let currency      = self.valueOfTag(OFXTags.BankStatementResponse.Currency, inString: statement),
          
          let accountInfo   = self.blocksWithTag(OFXTags.BankAccountInfo.Base, inString: statement)?.first,
          let accountNum    = self.valueOfTag(OFXTags.BankAccountInfo.AccountNumber, inString: accountInfo),
          let accountType   = self.valueOfTag(OFXTags.BankAccountInfo.AccountType, inString: accountInfo) else { return nil }
    
    let balanceTuple  = self.accountBalance()
    let ledgerBalance = balanceTuple.0.0
    let availBalance  = balanceTuple.0.1
    let dateOfBal     = balanceTuple.1
    
    return [
      AccountInfo.Currency:         currency,
      AccountInfo.AccountNumber:    accountNum,
      AccountInfo.AccountType:      accountType,
      AccountInfo.LedgerBalance:    ledgerBalance,
      AccountInfo.AvailableBalance: availBalance,
      AccountInfo.DateOfBalance:    dateOfBal
    ]
  }
  
  //----------------------------------------------------------------------------------------
  // creditAccountInfo
  //----------------------------------------------------------------------------------------
  func creditAccountInfo() -> [AccountInfo: String]? {
    guard let statement     = self.blocksWithTag(OFXTags.CreditStatementResponse.Base, inString: self.contents)?.first,
          let currency      = self.valueOfTag(OFXTags.CreditStatementResponse.Currency, inString: statement),
          
          let accountInfo   = self.blocksWithTag(OFXTags.CreditAccountInfo.Base, inString: statement)?.first,
          let accountNum    = self.valueOfTag(OFXTags.CreditAccountInfo.AccountNumber, inString: accountInfo) else { return nil }
    
    let balanceTuple  = self.accountBalance()
    let ledgerBalance = balanceTuple.0.0
    let availBalance  = balanceTuple.0.1
    let dateOfBal     = balanceTuple.1
    
    return [
      AccountInfo.Currency:         currency,
      AccountInfo.AccountNumber:    accountNum,
      AccountInfo.AccountType:      "CREDIT",
      AccountInfo.LedgerBalance:    ledgerBalance,
      AccountInfo.AvailableBalance: availBalance,
      AccountInfo.DateOfBalance:    dateOfBal
    ]
  }
  
  //----------------------------------------------------------------------------------------
  // transactions() -> [[TransactionInfo: String]]
  //----------------------------------------------------------------------------------------
  func transactions() -> [[TransactionInfo: String]] {
    guard let transactionsList  = self.blocksWithTag(OFXTags.Transactions.Base, inString: self.contents)?.first,
          let transactions      = self.blocksWithTag(OFXTags.Transactions.Transaction, inString: transactionsList) else { return [] }
    
    return transactions.map {
      var transaction: [TransactionInfo: String] = [:]
      
      if let type = self.valueOfTag(OFXTags.Transactions.Type, inString: $0) {
        transaction[TransactionInfo.TransactionType] = type
      }
      
      if let date = self.valueOfTag(OFXTags.Transactions.DatePosted, inString: $0) {
        transaction[TransactionInfo.DatePosted] = date
      }
      
      if let amount = self.valueOfTag(OFXTags.Transactions.Amount, inString: $0) {
        transaction[TransactionInfo.Amount] = amount
      }
      
      if let ID = self.valueOfTag(OFXTags.Transactions.UniqueID, inString: $0) {
        transaction[TransactionInfo.UniqueID] = ID
      }
      
      if let name = self.valueOfTag(OFXTags.Transactions.Name, inString: $0) {
        transaction[TransactionInfo.Name] = name
      }
      
      if let memo = self.valueOfTag(OFXTags.Transactions.Memo, inString: $0) {
        transaction[TransactionInfo.Memo] = memo
      }
      
      if let checkNum = self.valueOfTag(OFXTags.Transactions.CheckNumber, inString: $0) {
        transaction[TransactionInfo.CheckNum] = checkNum
      }
      
      return transaction
    }
    
  }
  
  //----------------------------------------------------------------------------------------
  // accountBalance() -> ((LedgeBal, AvailableBal), String)
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
    
    if var dateAsOf = self.valueOfTag(OFXTags.AvailableBalance.Date , inString: availBalanceBlock) {
      // Some dates have timezone info (ex. [0:GMT]) at the end of the string
      if let range = dateAsOf.rangeOfString("\\[[0-9]:[A-Z]{3}\\]", options: .RegularExpressionSearch, range: nil, locale: nil) {
        let stripped  = dateAsOf.substringToIndex(range.startIndex)
        dateAsOf      = stripped
      }
      
      // Strip the time, because we really only care about the date
      balance.1 = dateAsOf.substringToIndex(dateAsOf.startIndex.advancedBy(8))
    }
    
    return balance
  }
  
  //========================================================================================
  // MARK: - Private Methods
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // isBankAccount() -> Bool
  //----------------------------------------------------------------------------------------
  func isBankAccount() -> Bool {
    return self.blocksWithTag(OFXTags.BankStatementResponse.Base, inString: self.contents)?.first != nil
  }
  
  //----------------------------------------------------------------------------------------
  // isCreditAccount() -> Bool
  //----------------------------------------------------------------------------------------
  func isCreditAccount() -> Bool {
    return self.blocksWithTag(OFXTags.CreditStatementResponse.Base, inString: self.contents)?.first != nil
  }
  
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
    
    // If there is a closing tag, don't count it
    var endIndex = matchRange.endIndex
    if let closingTagMatch = string.rangeOfString("</\(tag)>", options: .RegularExpressionSearch, range: nil, locale: nil) {
      endIndex = closingTagMatch.startIndex
    }
    
    let tagLength   = "<\(tag)>".characters.count
    let stringRange = matchRange.startIndex.advancedBy(tagLength) ..< endIndex
    
    return string.substringWithRange(stringRange)
  }
  
}