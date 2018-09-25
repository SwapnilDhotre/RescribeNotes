//
//  UIViewController.swift
//  MyRescribe
//
//  Created by Hardik Jain on 30/05/17.
//  Copyright © 2017 Hardik Jain. All rights reserved.
//

import UIKit

extension UIViewController {
  
  /// Show alert message popup with only message
  func showAlertWithTitleAndMessage(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func showAlert(message msg: String) {
    let alert = UIAlertController(title: "Rescribe Notes", message: msg, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func showAlert(message msg: String, _ completion: @escaping () -> Void) {
    let alert = UIAlertController(title: "Rescribe Notes", message: msg, preferredStyle: UIAlertControllerStyle.alert)
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
      msg = "Oops! Unable to connect to server. Please, check your internet settings and try again."
    default:
      msg = "Oops! Something went wrong! Please try again or contact customer care."
    }
    
    let alert = UIAlertController(title: "Rescribe Notes", message: msg, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func showAlertWithCompletionHandler(message msg: String) {
    let alert = UIAlertController(title: "Rescribe Notes", message: msg, preferredStyle: UIAlertControllerStyle.alert)
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
    let alert = UIAlertController(title: "Rescribe Notes", message: msg, preferredStyle: UIAlertControllerStyle.alert)
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
  func showAlert(title: String, message msg: String) {
    let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func showAlertMessageWithIndex(index _: Int) {
    let alert = UIAlertController(title: "Rescribe Notes", message: "", preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    present(alert, animated: true, completion: nil)
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
