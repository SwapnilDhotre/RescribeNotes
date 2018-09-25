//
//  ImageViewerController.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 24/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

class ImageViewerController: UIViewController {

  var image: UIImage?
  @IBOutlet var completeImage: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()

  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if (self.image != nil) {
      self.completeImage.image = self.image!
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  
}
