//
//  StampTool.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 19/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

class StampTool: SketchTool {
  var lineWidth: CGFloat
  var lineColor: UIColor
  var lineAlpha: CGFloat
  var touchPoint: CGPoint
  var stampImage: UIImage?

  init() {
    lineWidth = 0
    lineColor = .blue
    lineAlpha = 0
    touchPoint = CGPoint(x: 0, y: 0)
  }

  func setInitialPoint(_ firstPoint: CGPoint) {
    touchPoint = firstPoint
  }

  func moveFromPoint(_ startPoint: CGPoint, toPoint endPoint: CGPoint) {}

  func setStampImage(image: UIImage?) {
    if let image = image {
      stampImage = image
    }
  }

  func getStamImage() -> UIImage? {
    return stampImage
  }

  func draw() {
    let context: CGContext = UIGraphicsGetCurrentContext()!
    context.setShadow(offset: CGSize(width: 0, height: 0), blur: 0, color: nil)

    if let image = self.getStamImage() {
      let imageX = touchPoint.x - (image.size.width / 2.0)
      let imageY = touchPoint.y - (image.size.height / 2.0)
      let imageWidth = image.size.width
      let imageHeight = image.size.height

      image.draw(in: CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight))
    }
  }
}
