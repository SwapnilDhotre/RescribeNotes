//
//  ViewEmbedder.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 21/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

class ViewEmbedder {
  class func embed(
    parent:UIViewController,
    container:UIView,
    child:UIViewController,
    previous:UIViewController?){

    if let previous = previous {
      removeFromParent(vc: previous)
    }
    child.willMove(toParentViewController: parent)
    parent.addChildViewController(child)
    container.addSubview(child.view)
    child.didMove(toParentViewController: parent)

    child.view.translatesAutoresizingMaskIntoConstraints = false
    child.view.topAnchor.constraint(equalTo: container.topAnchor, constant: 5).isActive = true
    child.view.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 5).isActive = true
    child.view.rightAnchor.constraint(equalTo: container.rightAnchor, constant: 5).isActive = true
    child.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 5).isActive = true

//    let w = container.frame.size.width - 20;
//    let h = container.frame.size.height;
//    child.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
  }

  class func removeFromParent(vc:UIViewController){
    vc.willMove(toParentViewController: nil)
    vc.view.removeFromSuperview()
    vc.removeFromParentViewController()
  }

  class func embed(withIdentifier id: String, parent: UIViewController, container: UIView, defaultColor: UIColor, completion:((UIViewController)->Void)? = nil){
//    let vc = parent.storyboard!.instantiateViewController(withIdentifier: id)

    let colorSelectionController = EFColorSelectionViewController()
    colorSelectionController.delegate = (container.superview as! GridView)
    colorSelectionController.color = defaultColor
    colorSelectionController.preferredContentSize = colorSelectionController.view.systemLayoutSizeFitting(
      UILayoutFittingCompressedSize
    )

    embed(
      parent: parent,
      container: container,
      child: colorSelectionController,
      previous: parent.childViewControllers.first
    )
    completion?(colorSelectionController)
  }
}
