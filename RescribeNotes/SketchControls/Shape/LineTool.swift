//
//  LineTool.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 19/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

class LineTool: SketchTool {
  var lineWidth: CGFloat
  var lineColor: UIColor
  var lineAlpha: CGFloat
  var firstPoint: CGPoint
  var lastPoint: CGPoint

  init() {
    lineWidth = 1.0
    lineAlpha = 1.0
    lineColor = .blue
    firstPoint = CGPoint(x: 0, y: 0)
    lastPoint = CGPoint(x: 0, y: 0)
  }

  internal func setInitialPoint(_ firstPoint: CGPoint) {
    self.firstPoint = firstPoint
  }

  internal func moveFromPoint(_ startPoint: CGPoint, toPoint endPoint: CGPoint) {
    self.lastPoint = endPoint
  }

  internal func draw() {
    let context: CGContext = UIGraphicsGetCurrentContext()!
    context.setStrokeColor(lineColor.cgColor)
    context.setLineCap(.square)
    context.setLineWidth(lineWidth)
    context.setAlpha(lineAlpha)
    context.move(to: CGPoint(x: firstPoint.x, y: firstPoint.y))
    context.addLine(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
    context.strokePath()
  }

  func angleWithFirstPoint(first: CGPoint, second: CGPoint) -> Float {
    let dx: CGFloat = second.x - first.x
    let dy: CGFloat = second.y - first.y
    let angle = atan2f(Float(dy), Float(dx))

    return angle
  }

  func pointWithAngle(angle: CGFloat, distance: CGFloat) -> CGPoint {
    let x = Float(distance) * cosf(Float(angle))
    let y = Float(distance) * sinf(Float(angle))

    return CGPoint(x: CGFloat(x), y: CGFloat(y))
  }
}
