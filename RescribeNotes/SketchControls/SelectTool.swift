//
//  SelectTool.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 14/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

class SelectTool: SketchTool {
  var lineWidth: CGFloat
  var lineColor: UIColor
  var lineAlpha: CGFloat
  var imageTool: ImageViewTool?
  var shouldDraw: Bool = false

  var touchPoint: CGPoint = CGPoint.zero

  init() {
    self.lineAlpha = 1
    self.lineWidth = 1
    self.lineColor = UIColor.white
  }

  func setInitialPoint(_ firstPoint: CGPoint) {}

  func moveFromPoint(_ startPoint: CGPoint, toPoint endPoint: CGPoint) {
    self.touchPoint = endPoint
  }

  func maskImageWithColor(color: UIColor) {

    self.imageTool?.image = self.imageTool?.image?.maskWithColor(color: color)
  }

  func draw() {
    print("Tool draw called")

    if shouldDraw {

      print("Tool drawn")

      let context: CGContext = UIGraphicsGetCurrentContext()!
      context.setShadow(offset: CGSize(width: 0, height: 0), blur: 0, color: nil)

      if let image = self.imageTool?.image {

        let imageWidth = self.imageTool!.actualWidth
        let imageHeight = self.imageTool!.actualHeight

        let originX = self.imageTool!.touchPoint.x - (imageWidth / 2)
        let originY = self.imageTool!.touchPoint.y - (imageHeight / 2)

        // Move the origin to center point of the image according to parent frame.
        // Suppose origin of the frame is 100 x 100 and width and height is 300 x 300
        // then values should be (100 + (300 / 2) x 100 + (300 / 2))
//        context.translateBy(x: self.imageTool!.touchPoint.x, y: self.imageTool!.touchPoint.y)

        // rotate around this point
//        context.rotate(by: (self.imageTool!.degressRotated * CGFloat.pi) / 180)

        // Below line stops mirror image to be drawn
//        context.scaleBy(x: 1, y: -1)

        // Now in drawing as we are at center position of the image we need to move back to origin position of the object
//        context.draw(image.cgImage!, in: CGRect(x: -(imageWidth / 2), y: -(imageHeight / 2), width: imageWidth, height: imageHeight))

        // Below is direct Image draw
        image.draw(in: CGRect(x: originX, y: originY, width: imageWidth, height: imageHeight))

        self.shouldDraw = false
        print("Now image is written")
      }
    } else {

      self.imageTool?.center.x = touchPoint.x
      self.imageTool?.center.y = touchPoint.y
    }
  }
}
