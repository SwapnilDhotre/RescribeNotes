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

  init() {
    self.lineAlpha = 1
    self.lineWidth = 1
    self.lineColor = UIColor.white
  }

  func setInitialPoint(_ firstPoint: CGPoint) {}

  func moveFromPoint(_ startPoint: CGPoint, toPoint endPoint: CGPoint) {}

  func draw() {
    print("Tool drawn")

    if shouldDraw {
      let context: CGContext = UIGraphicsGetCurrentContext()!
      context.setShadow(offset: CGSize(width: 0, height: 0), blur: 0, color: nil)

      if let image = self.imageTool?.image {
        let imageX = self.imageTool!.touchPoint.x  - (self.imageTool!.actualWidth / 2.0)
        let imageY = self.imageTool!.touchPoint.y - (self.imageTool!.actualHeight / 2.0)
        let imageWidth = self.imageTool!.actualWidth
        let imageHeight = self.imageTool!.actualHeight

        image.draw(in: CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight))
        print("Now image is written")
      }
    }
  }
}
