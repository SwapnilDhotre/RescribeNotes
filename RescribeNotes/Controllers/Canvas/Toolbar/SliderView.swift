//
//  SliderView.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 10/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

class SliderView: UIView {

  @IBOutlet var lblSlider: UILabel!
  @IBOutlet var slider: UISlider!
  
  override func awakeFromNib() {
    super.awakeFromNib()

    self.slider.maximumValue = 25
    self.slider.minimumValue = 1
  }
}
