//
//  BudgetTableCellViews.swift
//  Wallet
//
//  Created by Duff Neubauer on 12/13/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Cocoa

class ActualBudgetTableCellView: NSTableCellView {
  @IBOutlet weak var actualBudgetView: ActualBudgetView!
  
  private var percentFull: CGFloat = 0.0

  //----------------------------------------------------------------------------------------
  // init
  //----------------------------------------------------------------------------------------
  required init?(coder: NSCoder) {
    super.init(coder: coder)

    NotificationCenter.default().addObserver(self, selector: "windowDidResize:", name: NSNotification.Name.NSWindowDidResize, object: nil)
  }

  //----------------------------------------------------------------------------------------
  // windowDidResize:
  //----------------------------------------------------------------------------------------
  func windowDidResize(_ sender: Notification) {
    actualBudgetView.updatePercent(percentFull)
    actualBudgetView.drawTopView()
  }
  
  //----------------------------------------------------------------------------------------
  // updatePercentFull:
  //----------------------------------------------------------------------------------------
  func updatePercentFull(_ percent: CGFloat, withAmount: NSDecimalNumber) {
    percentFull = percent
    actualBudgetView.updatePercent(percent, withAmount: withAmount)
    actualBudgetView.animateTopView()
  }
}

class ActualBudgetView: NSView {
  
  private let grayColor   = NSColor(white: 0.60, alpha: 1.0).cgColor
  private let redColor    = NSColor(red: 1.00, green: 0.38, blue: 0.35, alpha: 1.0).cgColor
  private let blueColor   = NSColor(red: 0.60, green: 0.75, blue: 0.92, alpha: 1.0).cgColor
  private let greenColor  = NSColor(red: 0.16, green: 0.82, blue: 0.26, alpha: 1.0).cgColor
  private let yellowColor = NSColor(red: 1.00, green: 0.76, blue: 0.18, alpha: 1.0).cgColor
  private var percent     = CGFloat(0)
  
  @IBOutlet var view: NSView!
  @IBOutlet weak var topView: NSView!
  @IBOutlet weak var amountLabel: NSTextField!
  @IBOutlet weak var widthConstraint: NSLayoutConstraint!
  
  //----------------------------------------------------------------------------------------
  // init
  //----------------------------------------------------------------------------------------
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    Bundle.main().loadNibNamed("ActualBudgetView", owner: self, topLevelObjects: nil)
    self.addSubview(view)
    
    // Set contraints
    view.translatesAutoresizingMaskIntoConstraints = false
    let views = ["view": view]
    
    let horzContraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views)
    let vertContraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: views)
    
    NSLayoutConstraint.activate(horzContraint)
    NSLayoutConstraint.activate(vertContraint)
  }
  
  //----------------------------------------------------------------------------------------
  // awakeFromNib
  //----------------------------------------------------------------------------------------
  override func awakeFromNib() {
    super.awakeFromNib()
    
    // background color
    let layer = CALayer()
    layer.backgroundColor = NSColor(white: 0.9, alpha: 1.0).cgColor
    layer.cornerRadius = self.frame.size.height * 0.14
    view.wantsLayer = true
    view.layer = layer
    
    // foreground layer
    let topLayer = CALayer()
    topLayer.backgroundColor = topView.frame.size.width >= view.frame.size.width ? redColor : grayColor
    topLayer.cornerRadius = self.frame.size.height * 0.14
    topView.wantsLayer = true
    topView.layer = topLayer
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    self.drawTopView()
  }

  func drawTopView() {
    // change width
    let width = self.percent * self.frame.size.width
    self.widthConstraint.constant = width
    
    // change color
    switch self.percent {
    case let x where x >= 1.0:
      self.topView.layer?.backgroundColor = self.redColor
    case let x where x >= 0.75:
      self.topView.layer?.backgroundColor = self.yellowColor
    case let x where x >= 0.0:
      self.topView.layer?.backgroundColor = self.greenColor
    default:
      self.topView.layer?.backgroundColor = self.grayColor
    }
  }
  
  func animateTopView() {
    let width = self.percent * self.frame.size.width
    
    NSAnimationContext.runAnimationGroup({ (context) in
      context.duration = 0.2
      
      // change width
      self.widthConstraint.animator().constant = width
      
      // change color
      switch self.percent {
      case let x where x >= 1.0:
        self.topView.animator().layer?.backgroundColor = self.redColor
      case let x where x >= 0.75:
        self.topView.animator().layer?.backgroundColor = self.yellowColor
      case let x where x >= 0.0:
        self.topView.animator().layer?.backgroundColor = self.greenColor
      default:
        self.topView.animator().layer?.backgroundColor = self.grayColor
      }
      
      }, completionHandler: nil)
  }

  //----------------------------------------------------------------------------------------
  // updatePercent:
  //----------------------------------------------------------------------------------------
  func updatePercent(_ percent: CGFloat, withAmount: NSDecimalNumber? = nil) {
    self.percent = percent >= 1.0 ? 1.0 : percent
    
    if let amount = withAmount {
      let numberFormatter           = NumberFormatter()
      let currencyCodeKey           = AppDelegate.UserDefaultKeys.CurrencyCode
      numberFormatter.currencyCode  = UserDefaults.standard().string(forKey: currencyCodeKey)!
      numberFormatter.numberStyle   = .currencyAccounting
      amountLabel.stringValue       = numberFormatter.string(from: amount)!
    }
  }
}
