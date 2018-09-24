//
//  SketchToolType.swift
//  Sketch
//
//  Created by daihase on 04/06/2018.
//  Copyright (c) 2018 daihase. All rights reserved.
//

import UIKit

public enum SketchToolType {
  case select
  case pen
  case eraser
  case line
  case textTool
  case imageTool
  case arrow
  case rectangleStroke
  case rectangleFill
  case ellipseStroke
  case ellipseFill
  case stamp
}

public enum ImageRenderingMode {
  case scale
  case original
}

@objc public protocol SketchViewDelegate: NSObjectProtocol  {
  @objc optional func drawView(_ view: SketchView, willBeginDrawUsingTool tool: Any?)
  @objc optional func drawView(_ view: SketchView, didEndDrawUsingTool tool: Any?)
  @objc optional func drawToolChanged(selectedTool: Any?)
}

public class SketchView: UIView {
  public var lineColor = UIColor.black
  public var lineWidth = CGFloat(10)
  public var lineAlpha = CGFloat(1)
  public var stampImage: UIImage?
  public var drawTool: SketchToolType = .pen {

//    willSet {
//      if self.imageViewSelected && !(self.currentTool is SelectTool) {
//        self.drawImage()
//      }
//    }
    didSet {
      sketchViewDelegate?.drawToolChanged?(selectedTool: self.drawTool)
    }
  }
  public var drawingPenType: PenType = .normal
  public var sketchViewDelegate: SketchViewDelegate?
  public var currentSelectedImage: UIImage?
  private var keyboardVisible: Bool = false
  private var currentTool: SketchTool?
  private let pathArray: NSMutableArray = NSMutableArray()
  private let bufferArray: NSMutableArray = NSMutableArray()
  private var currentPoint: CGPoint?
  private var previousPoint1: CGPoint?
  private var previousPoint2: CGPoint?
  private var image: UIImage?
  private var backgroundImage: UIImage?
  private var drawMode: ImageRenderingMode = .original

  var dragTools: [SelectTool] = []

  var imageViewSelected: Bool = false
  var lastPanPoint: CGPoint?

  public override init(frame: CGRect) {
    super.init(frame: frame)
    prepareForInitial()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    prepareForInitial()
  }

  private func prepareForInitial() {
    backgroundColor = UIColor.clear

    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: Notification.Name.UIKeyboardWillHide, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
  }

  public override func draw(_ rect: CGRect) {
    super.draw(rect)

    switch drawMode {
    case .original:
      image?.draw(at: CGPoint.zero)
      break
    case .scale:
      image?.draw(in: self.bounds)
      break
    }

    if let tool: TextFieldTool = currentTool as? TextFieldTool {
      tool.draw()
      self.addSubview(tool)
    } else if let tool: ImageViewTool = currentTool as? ImageViewTool {
      tool.draw()
      self.addSubview(tool)
    } else {
      currentTool?.draw()
    }
  }

  @objc func keyboardWillAppear() {
    self.keyboardVisible = true
  }

  @objc func keyboardWillDisappear() {
    self.keyboardVisible = false
  }

  func drawImage() {

    self.currentTool = nil
    setNeedsDisplay()

    if let selectTool = self.getSelectTool() {
      selectTool.shouldDraw = true
      self.currentTool = selectTool

      for view in self.subviews {
        if view is ImageViewTool {
          view.removeFromSuperview()
        }
      }
      finishDrawing()
      self.drawTool = .pen
    }
  }

  func getSelectTool() -> SelectTool? {

    var tool: SelectTool?
    if let selectTool = self.currentTool as? SelectTool {

      tool = selectTool
    } else if let selectTool = self.pathArray.lastObject as? SelectTool {

      tool = selectTool
    } else if let imageTool = self.pathArray.lastObject as? ImageViewTool {
      let selectTool = SelectTool()
      selectTool.imageTool = imageTool
      tool = selectTool
    }

    tool?.lineWidth = lineWidth
    tool?.lineColor = lineColor
    tool?.lineAlpha = lineAlpha

    return tool
  }

  private func updateCacheImage(_ isUpdate: Bool) {
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)

    if isUpdate {

      image = nil
      switch drawMode {
      case .original:
        if let backgroundImage = backgroundImage  {
          (backgroundImage.copy() as! UIImage).draw(at: CGPoint.zero)
        }
        break
      case .scale:
        (backgroundImage?.copy() as! UIImage).draw(in: self.bounds)
        break
      }

      for (index, obj) in pathArray.enumerated() {
        if let tool = obj as? SketchTool {
          if let tool: TextFieldTool = tool as? TextFieldTool {
            tool.draw()
            self.addSubview(tool)
          } else if let tool: ImageViewTool = tool as? ImageViewTool {
            if pathArray.count > index + 1 {
              if let _: SelectTool = pathArray[index + 1] as? SelectTool {
                // Select tool is present
                print("Select tool is present")
              } else {
                tool.draw()
                self.imageViewSelected = true
                self.addSubview(tool)
                self.drawTool = .select
              }
            } else {
              tool.draw()
              self.imageViewSelected = true
              self.addSubview(tool)
              self.drawTool = .select
            }

          } else if let tool: SelectTool = tool as? SelectTool {

            tool.shouldDraw = true
            tool.draw()
            self.setNeedsLayout()
          } else {
            tool.draw()
          }
        }
      }
    } else {
      image?.draw(at: .zero)

      if let tool: TextFieldTool = currentTool as? TextFieldTool {
        tool.draw()
        self.addSubview(tool)
      } else if let tool: ImageViewTool = currentTool as? ImageViewTool {
        tool.draw()
        self.imageViewSelected = true
        self.addSubview(tool)
      } else if let tool: SelectTool = currentTool as? SelectTool {
        tool.shouldDraw = true
        tool.draw()
      } else {
        currentTool?.draw()
      }
    }

    image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    self.setNeedsLayout()
  }

  private func toolWithCurrentSettings() -> SketchTool? {
    switch drawTool {
    case .pen:
      return PenTool()
    case .eraser:
      return EraserTool()
    case .stamp:
      return StampTool()
    case .line:
      return LineTool()
    case .arrow:
      return ArrowTool()
    case .rectangleStroke:
      let rectTool = RectTool()
      rectTool.isFill = false
      return rectTool
    case .rectangleFill:
      let rectTool = RectTool()
      rectTool.isFill = true
      return rectTool
    case .ellipseStroke:
      let ellipseTool = EllipseTool()
      ellipseTool.isFill = false
      return ellipseTool
    case .ellipseFill:
      let ellipseTool = EllipseTool()
      ellipseTool.isFill = true
      return ellipseTool
    case .textTool:
      let textTool = TextFieldTool()
      return textTool
    case .imageTool:
      let imageTool = ImageViewTool()
      return imageTool
    case .select:

      return self.getSelectTool()
    }
  }

  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }

    sketchViewDelegate?.drawView?(self, willBeginDrawUsingTool: nil)
    
    previousPoint1 = touch.previousLocation(in: self)
    currentPoint = touch.location(in: self)
    if self.keyboardVisible {
      self.endEditing(true)
      return
    } else {
      currentTool = toolWithCurrentSettings()
    }
    currentTool?.lineWidth = lineWidth
    currentTool?.lineColor = lineColor
    currentTool?.lineAlpha = lineAlpha

    switch currentTool! {
    case is SelectTool:
      // Do nothing here
      print("Select Tool selected")
      guard (currentTool as? SelectTool) != nil else { return }

    case is PenTool:
      guard let penTool = currentTool as? PenTool else { return }
      pathArray.add(penTool)
      penTool.drawingPenType = drawingPenType
      penTool.setInitialPoint(currentPoint!)
    case is StampTool:
      guard let stampTool = currentTool as? StampTool else { return }
      pathArray.add(stampTool)
      stampTool.setStampImage(image: stampImage)
      stampTool.setInitialPoint(currentPoint!)
    case is TextFieldTool:
      guard let textFieldTool = currentTool as? TextFieldTool else { return }
      pathArray.add(textFieldTool)
      textFieldTool.setInitialPoint(currentPoint!)
    case is ImageViewTool:
      guard let imageViewTool = currentTool as? ImageViewTool else { return }
      imageViewTool.image = self.currentSelectedImage
      imageViewTool.setInitialPoint(currentPoint!)
      pathArray.add(imageViewTool)

      if let selectTool = self.getSelectTool() {
        selectTool.shouldDraw = false
        pathArray.add(selectTool)
        self.drawTool = .select
      }
    default:
      guard let currentTool = currentTool else { return }
      pathArray.add(currentTool)
      currentTool.setInitialPoint(currentPoint!)
    }
  }

  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }

    previousPoint2 = previousPoint1
    previousPoint1 = touch.previousLocation(in: self)
    currentPoint = touch.location(in: self)

    if let penTool = currentTool as? PenTool {
      let renderingBox = penTool.createBezierRenderingBox(previousPoint2!, widhPreviousPoint: previousPoint1!, withCurrentPoint: currentPoint!)

      setNeedsDisplay(renderingBox)
    } else {
      currentTool?.moveFromPoint(previousPoint1!, toPoint: currentPoint!)
      setNeedsDisplay()
    }
  }

  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    touchesMoved(touches, with: event)
    finishDrawing()
  }

  fileprivate func finishDrawing() {
    updateCacheImage(false)
    bufferArray.removeAllObjects()
    sketchViewDelegate?.drawView?(self, didEndDrawUsingTool: currentTool! as Any)
    currentTool = nil
  }

  private func resetTool() {
    currentTool = nil
  }

  public func clear() {
    self.drawTool = .pen
    resetTool()
    bufferArray.removeAllObjects()
    pathArray.removeAllObjects()
    updateCacheImage(true)

    for view in self.subviews {
      if view is ImageViewTool {
        view.removeFromSuperview()
      }
    }

    setNeedsDisplay()
  }

  func pinch() {
    resetTool()
    guard let tool = pathArray.lastObject as? SketchTool else { return }
    bufferArray.add(tool)
    pathArray.removeLastObject()
    updateCacheImage(true)

    setNeedsDisplay()
  }

  public func loadImage(image: UIImage) {
    self.image = image
    backgroundImage =  image.copy() as? UIImage
    bufferArray.removeAllObjects()
    pathArray.removeAllObjects()
    updateCacheImage(true)

    setNeedsDisplay()
  }

  public func undo() {
    if canUndo() {

      if self.imageViewSelected {
        self.imageViewSelected = false
        for view in self.subviews {
          if view is ImageViewTool {
            view.removeFromSuperview()
            break
          }
        }
      }

      guard let tool = pathArray.lastObject as? SketchTool else { return }
      resetTool()
      bufferArray.add(tool)
      pathArray.removeLastObject()
      updateCacheImage(true)

      setNeedsDisplay()

    }
  }

  public func redo() {
    if canRedo() {
      guard let tool = bufferArray.lastObject as? SketchTool else { return }
      resetTool()
      pathArray.add(tool)

      if self.imageViewSelected {
        self.imageViewSelected = false

        if let tool: SelectTool = tool as? SelectTool {

          for view in self.subviews {
            if view is ImageViewTool {
              view.removeFromSuperview()
              break
            }
          }

          self.currentTool = tool
        }
      }

      updateCacheImage(true)
      bufferArray.removeLastObject()
      setNeedsDisplay()
    }
  }

  func canUndo() -> Bool {
    return pathArray.count > 0
  }

  func canRedo() -> Bool {
    return bufferArray.count > 0
  }
}
