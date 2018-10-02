//
//  ClipArtView.swift
//  RescribeDoctor
//
//  Created by Swapnil Dhotre on 27/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

protocol ClipArtDelegate {

  func clipArtSelected(obj: ClipArt)
}

typealias ClipArt = (url: String, canBeColored: Bool)

class ClipArtView: UIView {

  var delegate: ClipArtDelegate?
  var clipArts: [ClipArt] = []
  @IBOutlet var collectionView: UICollectionView!

  override func awakeFromNib() {
    super.awakeFromNib()

    self.clipArts = [
      ("circleOutline.png", true),
      ("ellipseOutline.png", true),
      ("favoriteOutline.png", true),
      ("intravenousOutline.png", true),
      ("plain_triangle.png", true),
      ("speechBubble.png", true),
      ("squareShape.png", true),
      ("starFilled.png", true),
      ("starOutline.png", true),
      ("stethoscope.png", true),
      ("syringe.png", true),
      ("syrup.png", true),
      ("ayurvedic.png", false),
      ("Bandage_Strip.png", false),
      ("brain.png", false),
      ("coffee_cup.png", true),
      ("heart.png", false),
      ("intestine.png", false),
      ("liver.png", false),
      ("lung.png", false),
      ("lungs.png", false),
      ("new.png", false),
      ("nurse.png", false),
      ("stomach.png", false)
    ]

    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.collectionView.register(UINib(nibName: "ClipArtCell", bundle: nil), forCellWithReuseIdentifier: "clipArtCell")
  }
}

extension ClipArtView: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.clipArts.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell: ClipArtCell = collectionView.dequeueReusableCell(withReuseIdentifier: "clipArtCell", for: indexPath) as! ClipArtCell

    cell.imgView.image = UIImage(named: self.clipArts[indexPath.row].url)
    return cell
  }
}

extension ClipArtView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    self.delegate?.clipArtSelected(obj: self.clipArts[indexPath.row])
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

    let width = (collectionView.frame.width - 10) / 3
    return CGSize(width: width, height: width)
  }
}

