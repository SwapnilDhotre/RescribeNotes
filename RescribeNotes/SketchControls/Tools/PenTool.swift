//
//  PenTool.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 19/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

public enum PenType {
  case normal
  case blur
  case neon
}

class PenTool: UIBezierPath, SketchTool {
  var path: CGMutablePath
  var lineColor: UIColor
  var lineAlpha: CGFloat
  var drawingPenType: PenType

  override init() {
    path = CGMutablePath.init()
    lineColor = .black
    lineAlpha = 0
    drawingPenType = .blur
    super.init()
    lineCapStyle = CGLineCap.round
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setInitialPoint(_ firstPoint: CGPoint) {}

  func moveFromPoint(_ startPoint: CGPoint, toPoint endPoint: CGPoint) {}

  func createBezierRenderingBox(_ previousPoint2: CGPoint, widhPreviousPoint previousPoint1: CGPoint, withCurrentPoint cpoint: CGPoint) -> CGRect {
    let mid1 = middlePoint(previousPoint1, previousPoint2: previousPoint2)
    let mid2 = middlePoint(cpoint, previousPoint2: previousPoint1)
    let subpath = CGMutablePath.init()

    subpath.move(to: CGPoint(x: mid1.x, y: mid1.y))
    subpath.addQuadCurve(to: CGPoint(x: mid2.x, y: mid2.y), control: CGPoint(x: previousPoint1.x, y: previousPoint1.y))
    path.addPath(subpath)

    var boundingBox: CGRect = subpath.boundingBox
    boundingBox.origin.x -= lineWidth * 2.0
    boundingBox.origin.y -= lineWidth * 2.0
    boundingBox.size.width += lineWidth * 4.0
    boundingBox.size.height += lineWidth * 4.0

    return boundingBox
  }

  private func middlePoint(_ previousPoint1: CGPoint, previousPoint2: CGPoint) -> CGPoint {
    return CGPoint(x: (previousPoint1.x + previousPoint2.x) * 0.5, y: (previousPoint1.y + previousPoint2.y) * 0.5)
  }

  func draw() {
    let context: CGContext = UIGraphicsGetCurrentContext()!
    switch drawingPenType {
    case .normal:
      context.addPath(path)
      context.setLineCap(.round)
      context.setLineWidth(lineWidth)
      context.setStrokeColor(lineColor.cgColor)
      context.setBlendMode(.normal)
      context.setAlpha(lineAlpha)
      context.strokePath()
    case .blur:
      context.addPath(path)
      context.setLineCap(.round)
      context.setLineWidth(lineWidth)
      context.setStrokeColor(lineColor.cgColor)
      context.setShadow(offset: CGSize(width: 0, height: 0), blur: lineWidth / 1.25, color: lineColor.cgColor)
      context.setAlpha(lineAlpha)
      context.strokePath()
    case .neon:
      let shadowColor = lineColor
      let transparentShadowColor = shadowColor.withAlphaComponent(lineAlpha)

      context.addPath(path)
      context.setLineCap(.round)
      context.setLineWidth(lineWidth)
      context.setStrokeColor(UIColor.white.cgColor)
      context.setShadow(offset: CGSize(width: 0, height: 0), blur: lineWidth / 1.25, color: transparentShadowColor.cgColor)
      context.setBlendMode(.screen)
      context.strokePath()
    }
  }
}
