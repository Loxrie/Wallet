//
//  LineGraph.swift
//  Graph
//
//  Created by Duff Neubauer on 12/27/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Cocoa

//========================================================================================
// MARK: - GraphAxis
//========================================================================================
enum GraphAxis {
  case xAxis, yAxis
}

//========================================================================================
// MARK: - GraphLabelDelegate
//========================================================================================
protocol GraphLabelDelegate {
  /// Should return an array of tuples which contain the value to be labeled along
  /// with a human-readable string for the label
  func labelsForAxis(axis: GraphAxis) -> [(CGFloat, String)]
}

//========================================================================================
// MARK: - Graph
//========================================================================================
class Graph: NSView {
  
  //========================================================================================
  // MARK: - Private Properties
  //========================================================================================
  /// Used to determine how much space axes labels will take up
  private let maxLabelBlock = { (tuple: (CGFloat, String), axis: GraphAxis) -> CGFloat in
    let label         = NSTextField(frame: CGRectZero)
    label.stringValue = tuple.1
    label.sizeToFit()
    return axis == .xAxis ? label.frame.size.height : label.frame.size.width
  }
  
  private var categoryLabels: [(CGFloat, String)] = []  {
    didSet {
      categoryLabelHeight = categoryLabels.map({ maxLabelBlock($0, .xAxis) }).maxElement()!
    }
  }
  private var valueLabels: [(CGFloat, String)] = []  {
    didSet {
      valueLabelWidth = valueLabels.map({ maxLabelBlock($0, .yAxis) }).maxElement()!
    }
  }
  private let padding:              CGFloat = 10.0
  private var minCategory:          CGFloat = 0.0
  private var maxCategory:          CGFloat = 0.0
  private var minValue:             CGFloat = 0.0
  private var maxValue:             CGFloat = 0.0
  private var categoryLabelHeight:  CGFloat = 0.0
  private var valueLabelWidth:      CGFloat = 0.0
  
  //========================================================================================
  // MARK: - Public Properties
  //========================================================================================
  var categories = [CGFloat]() {
    didSet {
      if categories.count > 0 {
        minCategory     = categories.minElement()!
        maxCategory     = categories.maxElement()!
        categoryLabels  = delegate != nil ? delegate!.labelsForAxis(.xAxis) : []
      }
    }
  }
  var values = [CGFloat]() {
    didSet {
      if values.count > 0 {
        minValue    = values.minElement()!
        maxValue    = values.maxElement()!
        valueLabels = delegate != nil ? delegate!.labelsForAxis(.yAxis) : []
      }
    }
  }
  var backgroundColor               = NSColor.whiteColor()
  var borderColor                   = NSColor(white: 0.80, alpha: 1.0)
  var delegate: GraphLabelDelegate? = nil
  var graphFrame                    = CGRectZero
  
  //========================================================================================
  // MARK: - Lifecycle
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // drawRect(dirtyRect: NSRect)
  //----------------------------------------------------------------------------------------
  override func drawRect(dirtyRect: NSRect) {
    super.drawRect(dirtyRect)

    guard categories.count == values.count && self.delegate != nil else { return }
    
    self.removeAllSubViews()
    self.drawBackgroundColor(backgroundColor)
    
    graphFrame        = self.determineGraphSize(dirtyRect)
    let xLabelPixels  = categoryLabels.map({ self.convertValueToPixels($0.0, axis: .xAxis, frame: graphFrame) })
    let xLabelStrings = categoryLabels.map({ $0.1 })
    let yLabelPixels  = valueLabels.map({ self.convertValueToPixels($0.0, axis: .yAxis, frame: graphFrame) })
    let yLabelStrings = valueLabels.map({ $0.1 })
    
    // Draw border
    self.drawBorder(graphFrame)
    
    // Draw Grid
    self.drawGridLines(xLabelPixels, axis: .xAxis, frame: graphFrame)
    self.drawGridLines(yLabelPixels, axis: .yAxis, frame: graphFrame)
    
    // Label X, Y axes
    self.labelAxis(xLabelPixels, labelStrings: xLabelStrings, axis: .xAxis, frame: graphFrame)
    self.labelAxis(yLabelPixels, labelStrings: yLabelStrings, axis: .yAxis, frame: graphFrame)
    
    // Draw graph
    let categoryPixels  = categories.map({ self.convertValueToPixels($0, axis: .xAxis, frame: graphFrame) })
    let valuePixels     = values.map({ self.convertValueToPixels($0, axis: .yAxis, frame: graphFrame) })
    let points = zip(categoryPixels, valuePixels).map({ CGPoint(x: $0, y: $1) })
    self.drawDataPoints(points, frame: graphFrame)
  }
  
  //========================================================================================
  // MARK: - Public Methods
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // drawDataPoints(points:frame:)
  //----------------------------------------------------------------------------------------
  /// Must be overridden by subclass
  func drawDataPoints(points: [CGPoint], frame: CGRect) {}
  
  //========================================================================================
  // MARK: - Private Methods
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // removeAllSubViews()
  //----------------------------------------------------------------------------------------
  func removeAllSubViews() {
    for subview in self.subviews {
      subview.removeFromSuperview()
    }
  }
  
  //----------------------------------------------------------------------------------------
  // drawBackgroundColor(bgColor)
  //----------------------------------------------------------------------------------------
  private func drawBackgroundColor(bgColor: NSColor) {
    self.wantsLayer             = true
    self.layer?.backgroundColor = bgColor.CGColor
  }
  
  //----------------------------------------------------------------------------------------
  // drawBorder(frame:)
  //----------------------------------------------------------------------------------------
  private func drawBorder(frame: CGRect) {
    let path = NSBezierPath()
    borderColor.setStroke()
    path.lineWidth = 1.0
    path.appendBezierPathWithRect(frame)
    path.stroke()
  }
  
  //========================================================================================
  // MARK: - Labeling Axes
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // determineGraphSize(frame:)
  //----------------------------------------------------------------------------------------
  private func determineGraphSize(frame: CGRect) -> CGRect {
    var graphFrame = frame
    
    graphFrame.origin.y     += (categoryLabelHeight + padding)
    graphFrame.origin.x     += padding
    graphFrame.size.width   -= (valueLabelWidth     + padding) + padding
    graphFrame.size.height  -= (categoryLabelHeight + padding) + padding
    
    return graphFrame
  }
  
  //----------------------------------------------------------------------------------------
  // drawGridLines(labels:axis:frame:)
  //----------------------------------------------------------------------------------------
  private func drawGridLines(labelPixels: [CGFloat], axis: GraphAxis, frame: CGRect) {
    for pixel in labelPixels {
      let xStart  = axis == .xAxis ? pixel : frame.origin.x
      let yStart  = axis == .xAxis ? frame.origin.y : pixel
      let xEnd    = axis == .xAxis ? xStart : frame.origin.x + frame.size.width
      let yEnd    = axis == .xAxis ? frame.origin.y + frame.size.height : yStart
      let start   = CGPoint(x: xStart, y: yStart)
      let end     = CGPoint(x: xEnd, y: yEnd)
      
      // Draw
      let path = NSBezierPath()
      borderColor.setStroke()
      path.lineWidth = 1.0
      path.moveToPoint(start)
      path.lineToPoint(end)
      path.stroke()
    }
  }
  
  //----------------------------------------------------------------------------------------
  // labelAxis(labelPixels:labelStrings:axis:frame:)
  //----------------------------------------------------------------------------------------
  private func labelAxis(labelPixels: [CGFloat], labelStrings: [String], axis: GraphAxis, frame: CGRect) {
    for index in 0 ..< labelPixels.count {
      let labelString = labelStrings[index]
      let labelPoint  = labelPixels[index]
      let x           = axis == .xAxis ? labelPoint : frame.origin.x + frame.size.width + padding
      let y           = axis == .xAxis ? 0 : labelPoint
      let frame       = CGRect(x: x, y: y, width: 0, height: 0)
      let label       = NSTextField(frame: frame)
      
      label.stringValue     = labelString
      label.backgroundColor = NSColor.clearColor()
      label.bordered        = false
      label.alignment       = axis == .xAxis ? .Center : .Left
      label.sizeToFit()
      
      var adjFrame = label.frame
      if axis == .xAxis {
        adjFrame.origin.x -= adjFrame.size.width / 2.0
      } else {
        adjFrame.origin.y -= adjFrame.size.height / 2.0
      }
      label.frame = adjFrame
      
      self.addSubview(label)
    }

  }
  
  //========================================================================================
  // MARK: - Value -> Pixel
  //========================================================================================
  
  //----------------------------------------------------------------------------------------
  // convertValueToPixels(value:axis:frame:) -> CGFloat
  //----------------------------------------------------------------------------------------
  private func convertValueToPixels(value: CGFloat, axis: GraphAxis, frame: CGRect) -> CGFloat {
    let min   = self.minAxisValue(axis)
    let scale = self.scale(axis, frame: frame)
    let pixel = (value - min) * scale
    return axis == .xAxis ? frame.origin.x + pixel : frame.origin.y + pixel
  }
  
  //----------------------------------------------------------------------------------------
  // minAxisValue(axis:) -> CGFloat
  //----------------------------------------------------------------------------------------
  private func minAxisValue(axis: GraphAxis) -> CGFloat {
    return axis == .xAxis ? minCategory : minValue
  }
  
  //----------------------------------------------------------------------------------------
  // maxAxisValue(axis:) -> CGFloat
  //----------------------------------------------------------------------------------------
  private func maxAxisValue(axis: GraphAxis) -> CGFloat {
    return axis == .xAxis ? maxCategory : maxValue
  }
  
  //----------------------------------------------------------------------------------------
  // scale(axis:frame:) -> CGFloat
  //----------------------------------------------------------------------------------------
  private func scale(axis: GraphAxis, frame: CGRect) -> CGFloat {
    let axisSize    = axis == .xAxis ? frame.size.width : frame.size.height
    let min         = self.minAxisValue(axis)
    let max         = self.maxAxisValue(axis)
    let denominator = min == max ? max : max - min
    
    return axisSize / denominator
  }
}

//========================================================================================
// MARK: - LineGraph
//========================================================================================
class LineGraph: Graph {
  
  // Properties
  var lineColor = NSColor(red: 74/256.0, green: 144/256.0, blue: 226/256.0, alpha: 1.0)
  var fillColor = NSColor(red: 152/256.0, green: 190/256.0, blue: 235/256.0, alpha: 0.9)
  
  override func drawDataPoints(points: [CGPoint], frame: CGRect) {
    guard points.count > 0 else { return }
    
    let path = NSBezierPath()
    path.lineWidth = 3.0
    path.moveToPoint(points[0])
    
    fillColor.setFill()
    lineColor.setStroke()
    
    for index in 1 ..< points.count {
      let point = points[index]
      path.lineToPoint(point)
    }
    path.stroke()
    
    // Complete the shape for the fill
    if points.count >= 2 {
      let p1 = points[0]
      let p2 = points[1]
      if p1.x > p2.x {    // Right to left
        path.lineToPoint(CGPointMake(frame.origin.x, frame.origin.y))
        path.lineToPoint(CGPointMake(frame.origin.x + frame.size.width, frame.origin.y))
      } else {            // Left to right
        path.lineToPoint(CGPointMake(frame.origin.x + frame.size.width, frame.origin.y))
        path.lineToPoint(CGPointMake(frame.origin.x, frame.origin.y))
      }
      path.closePath()
      path.fill()
    }
  }
}
