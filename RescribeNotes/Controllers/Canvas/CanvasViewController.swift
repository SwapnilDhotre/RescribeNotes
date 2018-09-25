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
  var tipSizeSlider: SliderView?
  var opacitySlider: SliderView?

  // Properties
  var tipSize: CGFloat = 5 {
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

  // Grid Lines
  var lineThickness: CGFloat = 0.5
  var lineGap: CGFloat = 20
  var lineColor: UIColor = .red

  // MARK: - Life Cycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()

    self.setUIAppearance()
    NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.drawGrid(lineWidth: 1, gap: 50, color: UIColor.red.withAlphaComponent(1))
    self.updateViewOnAppear()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  @objc func rotated() {

    self.drawGrid(lineWidth: self.lineThickness, gap: self.lineGap, color: self.lineColor)
  }

  // MARK: - Custom Methods
  func updateViewOnAppear() {

    self.templateView.visualEffect.roundCorners(corners: [.topRight, .bottomRight], radius: 10)

    self.view.bringSubview(toFront: self.templateView)
    self.view.bringSubview(toFront: self.toolsPalatteView)
  }

  func setUIAppearance() {

    self.sketchView.lineWidth = self.tipSize
    self.sketchView.lineColor = self.tipColor

    self.templateView.templateDelegate = self
    self.toolsPalatteView.toolDelegate = self
    self.toolbarView.delegate = self

    self.templateView.btnExpandTemplate.addTarget(self, action: #selector(self.expandTemplate(button:)), for: .touchUpInside)
    self.toolsPalatteView.btnExpandTools.addTarget(self, action: #selector(self.expandTools(button:)), for: .touchUpInside)

    self.sketchView.sketchViewDelegate = self
    self.addClearButton()

    self.addSaveButton()
  }

  func drawGrid(lineWidth: CGFloat, gap: CGFloat, color: UIColor) {

    let originalImage = UIImage()
    let widthOfImage = self.backgroundImage.bounds.width
    let heightOfImage = self.backgroundImage.bounds.height
    UIGraphicsBeginImageContext(self.backgroundImage.bounds.size)

    // Pass 1: Draw the original image as the background
    originalImage.draw(at: CGPoint.zero)

    // Pass 2: Draw the line on top of original image
    let context = UIGraphicsGetCurrentContext()!
    context.setLineWidth(lineWidth)

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

    context.setStrokeColor(color.cgColor)
    context.strokePath()

    // Create new image
    if let image = UIGraphicsGetImageFromCurrentImageContext() {
      self.backgroundImage.image = image
    }

    // Tidy up
    UIGraphicsEndImageContext();
  }

  func addSaveButton() {
    let saveBarButton = UIBarButtonItem(title: "Save", style: .done, target: self, action:  #selector(self.saveImage))
    self.navigationItem.rightBarButtonItem  = saveBarButton
  }

  @objc func saveImage() {

    if let image = self.sketchView.getEditedImage() {

      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      if let controller = storyboard.instantiateViewController(withIdentifier: "imageViewerController") as? ImageViewerController {
        controller.image = image
        self.navigationController?.pushViewController(controller, animated: true)
      }
      
    }
  }

  func addClearButton() {

    let clearBarButton = UIBarButtonItem(title: "Clear All", style: .done, target: self, action: #selector(self.clearAll))

    let saveBarButton = UIBarButtonItem(title: "Save", style: .done, target: self, action:  #selector(self.saveImage))

    let barButtons: Array = [clearBarButton, saveBarButton]

    self.navigationItem.leftBarButtonItems = barButtons
  }

  func addDoneBarButton() {

    let doneBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action:  #selector(self.drawImage))
    self.navigationItem.rightBarButtonItem  = doneBarButton
  }

  func removeDoneBarButton() {
    self.navigationItem.rightBarButtonItem  = nil
  }

  func showShapePalatte(view: UIView) {

    let height: CGFloat = 250
    let shapeView: ShapePickerPalatte = ShapePickerPalatte.fromNib()
    shapeView.delegate = self

    self.showActionSheet(forView: shapeView, sourceView: view, withTitle: "Shape Tools", customViewHeight: height)
  }

  func showColorPicker(forView view: UIView) {

    let colorSelectionController = EFColorSelectionViewController()
    colorSelectionController.delegate = self
    colorSelectionController.color = self.view.backgroundColor ?? UIColor.white

    if UIUserInterfaceSizeClass.compact == self.traitCollection.horizontalSizeClass {

      let navCtrl = UINavigationController(rootViewController: colorSelectionController)
      navCtrl.navigationBar.backgroundColor = UIColor.white
      navCtrl.navigationBar.isTranslucent = false
      navCtrl.modalPresentationStyle = UIModalPresentationStyle.popover
      navCtrl.popoverPresentationController?.delegate = self
      navCtrl.popoverPresentationController?.sourceView = view
      navCtrl.popoverPresentationController?.sourceRect = view.bounds
      navCtrl.preferredContentSize = colorSelectionController.view.systemLayoutSizeFitting(
        UILayoutFittingCompressedSize
      )

      let doneBtn: UIBarButtonItem = UIBarButtonItem(
        title: NSLocalizedString("Done", comment: ""),
        style: UIBarButtonItemStyle.done,
        target: self,
        action: #selector(dismissColorPicker(_:))
      )
      colorSelectionController.navigationItem.rightBarButtonItem = doneBtn

      self.present(navCtrl, animated: true, completion: nil)
    } else {
      colorSelectionController.modalPresentationStyle = UIModalPresentationStyle.popover
      colorSelectionController.popoverPresentationController?.delegate = self
      colorSelectionController.popoverPresentationController?.sourceView = view
      colorSelectionController.popoverPresentationController?.sourceRect = view.bounds
      colorSelectionController.preferredContentSize = colorSelectionController.view.systemLayoutSizeFitting(
        UILayoutFittingCompressedSize
      )

      self.present(colorSelectionController, animated: true, completion: nil)
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

    let height: CGFloat = 60
    let tipView: SliderView = SliderView.fromNib()
    tipView.lblSlider.text = "Tip Size: \(Int(self.tipSize))"
    tipView.slider.setValue(Float(self.tipSize), animated: true)
    tipView.slider.tag = 1
    tipView.slider.addTarget(self, action: #selector(self.sliderValueChanged(_:_:)), for: UIControlEvents.valueChanged)

    self.tipSizeSlider = tipView

    self.showActionSheet(forView: tipView, sourceView: view, withTitle: "Pen - Size", customViewHeight: height)
  }

  func showOpacityView(view: UIView) {

    let height: CGFloat = 60
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

    alertController.view.addSubview(view)

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

  func setUpEmptyView(rect: CGRect) {

    if self.emptyView != nil {

      self.emptyView?.frame = CGRect(x: rect.origin.x + 30, y: rect.origin.y + 30, width: 0, height: 0)
    } else {
      self.emptyView = UIView(frame: CGRect(x: rect.origin.x + 30, y: rect.origin.y + 30, width: 0, height: 0))
      self.view.addSubview(self.emptyView!)
    }
  }

  // MARK: - Action Methods
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
    self.removeDoneBarButton()
  }

  @IBAction func gridBtnTapped(_ sender: UIButton) {

    self.showGridColorPicker(sourceView: sender)
  }

  func showGridColorPicker(sourceView: UIView) {

    let alertController = UIAlertController(title: "Pick Report", message: nil, preferredStyle: .actionSheet)

    let height: CGFloat = 550
    let view: GridView = GridView.fromNib()
    view.sliderLineThickness.setValue(Float(self.lineThickness), animated: true)
    view.sliderGapSpace.setValue(Float(self.lineGap), animated: true)
    view.delegate = self

    ViewEmbedder.embed(
      withIdentifier: "MyVC", // Storyboard ID
      parent: alertController,
      container: view.colorPalatteView,
      defaultColor: self.lineColor) { (vc) in
        // do things when embed complete
        print("Embedding completed")
    }

    alertController.view.addSubview(view)

    view.translatesAutoresizingMaskIntoConstraints = false
    view.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 45).isActive = true
    view.rightAnchor.constraint(equalTo: alertController.view.rightAnchor, constant: -10).isActive = true
    view.leftAnchor.constraint(equalTo: alertController.view.leftAnchor, constant: 10).isActive = true
    view.heightAnchor.constraint(equalToConstant: height).isActive = true

    alertController.view.translatesAutoresizingMaskIntoConstraints = false

    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in

      print("Cancel tapped.")
    }))

    alertController.view.layoutSubviews()

    // Show Action sheet according to device
    if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
      if let presenter = alertController.popoverPresentationController {
        presenter.sourceView = sourceView
        presenter.sourceRect = sourceView.bounds
      }

      alertController.view.heightAnchor.constraint(equalToConstant: height + 55).isActive = true

      present(alertController, animated: true, completion: nil)

    } else {
      alertController.view.heightAnchor.constraint(equalToConstant: height + 120).isActive = true
      present(alertController, animated: true, completion: nil)
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
  func selectedTemplate(template: TemplateImage) {

    self.backgroundImage.image = template.originalImage

    if self.templateView.btnExpandTemplate.isSelected {
      self.templateView.btnExpandTemplate.sendActions(for: .touchUpInside)
    } else if self.toolsPalatteView.btnExpandTools.isSelected {
      self.toolsPalatteView.btnExpandTools.sendActions(for: .touchUpInside)
    }
  }
}

// MARK: - Tools palatte
extension CanvasViewController: ToolsPalatteDelegate {
  func selectedTool(rect: CGRect, tool: ToolIcon) {

    let rect = self.toolsPalatteView.convert(rect, to: self.view)
    self.setUpEmptyView(rect: rect)

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
      self.showImagePickOptions(sourceView: self.emptyView!)
    } else if tool == .clipArt {
//      self.sketchView.drawTool = .stamp
//      self.showImagePickOptions(sourceView: self.emptyView!)
      self.toolsPalatteView.btnExpandTools.sendActions(for: .touchUpInside)
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
    self.setUpEmptyView(rect: rect)

    if barButton.object == .penTip {

      self.sketchView.drawTool = .pen
      self.showTipSizeView(view: self.emptyView!)
    } else if barButton.object == .opacity {

      self.sketchView.drawTool = .pen
      self.showOpacityView(view: self.emptyView!)
    } else if barButton.object == .undo {
      self.sketchView.undo()
    } else if barButton.object == .redo {
      self.sketchView.redo()
    } else if barButton.object == .eraser {

      self.sketchView.drawTool = .eraser
      self.toolbarView.eraserSelected = true
      self.toolbarView.collectionView.reloadData()
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
        self.dismiss(animated: true, completion: nil)
        break
      // handle drag ended
      default:
        break
      }
    }

    if sender.tag == 1 {
      self.tipSizeSlider?.lblSlider.text = "Tip Size: \(Int(sender.value))"
      self.tipSize = CGFloat(sender.value)
    } else if sender.tag == 2 {
      self.opacitySlider?.lblSlider.text = "Opacity: \(String(format: "%.1f", sender.value))"
      self.tipOpacity = CGFloat(sender.value)
    }

  }
}

// MARK: - SketchView Delegates
extension CanvasViewController: SketchViewDelegate {

  func drawView(_ view: SketchView, willBeginDrawUsingTool tool: Any?) {

    self.dismiss(animated: true, completion: nil)

    if self.templateView.btnExpandTemplate.isSelected {
      self.templateView.btnExpandTemplate.sendActions(for: .touchUpInside)
    } else if self.toolsPalatteView.btnExpandTools.isSelected {
      self.toolsPalatteView.btnExpandTools.sendActions(for: .touchUpInside)
    }
  }

  func drawToolChanged(selectedTool: Any?) {

    if let tool = selectedTool as? SketchToolType {
      self.toolbarView.selectedTool = tool
      self.removeDoneBarButton()
      self.toolbarView.setToolBar()
    }
    if let tool = selectedTool as? SketchToolType, tool != .eraser {
      self.toolbarView.eraserSelected = false
      self.toolbarView.collectionView.reloadData()
    }
    if let tool = selectedTool as? SketchToolType, tool == .select {

      self.addDoneBarButton()
    }
  }
}

// MARK: - ColorSelection Delegates
extension CanvasViewController: UIPopoverPresentationControllerDelegate, EFColorSelectionViewControllerDelegate {
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
      let pickedImage = pickedImage.fixOrientation()
      self.sketchView.currentSelectedImage = pickedImage
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
  func gridValueChanged(lineThickness: CGFloat, gapSize: CGFloat, lineColor: UIColor) {
    self.lineThickness = lineThickness
    self.lineGap = gapSize
    self.lineColor = lineColor
    self.drawGrid(lineWidth: lineThickness, gap: gapSize, color: lineColor)
  }
}

//MARK: - Camera image picker
extension CanvasViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {

      self.sketchView.currentSelectedImage = pickedImage.fixOrientation()
//      self.sketchView.stampImage = pickedImage.fixOrientation()
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
