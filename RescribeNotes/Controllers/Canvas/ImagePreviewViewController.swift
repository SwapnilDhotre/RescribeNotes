//
//  ImagePreviewViewController.swift
//  RescribeDoctor
//
//  Created by Swapnil Dhotre on 27/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

class ImagePreviewViewController: UIViewController {

  var imageToUpload: UIImage?
  var cachedNavigation: UINavigationController?

  @IBOutlet var btnUpload: UIButton!
  @IBOutlet var btnCancel: UIButton!
  @IBOutlet var previewImageView: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()

    if let image = self.imageToUpload {
      self.previewImageView.image = image
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func btnUploadTapped(_ sender: UIButton) {

    self.showProgress(status: "Savings...")
    UIImageWriteToSavedPhotosAlbum(self.imageToUpload!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
  }

  @objc func uploadCompleted() {
    self.hideProgress()
  }

  @IBAction func btnCancelTapped(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }

  //MARK: - Add image to Library
  @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    self.hideProgress()
    if let error = error {

      self.showAlert(title: "Saving error", message: error.localizedDescription) {
        self.dismiss(animated: true, completion: nil)
      }
    } else {
      self.showAlert(message: "Image saved successfully in Photos/Gallery.") {

        DispatchQueue.main.async {
          self.cachedNavigation?.popViewController(animated: false)
          self.dismiss(animated: true, completion: nil)
        }
      }
    }
  }
}
