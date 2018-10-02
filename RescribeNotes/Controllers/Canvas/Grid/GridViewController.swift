//
//  GridViewController.swift
//  RescribeDoctor
//
//  Created by Swapnil Dhotre on 26/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

enum LinesDrawn: Int {
  case vertical = 0
  case horizontal = 1
  case both = 2
}

protocol GridManipulation {

  func gridValueChanged(linesDrawn: LinesDrawn, lineThickness: CGFloat, gapSize: CGFloat, lineColor: UIColor)
  func tipColorChanged(lineColor: UIColor)
  func shouldShowGrid(shouldShowGrid: Bool)
}

class GridViewController: UIViewController {
  
  var delegate: GridManipulation?
  var isTipColorPicker: Bool = false
  
  var lineThickness: CGFloat = 0.5
  var lineGap: CGFloat = 20
  var lineColor: UIColor = .red
  var selectedSegment: LinesDrawn = .horizontal

  @IBOutlet var colorCollectionTopConstraint: NSLayoutConstraint!
  @IBOutlet var lblGridLineThickness: UILabel!
  @IBOutlet var lblGapSpace: UILabel!
  @IBOutlet var lblGridLines: UILabel!
  
  @IBOutlet var btnIsGridVisible: UISwitch!
  @IBOutlet var sliderLineThickness: UISlider!
  @IBOutlet var sliderGapSpace: UISlider!
  @IBOutlet var linesSegment: UISegmentedControl!
  
  @IBOutlet var colorPalatteView: UIView!
  @IBOutlet var defaultColorHeightConstraint: NSLayoutConstraint!
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var contentScrollView: UIScrollView!
  
  var isGridVisible: Bool = false

  var colors: [String] = ["ffffff", "ffffff", "000000", "14a763", "d4bfa4"]
  
  override func viewDidLoad() {
    super.viewDidLoad()

    self.title = "Grid"

    if let color = Utility.getUserLocalObjectForKey(key: Constants.UserDefault.lastColorSelected) as? String {

      self.colors[0] = color
    }

    if UIUserInterfaceSizeClass.compact != self.traitCollection.horizontalSizeClass {
      self.navigationController?.navigationBar.isHidden = true
      self.contentScrollView.isScrollEnabled = false
    }

    self.lblGridLines.text = "Lines"
    self.lblGapSpace.text = "Gap Space"
    self.lblGridLineThickness.text = "Thickness"

    self.sliderLineThickness.minimumValue = 0.5
    self.sliderLineThickness.maximumValue = 3.0

    self.sliderGapSpace.minimumValue = 10
    self.sliderGapSpace.maximumValue = 100

    self.sliderLineThickness.tag = 10
    self.sliderGapSpace.tag = 11

    self.collectionView.register(UINib(nibName: "GridColorCell", bundle: nil), forCellWithReuseIdentifier: "gridCell")
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    ViewEmbedder.embed(
      withIdentifier: "MyVC", // Storyboard ID
      parent: self,
      container: self.colorPalatteView,
      defaultColor: self.lineColor) { (vc) in
        // do things when embed complete
        print("Embedding completed")
    }

    self.setValues()
  }

  func setValues() {

    if self.isTipColorPicker {
      self.lblGapSpace.isHidden = true
      self.lblGridLineThickness.isHidden = true
      self.lblGridLines.isHidden = true
      self.sliderGapSpace.isHidden = true
      self.sliderLineThickness.isHidden = true
      self.linesSegment.isHidden = true
      self.colorCollectionTopConstraint.priority = UILayoutPriority(rawValue: 400)
    }

    if self.selectedSegment == .horizontal {
      self.linesSegment.selectedSegmentIndex = 0
    } else if self.selectedSegment == .vertical {
      self.linesSegment.selectedSegmentIndex = 1
    } else if self.selectedSegment == .both {
      self.linesSegment.selectedSegmentIndex = 2
    }

    self.sliderLineThickness.setValue(Float(self.lineThickness), animated: true)
    self.sliderGapSpace.setValue(Float(self.lineGap), animated: true)
    self.btnIsGridVisible.setOn(self.isGridVisible, animated: true)
  }

  // MARK: - Action Events
  @IBAction func isVisibleTapped(_ sender: UISwitch) {

    self.delegate?.shouldShowGrid(shouldShowGrid: sender.isOn)
  }

  @IBAction func segmentChanged(_ sender: UISegmentedControl) {

    if sender.selectedSegmentIndex == 0 {
      self.selectedSegment = .horizontal
    } else if sender.selectedSegmentIndex == 1 {
      self.selectedSegment = .vertical
    } else if sender.selectedSegmentIndex == 2 {
      self.selectedSegment = .both
    }

    self.btnIsGridVisible.setOn(true, animated: true)
    self.delegate?.gridValueChanged(linesDrawn: self.selectedSegment, lineThickness: self.lineThickness, gapSize: self.lineGap, lineColor: self.lineColor)
  }

  @IBAction func sliderValueChanged(_ sender: UISlider) {

    if sender.tag == 10 {
      self.lineThickness = CGFloat(sender.value)
    } else if sender.tag == 11 {
      self.lineGap = CGFloat(Int(sender.value))
    }

    self.btnIsGridVisible.setOn(true, animated: true)
    self.delegate?.gridValueChanged(linesDrawn: self.selectedSegment, lineThickness: self.lineThickness, gapSize: self.lineGap, lineColor: self.lineColor)
  }
}

extension GridViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

    return self.colors.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell: GridColorCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath) as! GridColorCell

    cell.colorView.borderColor = UIColor(hexString: "f5f5f5")
    cell.colorView.borderWidth = 1
    cell.colorView.backgroundColor = UIColor(hexString: self.colors[indexPath.row])
    cell.colorView.cornerRadius = 4

    return cell
  }
}

extension GridViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print("Color selected")

    self.lineColor = UIColor(hexString: self.colors[indexPath.row])
    _ = Utility.setUserLocalObject(object: self.lineColor.toHex(), key: Constants.UserDefault.lastColorSelected)

    if self.isTipColorPicker {
      self.delegate?.tipColorChanged(lineColor: self.lineColor)
    } else {
      self.btnIsGridVisible.setOn(true, animated: true)
      self.delegate?.gridValueChanged(linesDrawn: self.selectedSegment, lineThickness: self.lineThickness, gapSize: self.lineGap, lineColor: self.lineColor)
    }
    self.dismiss(animated: true, completion: nil)
  }
}

extension GridViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

    let width = (collectionView.frame.width - 10) / 5
    self.defaultColorHeightConstraint.constant = (collectionView.frame.width - 10) / 5
    return CGSize(width: width, height: width)
  }
}

// MARK: - ColorSelection Delegates
extension GridViewController: EFColorSelectionViewControllerDelegate {
  func colorViewController(colorViewCntroller: EFColorSelectionViewController, didChangeColor color: UIColor) {

    self.lineColor = color
    _ = Utility.setUserLocalObject(object: self.lineColor.toHex(), key: Constants.UserDefault.lastColorSelected)

    if self.isTipColorPicker {
      self.delegate?.tipColorChanged(lineColor: self.lineColor)
    } else {
      self.btnIsGridVisible.setOn(true, animated: true)
      self.delegate?.gridValueChanged(linesDrawn: self.selectedSegment, lineThickness: self.lineThickness, gapSize: self.lineGap, lineColor: self.lineColor)
    }
  }
}

