//
//  RectTool.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 19/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

class RectTool: SketchTool {
  var lineWidth: CGFloat
  var lineAlpha: CGFloat
  var lineColor: UIColor
  var firstPoint: CGPoint
  var lastPoint: CGPoint
  var isFill: Bool

  init() {
    lineWidth = 1.0
    lineAlpha = 1.0
    lineColor = .blue
    firstPoint = CGPoint(x: 0, y: 0)
    lastPoint = CGPoint(x: 0, y: 0)
    isFill = false
  }

  internal func setInitialPoint(_ firstPoint: CGPoint) {
    self.firstPoint = firstPoint
  }

  internal func moveFromPoint(_ startPoint: CGPoint, toPoint endPoint: CGPoint) {
    self.lastPoint = endPoint
  }

  internal func draw() {
    let context: CGContext = UIGraphicsGetCurrentContext()!
    let rectToFill = CGRect(x: firstPoint.x, y: firstPoint.y, width: lastPoint.x - self.firstPoint.x, height: lastPoint.y - firstPoint.y)

    context.setAlpha(lineAlpha)
    if self.isFill {
      context.setFillColor(lineColor.cgColor)
      UIGraphicsGetCurrentContext()!.fill(rectToFill)
    } else {
      context.setStrokeColor(lineColor.cgColor)
      context.setLineWidth(lineWidth)
      UIGraphicsGetCurrentContext()!.stroke(rectToFill)
    }
  }
}
