//
//  UIViewController.swift
//  MyRescribe
//
//  Created by Hardik Jain on 30/05/17.
//  Copyright © 2017 Hardik Jain. All rights reserved.
//

import Foundation
import SVProgressHUD
import SwiftMessages
import UIKit

extension UIViewController {
  
  func showInternetNotAvailableMsg() {
    // how network not available messages
    let config = getMessageConfig()
    
    // Instantiate a message view from the provided card view layout. SwiftMessages searches for nib
    // files in the main bundle first, so you can easily copy them into your project and make changes.
    let view = MessageView.viewFromNib(layout: .messageView)
    
    // Theme message elements with the warning style.
    view.configureTheme(.warning)
    view.button?.isHidden = true
    
    // Add a drop shadow.
    view.configureDropShadow()
    
    // Set message title, body, and icon. Here, we're overriding the default warning
    // image with an emoji character.
    let iconText = "🤔" // ["🤔", "😳", "🙄", "😶"].sm_random()!
    view.configureContent(title: "Warning", body: "Internet seems not available.", iconText: iconText)
    
    SwiftMessages.show(config: config, view: view)
  }
  
  func getMessageConfig() -> SwiftMessages.Config {
    var config = SwiftMessages.Config()
    
    // Slide up from the bottom.
    config.presentationStyle = .top
    
    // Display in a window at the specified window level: UIWindowLevelStatusBar
    // displays over the status bar while UIWindowLevelNormal displays under.
    config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
    
    // Disable the default auto-hiding behavior.
    config.duration = .seconds(seconds: 2)
    
    // Dim the background like a popover view. Hide when the background is tapped.
    config.dimMode = .gray(interactive: true)
    
    // Disable the interactive pan-to-hide gesture.
    config.interactiveHide = true
    
    // Specify a status bar style to if the message is displayed directly under the status bar.
    config.preferredStatusBarStyle = .lightContent
    
    // Specify one or more event listeners to respond to show and hide events.
    config.eventListeners.append { event in
      if case .didHide = event {
        print("yep")
      }
    }
    
    return config
  }
  
  /// Return view controller initialized with class
  ///
  /// - Returns: return UIViewController type as parent
  class func fromNib<T: UIViewController>() -> T {
    return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
  }
  
  /// Show progress bar using ProgressHUD
  ///
  /// - Parameter status: progress message as status
  func showProgress(status: String) {
    // Set ProgressHUD mask type
    SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
    SVProgressHUD.show(withStatus: status)
  }
  
  /// Show progress bar with image and status
  ///
  /// - Parameters:
  ///   - image: Image for progress view
  ///   - status: Status for progress
  func showProgressWithImage(image: UIImage, status: String) {
    // VProgressHUD.setInfoImage(image)
    SVProgressHUD.setDefaultMaskType(.clear)
    SVProgressHUD.setInfoImage(image)
    SVProgressHUD.show(image, status: status)
  }
  
  /// Hide Progress bar
  func hideProgress() {
    SVProgressHUD.dismiss()
  }
  
  /// Show alert message popup with only message
  func showAlertWithTitleAndMessage(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func showAlert(message msg: String) {
    let alert = UIAlertController(title: Constants.appName, message: msg, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func showAlert(message msg: String, _ completion: @escaping () -> Void) {
    let alert = UIAlertController(title: Constants.appName, message: msg, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { _ in
      
      completion()
    }))
    present(alert, animated: true, completion: nil)
  }
  
  func showAlert(forCode code: Int) {
    var msg = ""
    switch code {
      
      // MARK: - App Click
    // WS Failure (Due to network)
    case -1001, -1002, -1003, -1004, -1005, -1009:
      msg = "Oops! Unable to connect to server. Please, check your internet setting and make sure internet connection works fine."
    default:
      msg = "Oops! Something went wrong! Please try again or contact customer care."
    }
    
    let alert = UIAlertController(title: Constants.appName, message: msg, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func showAlertWithCompletionHandler(message msg: String) {
    let alert = UIAlertController(title: Constants.appName, message: msg, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
      _ in
      self.dissmissCurrentViewController()
    }))
    present(alert, animated: true, completion: nil)
  }
  
  func dissmissCurrentViewController() {
    navigationController?.popViewController(animated: true)
  }
  
  func showAlertWithDismissingController(message msg: String) {
    let alert = UIAlertController(title: Constants.appName, message: msg, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
      _ in
      self.dismissingController()
    }))
    present(alert, animated: true, completion: nil)
  }
  
  @objc func dismissingController() {
    dismiss(animated: true, completion: nil)
  }
  
  /// Show alert message popup with title and message
  func showAlert(title: String, message msg: String, complition: (() -> Void)?) {

    let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
      _ in
      complition?()
    }))
    present(alert, animated: true, completion: nil)
  }

  func showAlert(title: String, message msg: String) {
    let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func showAlertMessageWithIndex(index _: Int) {
    let alert = UIAlertController(title: Constants.appName, message: "", preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  /// Check whether left side menu button is available or not.
  func hasLeftMenu() -> Bool {
    if let leftItem = self.navigationController?.navigationItem.leftBarButtonItem {
      if let btnMenu = leftItem.customView as? UIButton {
        if btnMenu.tag == 1001 {
          return true
        }
      }
    }
    return false
  }
}

// MARK: - Size classes

extension UIViewController {
  /// Size class which can be used to identify traits.
  ///
  /// - Returns: return traits
  func sizeClass() -> (UIUserInterfaceSizeClass, UIUserInterfaceSizeClass) {
    return (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass)
  }
}

// MARK: - Backbutton actions

extension UIViewController {
  /// Dismiss controller action is set here
  func backButtonAction() {
    dismiss(animated: true, completion: nil)
  }
  
  /// Pop controller from navigation
  @objc func popController() {
    navigationController?.popViewController(animated: true)
  }
  
  /// Add back button with arrow
  func addBackbutton() {
    let leftButton = UIButton(type: .system)
    leftButton.setTitle("n", for: .normal)
    leftButton.titleLabel?.font = UIFont().fontIcon(withSize: 17)
    leftButton.setTitleColor(.white, for: .normal)
    leftButton.frame = CGRect(x: 0, y: 0, width: 40.0, height: 40.0)
    leftButton.addTarget(self, action: #selector(popController), for: .touchUpInside)
    
    let leftBackBtn = UIBarButtonItem(customView: leftButton)
    
    navigationItem.leftBarButtonItem = leftBackBtn
  }
}
