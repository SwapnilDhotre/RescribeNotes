//
//  ImageViewTool.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 14/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

class ImageViewTool: UIImageView, SketchTool {
  var lineWidth: CGFloat
  var lineColor: UIColor
  var lineAlpha: CGFloat

  var touchPoint: CGPoint

  var imageViewToPan: UIImageView?

  var actualWidth: CGFloat = 0
  var actualHeight: CGFloat = 0

  var width: CGFloat = 150 {
    didSet {
      self.draw()
    }
  }
  var height: CGFloat = 150 {
    didSet {
      self.draw()
    }
  }

  init() {

    lineWidth = 0
    lineColor = .blue
    lineAlpha = 0
    touchPoint = CGPoint(x: 0, y: 0)

    super.init(frame: CGRect(x: 0, y: 0, width: self.width, height: height))

    self.setDashedBorder()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setDashedBorder() {
    let borderView = CAShapeLayer()
    borderView.strokeColor = UIColor.black.cgColor
    borderView.lineDashPattern = [3, 3]
    borderView.frame = self.bounds
    borderView.fillColor = nil
    borderView.path = UIBezierPath(rect: self.bounds).cgPath
    self.layer.addSublayer(borderView)
  }

  func setInitialPoint(_ firstPoint: CGPoint) {
    self.touchPoint = firstPoint
    print("Initiated position")

    self.addPanGesture(view: self)
    self.addRotateGesture(view: self)
    self.addPinchGesture(view: self)
  }

  func moveFromPoint(_ startPoint: CGPoint, toPoint endPoint: CGPoint) { }

  func draw() {
    print("Tool drawn w:\(self.width) h:\(self.height)")
    self.backgroundColor = UIColor.clear

    self.bounds = CGRect(x: 0, y: 0, width: self.width, height: self.height)
    self.center.x = touchPoint.x
    self.center.y = touchPoint.y
  }

  // MARK: - Setup Gestures
  func addTapGesture(view: UIView) {
    view.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(_:)))
    view.addGestureRecognizer(tapGesture)
  }

  func addPinchGesture(view: UIView) {
    view.isUserInteractionEnabled = true
    let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                action: #selector(self.pinchGesture))
    pinchGesture.delegate = self
    view.addGestureRecognizer(pinchGesture)
  }

  func addPanGesture(view: UIView) {
    view.isUserInteractionEnabled = true
    let panGesture = UIPanGestureRecognizer(target: self,
                                            action: #selector(self.panGesture))
    panGesture.minimumNumberOfTouches = 1
    panGesture.maximumNumberOfTouches = 1
    panGesture.delegate = self
    view.addGestureRecognizer(panGesture)
  }

  func addRotateGesture(view: UIView) {
    let rotationGestureRecognizer =
      UIRotationGestureRecognizer(target: self,
                                  action: #selector(self.rotationGesture))
    rotationGestureRecognizer.delegate = self
    view.addGestureRecognizer(rotationGestureRecognizer)
  }
}

extension ImageViewTool: UIGestureRecognizerDelegate {

  /**
   UITapGestureRecognizer - Taping on Objects
   Will make scale scale Effect
   Selecting transparent parts of the imageview won't move the object
   */
  @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
    if let view = recognizer.view {
      if let imageTool: ImageViewTool = view as? ImageViewTool, let sketchView: SketchView = imageTool.superview as? SketchView {
        print("ImageView Tapped")
        //Tap only on visible parts on the image
        for imageView in subImageViews(view: sketchView) {
          let location = recognizer.location(in: imageView)
          let alpha = imageView.alphaAtPoint(location)
          if alpha > 0 {
            scaleEffect(view: imageView)
            break
          }
        }
      } else {
        print("not an imageView")
      }
    }
  }

  /**
   Scale Effect
   */
  func scaleEffect(view: UIView) {
    view.superview?.bringSubview(toFront: view)

    if #available(iOS 10.0, *) {
      let generator = UIImpactFeedbackGenerator(style: .heavy)
      generator.impactOccurred()
    }
    let previouTransform =  view.transform
    UIView.animate(withDuration: 0.2,
                   animations: {
                    view.transform = view.transform.scaledBy(x: 1.2, y: 1.2)
    }, completion: { _ in
        UIView.animate(withDuration: 0.2) {
          view.transform  = previouTransform
        }
    })
  }

  func subImageViews(view: UIView) -> [ImageViewTool] {
    var imageviews: [ImageViewTool] = []
    for imageView in view.subviews {
      if imageView is ImageViewTool {
        imageviews.append(imageView as! ImageViewTool)
      }
    }
    return imageviews
  }

  /**
   UIRotationGestureRecognizer - Rotating Objects
   */
  @objc func rotationGesture(_ recognizer: UIRotationGestureRecognizer) {
    self.endEditing(true)
    if let view = recognizer.view as? ImageViewTool {
      view.transform = view.transform.rotated(by: recognizer.rotation)
      recognizer.rotation = 0
    }
  }

  /*
   Support Multiple Gesture at the same time
   */
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return false
  }

  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return false
  }

  /**
   UIPinchGestureRecognizer - Pinching Objects
   If it's a UITextView will make the font bigger so it doen't look pixlated
   */
  @objc func pinchGesture(_ recognizer: UIPinchGestureRecognizer) {
    self.endEditing(true)
    if let view = recognizer.view {

      view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
      recognizer.scale = 1
      self.actualWidth = view.frame.width
      self.actualHeight = view.frame.height
    }
  }

  /**
   UIPanGestureRecognizer - Moving Objects
   Selecting transparent parts of the imageview won't move the object
   */
  @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
    self.endEditing(true)
    if let view = recognizer.view {
      if let imageTool: ImageViewTool = view as? ImageViewTool, let sketchView: SketchView = imageTool.superview as? SketchView {
        //Tap only on visible parts on the image
        if recognizer.state == .began {
          for imageView in subImageViews(view: sketchView) {
            let location = recognizer.location(in: imageView)
            let alpha = imageView.alphaAtPoint(location)
            if alpha > 0 {
              imageViewToPan = imageView
              break
            }
          }
        }
        if self.imageViewToPan != nil {
          moveView(view: self.imageViewToPan!, recognizer: recognizer)
        }
      } else {
        print("Parent view recongnized")
        moveView(view: view, recognizer: recognizer)
      }
    }
  }

  /**
   Moving Objects
   delete the view if it's inside the delete view
   Snap the view back if it's out of the canvas
   */
  func moveView(view: UIView, recognizer: UIPanGestureRecognizer)  {

    if let imageTool: ImageViewTool = view as? ImageViewTool, let sketchView: SketchView = imageTool.superview as? SketchView {

      sketchView.bringSubview(toFront: imageTool)
      let pointToSuperView = recognizer.location(in: sketchView)

      imageTool.center = CGPoint(x: imageTool.center.x + recognizer.translation(in: sketchView).x,
                                     y: imageTool.center.y + recognizer.translation(in: sketchView).y)
      recognizer.setTranslation(CGPoint.zero, in: sketchView)

      if let previousPoint = sketchView.lastPanPoint {
        //View is going into deleteView
        if sketchView.frame.contains(pointToSuperView) && !sketchView.frame.contains(previousPoint) {
          if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
          }
          UIView.animate(withDuration: 0.3, animations: {
            imageTool.transform = imageTool.transform.scaledBy(x: 0.25, y: 0.25)
            imageTool.center = recognizer.location(in: sketchView)
          })
        }
          //View is going out of deleteView
        else if sketchView.frame.contains(previousPoint) && !sketchView.frame.contains(pointToSuperView) {
          //Scale to original Size
          UIView.animate(withDuration: 0.3, animations: {
            imageTool.transform = imageTool.transform.scaledBy(x: 4, y: 4)
            imageTool.center = recognizer.location(in: sketchView)
          })
        }
      }

      sketchView.lastPanPoint = pointToSuperView

      if recognizer.state == .ended {
        sketchView.lastPanPoint = nil
        let lastPoint = CGPoint(x: imageTool.center.x, y: imageTool.center.y)//recognizer.location(in: sketchView)

        self.touchPoint = lastPoint
      }
    }
  }
}
