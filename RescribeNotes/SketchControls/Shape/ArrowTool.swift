//
//  ArrowTool.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 19/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

class ArrowTool: SketchTool {
  var lineWidth: CGFloat
  var lineColor: UIColor
  var lineAlpha: CGFloat
  var firstPoint: CGPoint
  var lastPoint: CGPoint

  init() {
    lineWidth = 1.0
    lineAlpha = 1.0
    lineColor = .black
    firstPoint = CGPoint(x: 0, y: 0)
    lastPoint = CGPoint(x: 0, y: 0)
  }

  func setInitialPoint(_ firstPoint: CGPoint) {
    self.firstPoint = firstPoint
  }

  func moveFromPoint(_ startPoint: CGPoint, toPoint endPoint: CGPoint) {
    lastPoint = endPoint
  }

  func draw() {
    let context: CGContext = UIGraphicsGetCurrentContext()!
    let capHeight = lineWidth * 4.0
    let angle = angleWithFirstPoint(first: firstPoint, second: lastPoint)
    var point1 = pointWithAngle(angle: CGFloat(angle + Float(6.0 * .pi / 8.0)), distance: capHeight)
    var point2 = pointWithAngle(angle:  CGFloat(angle - Float(6.0 * .pi / 8.0)), distance: capHeight)
    let endPointOffset = pointWithAngle(angle: CGFloat(angle), distance: lineWidth)

    context.setStrokeColor(lineColor.cgColor)
    context.setLineCap(.square)
    context.setLineWidth(lineWidth)
    context.setAlpha(lineAlpha)
    context.move(to: CGPoint(x: firstPoint.x, y: firstPoint.y))
    context.addLine(to: CGPoint(x: lastPoint.x, y: lastPoint.y))

    point1 = CGPoint(x: lastPoint.x + point1.x, y: lastPoint.y + point1.y)
    point2 = CGPoint(x: lastPoint.x + point2.x, y: lastPoint.y + point2.y)

    context.move(to: CGPoint(x: point1.x, y: point1.y))
    context.addLine(to: CGPoint(x: lastPoint.x + endPointOffset.x, y: lastPoint.y + endPointOffset.y))
    context.addLine(to: CGPoint(x: point2.x, y: point2.y))
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
