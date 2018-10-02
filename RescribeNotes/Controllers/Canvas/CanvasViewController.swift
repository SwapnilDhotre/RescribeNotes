//
//  CanvasViewController.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 06/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit
import AssetsPickerViewController
import Photos
import TinyLog

class CanvasViewController: UIViewController {

  @IBOutlet var templateLeftConstraint: NSLayoutConstraint!
  @IBOutlet var templateView: TemplatePalatteView!

  @IBOutlet var toolsRightConstraint: NSLayoutConstraint!
  @IBOutlet var toolsPalatteView: ToolsPalatteView!
  
  @IBOutlet var toolbarView: ToolbarView!
  
  @IBOutlet var sketchView: SketchView!
  @IBOutlet var gridButton: UIButton!

  var emptyView: UIView?
  var imageViewToPan: UIImageView?

  // Tools
  var eraserSlider: SliderView?
  var tipSizeSlider: SliderView?
  var opacitySlider: SliderView?

  private var templatePickerCalled: Bool = false
  private var linesDrawn: LinesDrawn?
  private var previousLineWidth: CGFloat = 0
  // Properties
  var tipSize: CGFloat = 2 {
    didSet {
      self.sketchView.lineWidth = self.tipSize
    }
  }

  var tipOpacity: CGFloat = 1.0 {
    didSet {
      self.sketchView.lineAlpha = self.tipOpacity
    }
  }

  var tipColor: UIColor = .black {
    didSet {
      self.sketchView.lineColor = self.tipColor
    }
  }

  @IBOutlet var backgroundImage: UIImageView!
  @IBOutlet var gridImage: UIImageView!
  var gridDrawnOnBackground: UIImage?
  
  // Grid Lines
  var gridLineThickness: CGFloat = 0.5
  var gridLineGap: CGFloat = 20
  var gridLineColor: UIColor = .red

  // MARK: - Life Cycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()

    self.setDefaultValue()
    self.setUIAppearance()
    NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.updateViewOnAppear()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  func setDefaultValue() {

    if let defaultTemplateData = Utility.getUserLocalObjectForKey(key: Constants.UserDefault.lastTemplateSelected) as? Data {
      self.templateView.selectedTemplateImage.image = UIImage(data: defaultTemplateData)
    }
    if let color = Utility.getUserLocalObjectForKey(key: Constants.UserDefault.tipColor) as? String {
      self.tipColor = UIColor(hexString: color)
    }
    if let size = Utility.getUserLocalObjectForKey(key: Constants.UserDefault.tipSize) as? CGFloat {
      self.tipSize = size
    }
    if let opacity = Utility.getUserLocalObjectForKey(key: Constants.UserDefault.tipOpacity) as? CGFloat {
      self.tipOpacity = opacity
    }
    if let gridLines = Utility.getUserLocalObjectForKey(key: Constants.UserDefault.gridLines) as? Int, let grid: LinesDrawn = LinesDrawn(rawValue: gridLines) {
      self.linesDrawn = grid
    }
    if let gridColor = Utility.getUserLocalObjectForKey(key: Constants.UserDefault.gridColor) as? String {
      self.gridLineColor = UIColor(hexString: gridColor)
    }
    if let lineThickness = Utility.getUserLocalObjectForKey(key: Constants.UserDefault.gridLineThickness) as? CGFloat {
      self.gridLineThickness = lineThickness
    }
    if let gridGap = Utility.getUserLocalObjectForKey(key: Constants.UserDefault.gridLineGap) as? CGFloat {
      self.gridLineGap = gridGap
    }
  }

  @objc func rotated() {

    if self.gridImage.image != nil {
      self.drawGrid(onImage: nil, linesDrawn: self.linesDrawn ?? .horizontal, lineWidth: self.gridLineThickness, gap: self.gridLineGap, color: self.gridLineColor)
    }
  }

  // MARK: - Custom Methods
  func updateViewOnAppear() {

    self.templateView.visualEffect.roundCorners(corners: [.topRight, .bottomRight], radius: 10)
    self.templateView.setNeedsLayout()

    self.setSelectedTemplateShadow()

    self.view.bringSubview(toFront: self.templateView)
    self.view.bringSubview(toFront: self.toolsPalatteView)
  }

  func setSelectedTemplateShadow() {
    self.templateView.selectedTemplateImage.cornerRadius = 10
    self.templateView.selectedTemplateImage.masksToBounds = true
    self.templateView.defaultImageContainer.layer.cornerRadius = 5.0
    self.templateView.defaultImageContainer.layer.borderWidth = 1.5
    self.templateView.defaultImageContainer.layer.borderColor = UIColor.white.cgColor
    self.templateView.defaultImageContainer.layer.masksToBounds = false

    self.templateView.templatesCollectionView.reloadData()
  }

  func setUIAppearance() {

    self.sketchView.lineWidth = self.tipSize
    self.sketchView.lineColor = self.tipColor

    self.templateView.templateDelegate = self
    self.toolsPalatteView.toolDelegate = self
    self.toolbarView.delegate = self

    self.templateView.btnGalleryPicker.addTarget(self, action: #selector(self.galleryImagePicker(sender:)), for: .touchUpInside)
    self.templateView.btnExpandTemplate.addTarget(self, action: #selector(self.expandTemplate(button:)), for: .touchUpInside)
    self.toolsPalatteView.btnExpandTools.addTarget(self, action: #selector(self.expandTools(button:)), for: .touchUpInside)

    self.sketchView.sketchViewDelegate = self
    self.addLeftNavButton()
    self.addRightNavButtons(withDoneBtn: false)
  }

  func drawGrid(onImage gridBackImage: UIImage?, linesDrawn: LinesDrawn, lineWidth: CGFloat, gap: CGFloat, color: UIColor) {

    let originalImage = gridBackImage ?? UIImage()
    let widthOfImage = self.gridImage.bounds.width
    let heightOfImage = self.gridImage.bounds.height
    UIGraphicsBeginImageContext(self.gridImage.bounds.size)

    // Pass 1: Draw the original image as the background
    originalImage.draw(at: CGPoint.zero)

    // Pass 2: Draw the line on top of original image
    let context = UIGraphicsGetCurrentContext()!
    context.setLineWidth(lineWidth)

    if linesDrawn == .both {
      var yPosition: CGFloat = 0
      while (yPosition < heightOfImage) {
        context.move(to: CGPoint(x: 0, y: yPosition))
        context.addLine(to: CGPoint(x: widthOfImage, y: yPosition))
        yPosition += gap
      }

      var xPosition: CGFloat = 0
      while (xPosition < widthOfImage) {
        context.move(to: CGPoint(x: xPosition, y: 0))
        context.addLine(to: CGPoint(x: xPosition, y: heightOfImage))
        xPosition += gap
      }
    } else if linesDrawn == .vertical {

      var xPosition: CGFloat = 0
      while (xPosition < widthOfImage) {
        context.move(to: CGPoint(x: xPosition, y: 0))
        context.addLine(to: CGPoint(x: xPosition, y: heightOfImage))
        xPosition += gap
      }
    } else if linesDrawn == .horizontal {

      var yPosition: CGFloat = 0
      while (yPosition < heightOfImage) {
        context.move(to: CGPoint(x: 0, y: yPosition))
        context.addLine(to: CGPoint(x: widthOfImage, y: yPosition))
        yPosition += gap
      }
    }

    context.setStrokeColor(color.cgColor)
    context.strokePath()

    // Create new image
    if let image = UIGraphicsGetImageFromCurrentImageContext() {
      if gridBackImage == nil {
        self.gridImage.image = image
      } else {
        self.gridDrawnOnBackground = image
      }
    }

    // Tidy up
    UIGraphicsEndImageContext();
  }

  func addSaveButton() {
    let saveBarButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveImage))
    self.navigationItem.rightBarButtonItem  = saveBarButton
  }

  func imageFromView(myView: UIView) -> UIImage? {

    UIGraphicsBeginImageContextWithOptions(myView.bounds.size, false, UIScreen.main.scale)
    myView.drawHierarchy(in: myView.bounds, afterScreenUpdates: true)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return image
  }

  @objc func saveImage(sender: UIBarButtonItem) {

    var backgroundImage = self.imageFromView(myView: self.backgroundImage)
    let hasGridLine = !(self.gridImage.image == nil)

    let alert = UIAlertController(title: "Notes", message: nil, preferredStyle: .actionSheet)

    if hasGridLine {
      alert.addAction(UIAlertAction(title: "Save with grid", style: .default, handler: { (action) in
        self.drawGrid(onImage: backgroundImage, linesDrawn: self.linesDrawn ?? .horizontal, lineWidth: self.gridLineThickness, gap: self.gridLineGap, color: self.gridLineColor)
        backgroundImage = self.gridDrawnOnBackground

        self.showImage(withBackgroundImage: backgroundImage)
      }))
      alert.addAction(UIAlertAction(title: "Save without grid", style: .default, handler: { (action) in

        self.showImage(withBackgroundImage: backgroundImage)
      }))
    } else {

      alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in

        self.showImage(withBackgroundImage: backgroundImage)
      }))
    }

    alert.addAction(UIAlertAction(title: "Set as default", style: .default, handler: { (action) in

      self.saveToDefault()
    }))

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

    if let popoverController = alert.popoverPresentationController {
      popoverController.barButtonItem = sender
    }

    self.present(alert, animated: true, completion: nil)

  }

  func showImage(withBackgroundImage backgroundImage: UIImage?) {

    self.sketchView.getEditedImage(backgroundImage: backgroundImage) { (canvasImage: UIImage) in

      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      if let controller = storyboard.instantiateViewController(withIdentifier: "imagePreviewController") as? ImagePreviewViewController {
        controller.imageToUpload = canvasImage
        controller.cachedNavigation = self.navigationController

        controller.providesPresentationContextTransitionStyle = true
        controller.definesPresentationContext = true
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext

        self.present(controller, animated: true, completion: nil)
      }
    }
  }

  func addLeftNavButton() {

    let backBarButton = self.getBackButton()

    let clearBarButton = UIBarButtonItem(title: "Clear All", style: .done, target: self, action: #selector(self.clearAll))

    let barButtons: Array = [backBarButton, clearBarButton]

    self.navigationItem.leftBarButtonItems = barButtons
  }

  func getBackButton() -> UIBarButtonItem {
    let leftButton = UIButton(type: .system)
    leftButton.setTitle("n", for: .normal)
    leftButton.titleLabel?.font = UIFont().fontIcon(withSize: 17)
    leftButton.setTitleColor(.white, for: .normal)
    leftButton.frame = CGRect(x: 0, y: 0, width: 40.0, height: 40.0)
    leftButton.addTarget(self, action: #selector(self.backButtonTapped), for: .touchUpInside)

    let leftBackBtn = UIBarButtonItem(customView: leftButton)
    return leftBackBtn
  }

  @objc func backButtonTapped() {

    let alert = UIAlertController(title: "Rescribe Notes", message: "Are you sure want to move back? Your work is not saved.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
      self.navigationController?.popViewController(animated: false)
    }))
    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

    self.present(alert, animated: true, completion: nil)
  }

  func addRightNavButtons(withDoneBtn: Bool) {

    let saveBarButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveImage(sender:)))

    if withDoneBtn {

      saveBarButton.isEnabled = false
      let doneBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.drawImage))

      let barButtons: Array = [saveBarButton, doneBarButton]
      self.navigationItem.rightBarButtonItems = barButtons
    } else {
      self.navigationItem.rightBarButtonItems = []
      self.navigationItem.rightBarButtonItem = saveBarButton
    }
  }

  func showShapePalatte(view: UIView) {

    let height: CGFloat = 270
    let shapeView: ShapePickerPalatte = ShapePickerPalatte.fromNib()
    shapeView.delegate = self

    self.showActionSheet(forView: shapeView, sourceView: view, withTitle: "Shape Tools", customViewHeight: height)
  }

  func showClipArtPalatte(view: UIView) {

    let height: CGFloat = 270
    let clipArtView: ClipArtView = ClipArtView.fromNib()
    clipArtView.delegate = self

    self.showActionSheet(forView: clipArtView, sourceView: view, withTitle: "Clip Arts", customViewHeight: height)
  }

  func showColorPicker(forView sourceView: UIView) {

    let gridController: GridViewController = GridViewController.fromNib()
    gridController.lineColor = self.tipColor
    gridController.isTipColorPicker = true
    gridController.delegate = self

    let navCtrl = UINavigationController(rootViewController: gridController)
    navCtrl.modalPresentationStyle = UIModalPresentationStyle.popover
    let popover = navCtrl.popoverPresentationController
    popover?.delegate = self
    popover?.sourceView = sourceView
    popover?.sourceRect = sourceView.bounds
    popover?.backgroundColor = UIColor(hexString: "#33363B")

    navCtrl.navigationBar.isHidden = true

    if UIUserInterfaceSizeClass.compact == self.traitCollection.horizontalSizeClass {

      navCtrl.navigationBar.isHidden = false
      navCtrl.navigationBar.isTranslucent = false
      let doneBtn: UIBarButtonItem = UIBarButtonItem(
        title: NSLocalizedString("Done", comment: ""),
        style: UIBarButtonItemStyle.done,
        target: self,
        action: #selector(self.dismissingController)
      )
      gridController.navigationItem.rightBarButtonItem = doneBtn

      navCtrl.preferredContentSize = gridController.view.systemLayoutSizeFitting(
        UILayoutFittingCompressedSize
      )
      self.present(navCtrl, animated: true, completion: nil)
    } else {

      gridController.preferredContentSize = CGSize(width: 300, height: 380)
      self.present(navCtrl, animated: true, completion: nil)
    }
  }

  func traingleShapeWithCenter(center: CGPoint, side: CGFloat) -> CAShapeLayer {

    let layer = CAShapeLayer()

    let path = UIBezierPath()

    let startX = center.x - side / 2
    let startY = center.y - side / 2

    path.move(to: CGPoint(x: startX, y: startY))
    path.addLine(to: CGPoint(x: startX, y: startY + side))
    path.addLine(to: CGPoint(x: startX + side, y: startY + side/2))
    path.close()

    layer.path = path.cgPath
    layer.fillColor = UIColor(hexString: "D2D2D2", alpha: 1).cgColor
    return layer
  }

  func showTipSizeView(view: UIView) {

    let height: CGFloat = 70
    let tipView: SliderView = SliderView.fromNib()
    tipView.lblSlider.text = "Tip Size: \(Int(self.tipSize))"
    tipView.slider.setValue(Float(self.tipSize), animated: true)
    tipView.slider.tag = 1
    tipView.slider.addTarget(self, action: #selector(self.sliderValueChanged(_:_:)), for: UIControlEvents.valueChanged)

    self.tipSizeSlider = tipView

    self.showActionSheet(forView: tipView, sourceView: view, withTitle: "Pen - Size", customViewHeight: height)
  }

  func showEraserSizeView(view: UIView) {

    self.tipSize = 40
    let height: CGFloat = 70

    let tipView: SliderView = SliderView.fromNib()
    tipView.lblSlider.text = "Eraser Size: \(Int(self.tipSize))"
    tipView.slider.setValue(Float(self.tipSize), animated: true)
    tipView.slider.tag = 3
    tipView.slider.minimumValue = 20
    tipView.slider.maximumValue = 100
    tipView.slider.addTarget(self, action: #selector(self.sliderValueChanged(_:_:)), for: UIControlEvents.valueChanged)

    self.eraserSlider = tipView

    self.showActionSheet(forView: tipView, sourceView: view, withTitle: "Eraser - Size", customViewHeight: height)
  }

  func showOpacityView(view: UIView) {

    let height: CGFloat = 70
    let tipOpacity: SliderView = SliderView.fromNib()
    tipOpacity.lblSlider.text = "Opacity: \(String(format: "%.1f", self.tipOpacity))"
    tipOpacity.slider.minimumValue = 0.1
    tipOpacity.slider.maximumValue = 1.0
    tipOpacity.slider.setValue(Float(self.tipOpacity), animated: true)
    tipOpacity.slider.tag = 2
    tipOpacity.slider.addTarget(self, action: #selector(self.sliderValueChanged(_:_:)), for: UIControlEvents.valueChanged)

    self.opacitySlider = tipOpacity

    self.showActionSheet(forView: tipOpacity, sourceView: view, withTitle: "Pen - Opacity", customViewHeight: height)
  }

  func showActionSheet(forView view: UIView, sourceView: UIView, withTitle title: String, customViewHeight: CGFloat) {

    let alertController = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)

    view.cornerRadius = 5
    view.masksToBounds = true
    alertController.view.addSubview(view)

    let subview = (alertController.view.subviews.first?.subviews.first?.subviews.first!)! as UIView

    subview.backgroundColor = UIColor(hexString: "4E5259")
    alertController.view.tintColor = UIColor.black

    view.translatesAutoresizingMaskIntoConstraints = false
    view.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 45).isActive = true
    view.rightAnchor.constraint(equalTo: alertController.view.rightAnchor, constant: -10).isActive = true
    view.leftAnchor.constraint(equalTo: alertController.view.leftAnchor, constant: 10).isActive = true
    view.heightAnchor.constraint(equalToConstant: customViewHeight).isActive = true

    alertController.view.translatesAutoresizingMaskIntoConstraints = false

    if UIUserInterfaceSizeClass.compact == self.traitCollection.horizontalSizeClass {
      alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      alertController.view.heightAnchor.constraint(equalToConstant: customViewHeight + 120).isActive = true
    } else {
      alertController.view.heightAnchor.constraint(equalToConstant: customViewHeight + 55).isActive = true
    }

    alertController.popoverPresentationController?.delegate = self
    alertController.popoverPresentationController?.sourceView = sourceView
    alertController.popoverPresentationController?.sourceRect = sourceView.bounds
    alertController.popoverPresentationController?.backgroundColor = UIColor(hexString: "#4E5259")

    self.present(alertController, animated: true, completion: nil)
  }

  func showImagePickOptions(sourceView: UIView) {
    let actionSheet = UIAlertController(title: "Pick Report", message: nil, preferredStyle: .actionSheet)

    let camera = UIAlertAction(title: "Camera", style: .default, handler: { _ in

      self.toolsPalatteView.btnExpandTools.sendActions(for: .touchUpInside)
      self.cameraPickerTapped()
    })

    let gallery = UIAlertAction(title: "Gallery", style: .default, handler: { _ in

      self.toolsPalatteView.btnExpandTools.sendActions(for: .touchUpInside)
      self.galleryPickerTapped()
    })

//    camera.setValue(#imageLiteral(resourceName: "cameraAlert"), forKey: "image")
//    gallery.setValue(#imageLiteral(resourceName: "galleryAlert"), forKey: "image")

    actionSheet.addAction(camera)
    actionSheet.addAction(gallery)

    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in

      self.toolsPalatteView.btnExpandTools.sendActions(for: .touchUpInside)
      print("Cancel tapped.")
    }))

    // Show Action sheet according to device
    if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
      if let presenter = actionSheet.popoverPresentationController {
        presenter.sourceView = sourceView
        presenter.sourceRect = sourceView.bounds
      }

      present(actionSheet, animated: true, completion: nil)

    } else {
      present(actionSheet, animated: true, completion: nil)
    }
  }

  func cameraPickerTapped() {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.sourceType = UIImagePickerControllerSourceType.camera
      imagePicker.allowsEditing = false
      present(imagePicker, animated: true, completion: nil)
    }
  }

  func galleryPickerTapped() {
    let picker = AssetsPickerViewController()
    picker.pickerDelegate = self
    present(picker, animated: true, completion: nil)
  }

  func setUpEmptyView(rect: CGRect, forToolBar: Bool) {
    if self.emptyView != nil {

      self.emptyView?.frame = forToolBar ? rect : CGRect(x: rect.origin.x + 30, y: rect.origin.y + 30, width: 0, height: 0)
    } else {
      self.emptyView = forToolBar ? UIView(frame: rect) : UIView(frame: CGRect(x: rect.origin.x + 30, y: rect.origin.y + 30, width: 0, height: 0))
      self.view.addSubview(self.emptyView!)
    }

    self.view.bringSubview(toFront: self.toolbarView)
    self.view.bringSubview(toFront: self.toolsPalatteView)
    self.emptyView?.tag = 250
  }

  // MARK: - Action Methods
  @objc func galleryImagePicker(sender: UIButton) {
    self.templatePickerCalled = true
    self.showImagePickOptions(sourceView: sender)
  }

  @IBAction func expandTemplate(button: UIButton) {

    if self.toolsPalatteView.btnExpandTools.isSelected {
      self.toolsPalatteView.btnExpandTools.sendActions(for: .touchUpInside)
    }

    if button.isSelected {

      button.isSelected = false
      self.templateLeftConstraint.constant = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? -410 : -235

      UIView.animate(withDuration: 0.5,
                     delay: 0.0,
                     options: [.curveEaseInOut , .allowUserInteraction],
                     animations: {
                      self.view.layoutIfNeeded()
      }, completion: nil)

    } else {

      button.isSelected = true
      self.templateLeftConstraint.constant = 0

      UIView.animate(withDuration: 0.7,
                     delay: 0.0,
                     options: [.curveEaseInOut , .allowUserInteraction],
                     animations: {
                      self.view.layoutIfNeeded()
      }, completion: nil)
    }
  }

  @IBAction func expandTools(button: UIButton) {

    if self.templateView.btnExpandTemplate.isSelected {
      self.templateView.btnExpandTemplate.sendActions(for: .touchUpInside)
    }
    if button.isSelected {
      button.isSelected = false
      self.toolsRightConstraint.constant = -90
      UIView.animate(withDuration: 0.4) {
        DispatchQueue.main.async {
          self.view.layoutIfNeeded()
        }
      }
    } else {
      button.isSelected = true
      self.toolsRightConstraint.constant = 0
      UIView.animate(withDuration: 0.4) {
        DispatchQueue.main.async {
          self.view.layoutIfNeeded()
        }
      }
    }
  }

  @objc func drawImage() {

    self.sketchView.drawImage()
    self.addRightNavButtons(withDoneBtn: false)
  }

  @IBAction func gridBtnTapped(_ sender: UIButton) {

    self.showGridColorPicker(sourceView: sender)
  }

  func showGridColorPicker(sourceView: UIView) {

    let gridController: GridViewController = GridViewController.fromNib()

    gridController.lineThickness = self.gridLineThickness
    gridController.lineGap = self.gridLineGap
    gridController.lineColor = self.gridLineColor
    gridController.selectedSegment = self.linesDrawn ?? .horizontal
    gridController.isGridVisible = !(self.gridImage.image == nil)

    gridController.delegate = self

    let navCtrl = UINavigationController(rootViewController: gridController)
    navCtrl.modalPresentationStyle = UIModalPresentationStyle.popover
    let popover = navCtrl.popoverPresentationController
    popover?.delegate = self
    popover?.sourceView = sourceView
    popover?.sourceRect = sourceView.bounds
    popover?.backgroundColor = UIColor(hexString: "#33363B")

    navCtrl.navigationBar.isHidden = true

    if UIUserInterfaceSizeClass.compact == self.traitCollection.horizontalSizeClass {

      navCtrl.navigationBar.isHidden = false
      navCtrl.navigationBar.isTranslucent = false
      let doneBtn: UIBarButtonItem = UIBarButtonItem(
        title: NSLocalizedString("Done", comment: ""),
        style: UIBarButtonItemStyle.done,
        target: self,
        action: #selector(self.dismissingController)
      )
      gridController.navigationItem.rightBarButtonItem = doneBtn

      navCtrl.preferredContentSize = gridController.view.systemLayoutSizeFitting(
        UILayoutFittingCompressedSize
      )
      self.present(navCtrl, animated: true, completion: nil)
    } else {

      gridController.preferredContentSize = CGSize(width: 300, height: 600)
      self.present(navCtrl, animated: true, completion: nil)
    }
  }

  func saveToDefault() {

    _ = Utility.setUserLocalObject(object: self.tipSize, key: Constants.UserDefault.tipSize)
    _ = Utility.setUserLocalObject(object: self.tipColor.toHex(), key: Constants.UserDefault.tipColor)
    _ = Utility.setUserLocalObject(object: self.tipOpacity, key: Constants.UserDefault.tipOpacity)
    _ = Utility.setUserLocalObject(object: self.gridLineColor.toHex(), key: Constants.UserDefault.gridColor)
    _ = Utility.setUserLocalObject(object: self.gridLineGap, key: Constants.UserDefault.gridLineGap)
    _ = Utility.setUserLocalObject(object: self.gridLineThickness, key: Constants.UserDefault.gridLineThickness)
    _ = Utility.setUserLocalObject(object: (self.linesDrawn ?? .horizontal).rawValue, key: Constants.UserDefault.gridLines)
    if let backgroundImage = self.backgroundImage.image {
      _ = Utility.setUserLocalObject(object: UIImagePNGRepresentation(backgroundImage), key: Constants.UserDefault.lastTemplateSelected)
    }
  }

  @objc func clearAll() {

    let alert: UIAlertController = UIAlertController(title: "Add Notes", message: "Are you sure you want to clear your work?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
      self.sketchView.clear()
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
}

// MARK: - Template palatte
extension CanvasViewController: TemplatePalatteDelegate {
  func getDefaultTemplate(image: UIImage) {
    self.backgroundImage.image = image

    if self.templateView.btnExpandTemplate.isSelected {
      self.templateView.btnExpandTemplate.sendActions(for: .touchUpInside)
    } else if self.toolsPalatteView.btnExpandTools.isSelected {
      self.toolsPalatteView.btnExpandTools.sendActions(for: .touchUpInside)
    }
  }

  func selectedTemplate(template: TemplateImage) {

    self.backgroundImage.image = template.originalImage

    if self.templateView.btnExpandTemplate.isSelected {
      self.templateView.btnExpandTemplate.sendActions(for: .touchUpInside)
    } else if self.toolsPalatteView.btnExpandTools.isSelected {
      self.toolsPalatteView.btnExpandTools.sendActions(for: .touchUpInside)
    }
  }
}

//MARK: - Clip Arts
extension CanvasViewController: ClipArtDelegate {

  func clipArtSelected(obj: ClipArt) {

    let image = UIImage(named: obj.url)!
    self.sketchView.drawTool = .imageTool
    self.sketchView.currentSelectedImage = image.fixOrientation()

    self.toolbarView.showColorOption()
    self.dismiss(animated: true, completion: nil)
  }
}

// MARK: - Tools palatte
extension CanvasViewController: ToolsPalatteDelegate {
  func selectedTool(rect: CGRect, tool: ToolIcon) {

    let rect = self.toolsPalatteView.convert(rect, to: self.view)
    self.setUpEmptyView(rect: rect, forToolBar: false)

    if self.sketchView.drawTool == .select {
      self.sketchView.drawImage()
    }

    if tool == .shapeTool {

      self.showShapePalatte(view: self.emptyView!)
    } else if tool == .pencilTool {

      self.sketchView.drawTool = .pen
      self.toolsPalatteView.btnExpandTools.sendActions(for: .touchUpInside)
    } else if tool == .textTool {
      self.sketchView.drawTool = .textTool
      self.toolsPalatteView.btnExpandTools.sendActions(for: .touchUpInside)
    } else if tool == .imageTool {
      self.sketchView.drawTool = .imageTool
      self.templatePickerCalled = false
      self.showImagePickOptions(sourceView: self.emptyView!)
    } else if tool == .clipArt {

      self.showClipArtPalatte(view: self.emptyView!)
    }
  }
}

// MARK: - Shape Delegates
extension CanvasViewController: ShapeDelegate {
  func selectedTool(tool: SketchToolType) {

    self.dismiss(animated: true, completion: nil)
    self.sketchView.drawTool = tool

    if self.templateView.btnExpandTemplate.isSelected {
      self.templateView.btnExpandTemplate.sendActions(for: .touchUpInside)
    } else if self.toolsPalatteView.btnExpandTools.isSelected {
      self.toolsPalatteView.btnExpandTools.sendActions(for: .touchUpInside)
    }
  }
}

// MARK: - Toolbar Delegates
extension CanvasViewController: ToolbarDelegate {

  func toolbarTapped(forItem barButton: ToolBarButton, rect: CGRect) {

    let rect = self.toolbarView.convert(rect, to: self.view)
    self.setUpEmptyView(rect: rect, forToolBar: true)

    if barButton.object == .penTip {

      self.showTipSizeView(view: self.emptyView!)
    } else if barButton.object == .opacity {

      self.showOpacityView(view: self.emptyView!)
    } else if barButton.object == .undo {
      self.sketchView.undo()
    } else if barButton.object == .redo {
      self.sketchView.redo()
    } else if barButton.object == .eraser {

      self.previousLineWidth = self.tipSize
      self.sketchView.drawTool = .eraser
      self.toolbarView.eraserSelected = true
      self.toolbarView.collectionView.reloadData()
      self.showEraserSizeView(view: self.emptyView!)
    } else if barButton.object == .color {
      self.showColorPicker(forView: self.emptyView!)
    }

    if self.templateView.btnExpandTemplate.isSelected {
      self.templateView.btnExpandTemplate.sendActions(for: .touchUpInside)
    } else if self.toolsPalatteView.btnExpandTools.isSelected {
      self.toolsPalatteView.btnExpandTools.sendActions(for: .touchUpInside)
    }
  }


  @objc func sliderValueChanged(_ sender: UISlider, _ event: UIEvent) {

    if let touchEvent = event.allTouches?.first {
      switch touchEvent.phase {
      case .began: break
      // handle drag began
      case .moved: break
      // handle drag moved
      case .ended:
        if self is UIAlertController {
          self.dismiss(animated: true, completion: nil)
        }
        break
      // handle drag ended
      default:
        break
      }
    }

    if sender.tag == 1 {
      self.tipSizeSlider?.lblSlider.text = "Tip Size: \(Int(sender.value))"
      self.previousLineWidth = CGFloat(sender.value)
      self.tipSize = CGFloat(sender.value)
    } else if sender.tag == 2 {
      self.opacitySlider?.lblSlider.text = "Opacity: \(String(format: "%.1f", sender.value))"
      self.tipOpacity = CGFloat(sender.value)
    } else if sender.tag == 3 {
      self.tipSize = CGFloat(sender.value)
      self.eraserSlider?.lblSlider.text = "Eraser Size: \(Int(sender.value))"
    }

  }
}

// MARK: - SketchView Delegates
extension CanvasViewController: SketchViewDelegate {

  func drawView(_ view: SketchView, willBeginDrawUsingTool tool: Any?) {

    if self is UIAlertController {
      self.dismiss(animated: true, completion: nil)
    }

    if self.templateView.btnExpandTemplate.isSelected {
      self.templateView.btnExpandTemplate.sendActions(for: .touchUpInside)
    } else if self.toolsPalatteView.btnExpandTools.isSelected {
      self.toolsPalatteView.btnExpandTools.sendActions(for: .touchUpInside)
    }
  }

  func drawToolChanged(selectedTool: Any?) {

    if let tool = selectedTool as? SketchToolType {
      self.toolbarView.selectedTool = tool
      self.addRightNavButtons(withDoneBtn: false)
      self.toolbarView.setToolBar()
    }
    if let tool = selectedTool as? SketchToolType, tool != .eraser {
      self.tipSize = self.previousLineWidth
      self.toolbarView.eraserSelected = false
      self.toolbarView.collectionView.reloadData()
    }
    if let tool = selectedTool as? SketchToolType, tool == .select {

      self.addRightNavButtons(withDoneBtn: true)
    }
  }
}

// MARK: - ColorSelection Delegates
extension CanvasViewController: UIPopoverPresentationControllerDelegate, EFColorSelectionViewControllerDelegate {

  func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
    self.templatePickerCalled = false
  }

  func colorViewController(colorViewCntroller: EFColorSelectionViewController, didChangeColor color: UIColor) {

    self.tipColor = color
  }

  @objc func dismissColorPicker(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
}

// MARK: - AssetController
extension CanvasViewController: AssetsPickerViewControllerDelegate {
  func assetsPickerCannotAccessPhotoLibrary(controller _: AssetsPickerViewController) {
    logw("Need permission to access photo library.")
  }

  func assetsPickerDidCancel(controller _: AssetsPickerViewController) {
    log("Cancelled.")
  }

  func assetsPicker(controller _: AssetsPickerViewController, selected assets: [PHAsset]) {

    if let asset = assets.first, let pickedImage = self.getUIImage(asset: asset) {

      if self.templatePickerCalled {
        self.backgroundImage.image = pickedImage.fixOrientation()
      } else {
        let pickedImage = pickedImage.fixOrientation()
        self.sketchView.currentSelectedImage = pickedImage
      }
//      self.sketchView.stampImage = pickedImage.fixOrientation()
    }
  }

  func assetsPicker(controller: AssetsPickerViewController, shouldSelect _: PHAsset, at indexPath: IndexPath) -> Bool {
    log("shouldSelect: \(indexPath.row)")
    if controller.selectedAssets.count > 0 {
      return false
    }
    return true
  }

  func assetsPicker(controller _: AssetsPickerViewController, didSelect _: PHAsset, at indexPath: IndexPath) {
    log("didSelect: \(indexPath.row)")
  }

  func assetsPicker(controller _: AssetsPickerViewController, shouldDeselect _: PHAsset, at indexPath: IndexPath) -> Bool {
    log("shouldDeselect: \(indexPath.row)")
    return true
  }

  func assetsPicker(controller _: AssetsPickerViewController, didDeselect _: PHAsset, at indexPath: IndexPath) {
    log("didDeselect: \(indexPath.row)")
  }
}

//MARK: - Grid Value changed
extension CanvasViewController: GridManipulation {
  func tipColorChanged(lineColor: UIColor) {
    self.tipColor = lineColor
  }

  func shouldShowGrid(shouldShowGrid showGrid: Bool) {
    if showGrid {
      self.drawGrid(onImage: nil, linesDrawn: self.linesDrawn ?? .horizontal, lineWidth: self.gridLineThickness, gap: self.gridLineGap, color: self.gridLineColor)
    } else {
      self.gridImage.image = nil
    }
  }

  func gridValueChanged(linesDrawn: LinesDrawn, lineThickness: CGFloat, gapSize: CGFloat, lineColor: UIColor) {

    self.gridLineThickness = lineThickness
    self.gridLineGap = gapSize
    self.gridLineColor = lineColor
    self.linesDrawn = linesDrawn
    self.drawGrid(onImage: nil, linesDrawn: self.linesDrawn!, lineWidth: lineThickness, gap: gapSize, color: lineColor)
  }
}

//MARK: - Camera image picker
extension CanvasViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {

      if self.templatePickerCalled {
        self.backgroundImage.image = pickedImage.fixOrientation()
      } else {
        self.sketchView.currentSelectedImage = pickedImage.fixOrientation()
      }
    }
    picker.dismiss(animated: true, completion: nil)
  }

  func getUIImage(asset: PHAsset) -> UIImage? {
    var img: UIImage?
    let manager = PHImageManager.default()
    let options = PHImageRequestOptions()
    options.version = .original
    options.isSynchronous = true
    manager.requestImageData(for: asset, options: options) { data, _, _, _ in

      if let data = data {
        img = UIImage(data: data)
      }
    }
    return img
  }
}
