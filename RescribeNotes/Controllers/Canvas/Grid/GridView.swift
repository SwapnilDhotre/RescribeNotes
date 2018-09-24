//
//  GridView.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 21/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

protocol GridManipulation {

  func gridValueChanged(lineThickness: CGFloat, gapSize: CGFloat, lineColor: UIColor)
}

class GridView: UIView {

  var delegate: GridManipulation?
  var tipColor: UIColor = .white

  var lineThickness: CGFloat = 0.5
  var lineGap: CGFloat = 20
  var lineColor: UIColor = .red

  @IBOutlet var lblGridLineThickness: UILabel!
  @IBOutlet var lblGapSpace: UILabel!

  @IBOutlet var sliderLineThickness: UISlider!
  @IBOutlet var sliderGapSpace: UISlider!
  

  @IBOutlet var colorPalatteView: UIView!

  override func awakeFromNib() {
    super.awakeFromNib()

    self.lblGapSpace.text = "Gap Space"
    self.lblGridLineThickness.text = "Line Thickness"

    self.sliderLineThickness.setValue(Float(self.lineThickness), animated: true)
    self.sliderGapSpace.setValue(Float(self.lineGap), animated: true)

    self.sliderLineThickness.minimumValue = 0.5
    self.sliderLineThickness.maximumValue = 3.0

    self.sliderGapSpace.minimumValue = 10
    self.sliderGapSpace.maximumValue = 60

    self.sliderLineThickness.tag = 10
    self.sliderGapSpace.tag = 11
  }

  override func layoutSubviews() {
    super.layoutSubviews()
  }

  @IBAction func sliderValueChanged(_ sender: UISlider) {

    if sender.tag == 10 {
      self.lineThickness = CGFloat(sender.value)
    } else if sender.tag == 11 {
      self.lineGap = CGFloat(Int(sender.value))
    }

    self.delegate?.gridValueChanged(lineThickness: self.lineThickness, gapSize: self.lineGap, lineColor: self.lineColor)
  }
}

// MARK: - ColorSelection Delegates
extension GridView: EFColorSelectionViewControllerDelegate {
  func colorViewController(colorViewCntroller: EFColorSelectionViewController, didChangeColor color: UIColor) {

    self.lineColor = color
    self.delegate?.gridValueChanged(lineThickness: self.lineThickness, gapSize: self.lineGap, lineColor: self.lineColor)
  }
}
