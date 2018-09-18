//
//  UIFontExtension.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 11/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

enum FontStyle: String {
  case fontBold = "Roboto-Bold"
  case fontMedium = "Roboto-Medium"
  case fontRegular = "Roboto-Regular"
  case fontLight = "Roboto-Light"
}

extension UIFont {

  func font(withStyle style: FontStyle, size: Int) -> UIFont {
    return UIFont(name: style.rawValue, size: CGFloat(size))!
  }

  func fontIcon(withSize size: Int) -> UIFont {
    return UIFont(name: "MyRescribe", size: CGFloat(size))!
  }
}
