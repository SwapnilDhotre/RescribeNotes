//
//  ShapePickerPalatte.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 07/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

protocol ShapeDelegate {

  func selectedTool(tool: SketchToolType)
}

struct ShapeTool {

  var img: UIImage
  var title: String
  var tool: SketchToolType
}

class ShapePickerPalatte: UIView {

  var tools: [ShapeTool] = []
  var delegate: ShapeDelegate?
  @IBOutlet var collectionView: UICollectionView!

  override func awakeFromNib() {
    super.awakeFromNib()

    self.tools = [
      ShapeTool(img: #imageLiteral(resourceName: "line.png"), title: "Line", tool: .line),
      ShapeTool(img: #imageLiteral(resourceName: "arrow.png"), title: "Arrow", tool: .arrow),
      ShapeTool(img: #imageLiteral(resourceName: "ellipse.png"), title: "Ellipse", tool: .ellipseStroke),
      ShapeTool(img: #imageLiteral(resourceName: "ellipseFilled.png"), title: "Ellipse Filled", tool: .ellipseFill),
      ShapeTool(img: #imageLiteral(resourceName: "rectangle.png"), title: "Rectangle", tool: .rectangleStroke),
      ShapeTool(img: #imageLiteral(resourceName: "rectangleFilled.png"), title: "Rectangle Filled", tool: .rectangleFill)
    ]

    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.collectionView.register(UINib(nibName: "ShapeToolCell", bundle: nil), forCellWithReuseIdentifier: "shapeToolCell")
  }
}

extension ShapePickerPalatte: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

    return self.tools.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell: ShapeToolCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "shapeToolCell", for: indexPath) as! ShapeToolCell

    cell.imgIcon.image = self.tools[indexPath.row].img

    return cell
  }
}

extension ShapePickerPalatte: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    if let delegate = self.delegate {
      delegate.selectedTool(tool: self.tools[indexPath.row].tool)
    }
  }
}

extension ShapePickerPalatte: UICollectionViewDelegateFlowLayout {
  func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {

    let cellSize = (collectionView.bounds.width - 5) / 3

    return CGSize(width: cellSize, height: cellSize)
  }
}

