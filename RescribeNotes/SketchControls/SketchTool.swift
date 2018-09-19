//
//  SketchTool.swift
//  Sketch
//
//  Created by daihase on 04/06/2018.
//  Copyright (c) 2018 daihase. All rights reserved.
//

import UIKit

protocol SketchTool {
    var lineWidth: CGFloat { get set }
    var lineColor: UIColor { get set }
    var lineAlpha: CGFloat { get set }

    func setInitialPoint(_ firstPoint: CGPoint)
    func moveFromPoint(_ startPoint: CGPoint, toPoint endPoint: CGPoint)
    func draw()
}
