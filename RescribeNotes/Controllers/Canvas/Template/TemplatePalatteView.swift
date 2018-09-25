//
//  TemplatePalatteView.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 06/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

protocol TemplatePalatteDelegate {

  func selectedTemplate(template: TemplateImage)
}

enum TemplateImage: String {
  case grid = "grid1"
  case crossGrid = "crossGrid"
  case graphPaper = "graphPaper"
  case peyoteGrid = "peyote"
  case vertical = "vertical"

  var thumbIcon: UIImage {
    return UIImage(named: "\(self.rawValue)Thumb.png")!
  }

  var originalImage: UIImage {
    return UIImage(named: "\(self.rawValue).png")!
  }
}

class TemplatePalatteView: NibView {

  var templates: [TemplateImage] = []

  var templateDelegate: TemplatePalatteDelegate?

  @IBOutlet var labelTitle: UILabel!
  @IBOutlet var btnExpandTemplate: UIButton!
  @IBOutlet var visualEffect: UIView!
  @IBOutlet var selectedTemplateImage: UIImageView!
  @IBOutlet var templatesCollectionView: UICollectionView!

  @IBOutlet var defaultImageContainer: UIView!
  @IBOutlet var lblDefaultTitle: UILabel!
  

  override func awakeFromNib() {

    super.awakeFromNib()

    self.templates = [
      TemplateImage.grid,
      TemplateImage.crossGrid,
      TemplateImage.graphPaper,
      TemplateImage.peyoteGrid,
      TemplateImage.vertical
    ]

    self.setUIAppearance()

    self.templatesCollectionView.dataSource = self
    self.templatesCollectionView.delegate = self
    self.templatesCollectionView.register(UINib(nibName: "TemplateCell", bundle: nil), forCellWithReuseIdentifier: "templateCell")
  }

  func setUIAppearance() {

    self.templatesCollectionView.backgroundColor = UIColor.clear
    self.templatesCollectionView.backgroundView = UIView(frame: CGRect.zero)

    self.labelTitle.roundCorners(corners: [.topRight], radius: 10)

    // Set Expand button images
    self.btnExpandTemplate.setImage(#imageLiteral(resourceName: "arrowLeft.png").maskWithColor(color: #colorLiteral(red: 0.01568627451, green: 0.6823529412, blue: 0.8941176471, alpha: 1)), for: .selected)
    self.btnExpandTemplate.setImage(#imageLiteral(resourceName: "arrowRight.png").maskWithColor(color: #colorLiteral(red: 0.01568627451, green: 0.6823529412, blue: 0.8941176471, alpha: 1)), for: .normal)

    self.layoutSubviews()
    self.selectedTemplateImage.image = #imageLiteral(resourceName: "grid1Thumb.png")
    self.selectedTemplateImage.cornerRadius = 10
    self.selectedTemplateImage.masksToBounds = true
    self.defaultImageContainer.layer.cornerRadius = 5.0
    self.defaultImageContainer.layer.borderWidth = 1.5
    self.defaultImageContainer.layer.borderColor = UIColor.white.cgColor
    self.defaultImageContainer.layer.masksToBounds = false

    let cornerRadius: CGFloat = 7
    let shadowOffsetWidth: Int = 0
    let shadowOffsetHeight: Int = 1
    let shadowOpacity: Float = 0.7

    self.defaultImageContainer.layer.shadowPath = UIBezierPath(roundedRect: self.defaultImageContainer.bounds, cornerRadius: cornerRadius).cgPath
    self.defaultImageContainer.layer.cornerRadius = cornerRadius
    self.defaultImageContainer.layer.masksToBounds = false
    self.defaultImageContainer.layer.shadowColor = UIColor.gray.cgColor
    self.defaultImageContainer.layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
    self.defaultImageContainer.layer.shadowOpacity = shadowOpacity
  }

  // MARK: - Action Methods
  @IBAction func defaultTemplatetapped(_ sender: UIButton) {
    self.templateDelegate?.selectedTemplate(template: .grid)
  }
}

extension TemplatePalatteView: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

    return self.templates.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell: TemplateCell = self.templatesCollectionView.dequeueReusableCell(withReuseIdentifier: "templateCell", for: indexPath) as! TemplateCell

    cell.templateImage.image = templates[indexPath.row].thumbIcon
    cell.templateName.text = templates[indexPath.row].rawValue.capitalized

    //This creates the shadows and modifies the cards a little bit
    cell.templateImage.layer.cornerRadius = 10.0
    cell.contentView.layer.cornerRadius = 5.0
    cell.contentView.layer.borderWidth = 1.5
    cell.contentView.layer.borderColor = UIColor.white.cgColor
    cell.contentView.layer.masksToBounds = false
    cell.contentView.backgroundColor = UIColor.white

    let cornerRadius: CGFloat = 7
    let shadowOffsetWidth: Int = 0
    let shadowOffsetHeight: Int = 1
    let shadowOpacity: Float = 0.7

    cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cornerRadius).cgPath
    cell.layer.cornerRadius = cornerRadius
    cell.layer.masksToBounds = false
    cell.layer.shadowColor = UIColor.gray.cgColor
    cell.layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
    cell.layer.shadowOpacity = shadowOpacity

    return cell
  }
}

extension TemplatePalatteView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    if let delegate = self.templateDelegate {
      delegate.selectedTemplate(template: self.templates[indexPath.row])
    }
  }
}

extension TemplatePalatteView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {

    let cellWidth: Double = Double((collectionView.bounds.width - 50) / (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? 3 : 2))

    return CGSize(width: cellWidth, height: (cellWidth / 0.70))// makes 3:4 ratio height
  }
}
