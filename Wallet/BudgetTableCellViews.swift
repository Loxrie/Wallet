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

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidResize:", name: NSWindowDidResizeNotification, object: nil)
  }

  //----------------------------------------------------------------------------------------
  // windowDidResize:
  //----------------------------------------------------------------------------------------
  func windowDidResize(sender: NSNotification) {
    actualBudgetView.updateWidth(percentFull)
  }
  
  //----------------------------------------------------------------------------------------
  // updatePercentFull:
  //----------------------------------------------------------------------------------------
  func updatePercentFull(value: CGFloat) {
    percentFull = value
    actualBudgetView.updateWidth(value)
  }
}

class ActualBudgetView: NSView {
  
  private let grayColor = NSColor(white: 0.60, alpha: 1.0).CGColor
  private let redColor  = NSColor(red: 1.00, green: 0.54, blue: 0.51, alpha: 1.0).CGColor
  private let blueColor = NSColor(red: 0.60, green: 0.75, blue: 0.92, alpha: 1.0).CGColor
  
  @IBOutlet var view: NSView!
  @IBOutlet weak var topView: NSView!
  @IBOutlet weak var widthConstraint: NSLayoutConstraint!
  
  //----------------------------------------------------------------------------------------
  // init
  //----------------------------------------------------------------------------------------
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    NSBundle.mainBundle().loadNibNamed("ActualBudgetView", owner: self, topLevelObjects: nil)
    self.addSubview(view)
    
    // Set contraints
    view.translatesAutoresizingMaskIntoConstraints = false
    let views = ["view": view]
    
    let horzContraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: views)
    let vertContraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: views)
    
    NSLayoutConstraint.activateConstraints(horzContraint)
    NSLayoutConstraint.activateConstraints(vertContraint)
  }
  
  //----------------------------------------------------------------------------------------
  // awakeFromNib
  //----------------------------------------------------------------------------------------
  override func awakeFromNib() {
    super.awakeFromNib()
    
    // background color
    let layer = CALayer()
    layer.backgroundColor = NSColor(white: 0.9, alpha: 1.0).CGColor
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

  //----------------------------------------------------------------------------------------
  // updateWidth:
  //----------------------------------------------------------------------------------------
  func updateWidth(percent: CGFloat) {
    let adjPercent  = percent >= 1.0 ? 1.0 : percent
    let width       = adjPercent * self.frame.size.width
    self.widthConstraint.constant = width
    
    topView.layer?.backgroundColor = adjPercent >= 1.0 ? redColor : grayColor
  }
}