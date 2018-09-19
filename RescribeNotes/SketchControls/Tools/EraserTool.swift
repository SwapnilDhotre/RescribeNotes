//
//  EraserTool.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 19/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

class EraserTool: PenTool {
  override func draw() {
    let context: CGContext = UIGraphicsGetCurrentContext()!
    context.saveGState()
    context.addPath(path)
    context.setLineCap(.round)
    context.setLineWidth(lineWidth)
    context.setBlendMode(.clear)
    context.strokePath()
    context.restoreGState()
  }
}
