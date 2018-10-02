//
//  TextFieldTool.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 14/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

class TextFieldTool: UIView, SketchTool {
  var lineWidth: CGFloat
  var lineColor: UIColor {
    didSet {
      self.textField?.textColor = self.lineColor
    }
  }
  var lineAlpha: CGFloat
  var touchPoint: CGPoint

  var textField: UITextField?
  var width: CGFloat = 40
  var height: CGFloat = 50
  var rotationCalled: Bool = false
  var shouldDraw = false

  var actualWidth: CGFloat = 0
  var actualHeight: CGFloat = 0

  var textFieldWidth: CGFloat = 5 {
    didSet {
      self.width = self.textFieldWidth + 40
      self.draw()
    }
  }

  var font: UIFont = UIFont().font(withStyle: .fontMedium, size: 20) {
    didSet {
      self.height = font.pointSize + 50
      self.width = self.getWidth(text: textField!.text!)
      self.draw()
    }
  }

  init() {

    lineWidth = 0
    lineColor = .blue
    lineAlpha = 0
    touchPoint = CGPoint(x: 0, y: 0)

    super.init(frame: CGRect(x: 0, y: 0, width: self.width, height: height))
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setInitialPoint(_ firstPoint: CGPoint) {
    self.touchPoint = firstPoint
    print("Initiated position")

    self.createTextField()

    self.createPanView()
//    self.addRotateGesture(view: self)

    //    let imageView = UIImageView()
    //    imageView.image = #imageLiteral(resourceName: "refresh.png")
    //    self.addSubview(imageView)
    //
    //    imageView.translatesAutoresizingMaskIntoConstraints = false
    //    imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
    //    imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    //    imageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
    //    imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true

    //    self.addTapGesture(view: imageView)
    //    self.addPanGesture(view: imageView)
    self.addPinchGesture(view: self)
  }

  func moveFromPoint(_ startPoint: CGPoint, toPoint endPoint: CGPoint) { }

  func draw() {
    print("Tool drawn")
    self.backgroundColor = UIColor.clear

    self.bounds = CGRect(x: 0, y: 0, width: self.width, height: self.height)
    self.center.x = touchPoint.x
    self.center.y = touchPoint.y
    self.textField?.textColor = self.lineColor
    self.actualWidth = self.frame.width
    self.actualHeight = self.frame.height

    if shouldDraw, let context: CGContext = UIGraphicsGetCurrentContext() {
      self.textField?.resignFirstResponder()

      context.setShadow(offset: CGSize(width: 0, height: 0), blur: 0, color: nil)

      let imageWidth = self.actualWidth
      let imageHeight = self.actualHeight

      let originX = self.touchPoint.x - (imageWidth / 2)
      let originY = self.touchPoint.y - (imageHeight / 2)

      if let image = self.imageFromView(myView: self) {
      // Below is direct Image draw
        image.draw(in: CGRect(x: originX, y: originY, width: imageWidth, height: imageHeight))
      }
      print("Now text is written")
      self.shouldDraw = false
    }
  }

  func imageFromView(myView: UIView) -> UIImage? {

    UIGraphicsBeginImageContextWithOptions(myView.bounds.size, false, UIScreen.main.scale)
    myView.drawHierarchy(in: myView.bounds, afterScreenUpdates: true)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return image
  }

  // MARK: - Do Setup
  func createTextField() {
    let textField = UITextField()

    textField.borderColor = .red
    textField.borderWidth = 1.5
    textField.cornerRadius = 4

    textField.textAlignment = .center
    textField.font = self.font
    textField.textColor = self.lineColor
    textField.layer.backgroundColor = UIColor.clear.cgColor
    textField.autocorrectionType = .no
    textField.addTarget(self, action: #selector(self.textField(didChange:)), for: .editingChanged)
    textField.delegate = self

    self.addSubview(textField)

    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
    textField.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
    textField.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
    textField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    textField.becomeFirstResponder()

    self.textField = textField
  }

  func createPanView() {

    self.addPanGesture(view: self)
  }

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

extension TextFieldTool: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {

    textField.borderColor = UIColor.clear
    return textField.resignFirstResponder()
  }

  func textFieldDidBeginEditing(_ textField: UITextField) {
    (self.superview as? SketchView)?.selectedTextfieldView = self
    textField.borderColor = UIColor.red
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    if self.textField!.text == "" {
      if let textTool: TextFieldTool = textField.superview as? TextFieldTool {
        textTool.removeFromSuperview()
      }
    }
    textField.borderColor = UIColor.clear
  }

  @objc func textField(didChange textField: UITextField) {

    self.textFieldWidth = self.getWidth(text: textField.text!)
  }

  func getWidth(text: String) -> CGFloat {
    let txtField = UITextField(frame: .zero)
    txtField.text = text
    txtField.font = self.font
    txtField.sizeToFit()
    return txtField.frame.size.width
  }
}

extension TextFieldTool: UIGestureRecognizerDelegate {

  /**
   UITapGestureRecognizer - Taping on Objects
   Will make scale scale Effect
   Selecting transparent parts of the imageview won't move the object
   */
  @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
    if let view = recognizer.view {
      if let imgView = view as? UIImageView {
        print("ImageView Tapped")
      } else {
        print("not a text field")
      }
    }
  }

  /**
   UIRotationGestureRecognizer - Rotating Objects
   */
  @objc func rotationGesture(_ recognizer: UIRotationGestureRecognizer) {
    self.endEditing(true)
    if let view = recognizer.view as? TextFieldTool {
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
      if view is TextFieldTool {
        let textField = (view as! TextFieldTool).textField!

        if textField.font!.pointSize * recognizer.scale < 90 {
          let font = UIFont(name: textField.font!.fontName, size: textField.font!.pointSize * recognizer.scale)
          self.font = font!
          textField.font = font
          let sizeToFit = textField.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                        height:CGFloat.greatestFiniteMagnitude))
          textField.bounds.size = CGSize(width: textField.intrinsicContentSize.width,
                                         height: sizeToFit.height)
        } else {
          let sizeToFit = textField.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                        height:CGFloat.greatestFiniteMagnitude))
          textField.bounds.size = CGSize(width: textField.intrinsicContentSize.width,
                                         height: sizeToFit.height)
        }

        textField.textColor = self.lineColor
        textField.setNeedsDisplay()
      } else {
        view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
      }
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
      if let imgView: UIImageView = view as? UIImageView {
        print("gesture recognized")
        /*let location = gesture.location(in: view)
         let gestureRotation = CGFloat(angle(from: location)) - startRotationAngle
         switch gesture.state {
         case .began:
         startRotationAngle = angle(from: location)
         case .changed:
         rotate(to: rotation - gestureRotation.degreesToRadians)
         case .ended:
         rotation -= gestureRotation.degreesToRadians
         default :
         break
         }
         UserDefaults.standard.rotation = rotation*/
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

    if let textFieldTool: TextFieldTool = view as? TextFieldTool, let sketchView: SketchView = textFieldTool.superview as? SketchView {

      sketchView.bringSubviewToFront(textFieldTool)
      let pointToSuperView = recognizer.location(in: sketchView)

      textFieldTool.center = CGPoint(x: textFieldTool.center.x + recognizer.translation(in: sketchView).x,
                                     y: textFieldTool.center.y + recognizer.translation(in: sketchView).y)
      recognizer.setTranslation(CGPoint.zero, in: sketchView)

      if let previousPoint = sketchView.lastPanPoint {
        //View is going into deleteView
        if sketchView.frame.contains(pointToSuperView) && !sketchView.frame.contains(previousPoint) {
          if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
          }
          UIView.animate(withDuration: 0.3, animations: {
            textFieldTool.transform = textFieldTool.transform.scaledBy(x: 0.25, y: 0.25)
            textFieldTool.center = recognizer.location(in: sketchView)
          })
        }
          //View is going out of deleteView
        else if sketchView.frame.contains(previousPoint) && !sketchView.frame.contains(pointToSuperView) {
          //Scale to original Size
          UIView.animate(withDuration: 0.3, animations: {
            textFieldTool.transform = textFieldTool.transform.scaledBy(x: 4, y: 4)
            textFieldTool.center = recognizer.location(in: sketchView)
          })
        }
      }

      sketchView.lastPanPoint = pointToSuperView

      if recognizer.state == .ended {
        sketchView.lastPanPoint = nil
        let lastPoint = CGPoint(x: textFieldTool.center.x, y: textFieldTool.center.y)//recognizer.location(in: sketchView)

        self.touchPoint = lastPoint
      }
    }
  }
}
