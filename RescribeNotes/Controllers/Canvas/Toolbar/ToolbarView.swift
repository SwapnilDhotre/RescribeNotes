//
//  ToolbarView.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 10/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

protocol ToolbarDelegate {

  func toolbarTapped(forItem: ToolBarButton, rect: CGRect)
}

enum ToolbarIcon: String {
  case undo = "undoArrow"
  case redo = "redoArrow"
  case penTip = "penTip"
  case opacity = "opacity"
  case eraser = "eraser"
  case color = "colorSwatches"
  case font = "font"

  var icon: UIImage {
    return UIImage(named: self.rawValue)!
  }
}

struct ToolBarButton {
  var title: String
  var object: ToolbarIcon
}

class ToolbarView: NibView {

  var eraserSelected: Bool = false
  var delegate: ToolbarDelegate?
  @IBOutlet var collectionView: UICollectionView!

  var toolBar: [ToolBarButton] = []

  var selectedTool: SketchToolType = .pen

  override func awakeFromNib() {
    super.awakeFromNib()

    self.setToolBar()
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.collectionView.register(UINib(nibName: "ToolbarCell", bundle: nil), forCellWithReuseIdentifier: "toolBarCell")

    self.collectionView.backgroundColor = UIColor.clear
    self.collectionView.backgroundView = UIView(frame: CGRect.zero)

    //self.collectionView.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
//    self.collectionView.transform = CGAffineTransform.init(scaleX: -1, y: 1)
  }

  func setToolBar() {

    if self.selectedTool == .pen ||
      self.selectedTool == .arrow ||
      self.selectedTool == .ellipseFill ||
      self.selectedTool == .ellipseStroke ||
      self.selectedTool == .line ||
      self.selectedTool == .rectangleFill ||
      self.selectedTool == .rectangleStroke {
      self.toolBar = [
        ToolBarButton(title: "Undo", object: .undo),
        ToolBarButton(title: "Redo", object: .redo),
        ToolBarButton(title: "Eraser", object: .eraser),
        ToolBarButton(title: "Tip Size", object: .penTip),
        ToolBarButton(title: "Opacity", object: .opacity),
        ToolBarButton(title: "Color", object: .color)
      ]
    } else if self.selectedTool == .textTool {
      self.toolBar = [
        ToolBarButton(title: "Undo", object: .undo),
        ToolBarButton(title: "Redo", object: .redo),
        ToolBarButton(title: "Eraser", object: .eraser),
        ToolBarButton(title: "Color", object: .color)
//        ToolBarButton(title: "Font", object: .font)
      ]
    } else if self.selectedTool == .select {
      self.toolBar = [
        ToolBarButton(title: "Undo", object: .undo),
        ToolBarButton(title: "Redo", object: .redo)
      ]
    } else {
      self.toolBar = [
        ToolBarButton(title: "Undo", object: .undo),
        ToolBarButton(title: "Redo", object: .redo),
        ToolBarButton(title: "Eraser", object: .eraser)
      ]
    }

    self.collectionView.reloadData()
  }

  func showColorOption() {
    self.toolBar = [
      ToolBarButton(title: "Undo", object: .undo),
      ToolBarButton(title: "Redo", object: .redo),
      ToolBarButton(title: "Color", object: .color)
    ]
    self.collectionView.reloadData()
  }

}

extension ToolbarView: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

    return self.toolBar.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell: ToolBarCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "toolBarCell", for: indexPath) as! ToolBarCell

    if self.toolBar[indexPath.row].object == .eraser {

      if self.eraserSelected {
        cell.icon.image = self.toolBar[indexPath.row].object.icon.maskWithColor(color: #colorLiteral(red: 0.01568627451, green: 0.6823529412, blue: 0.8941176471, alpha: 1))
      } else {
        cell.icon.image = self.toolBar[indexPath.row].object.icon
      }
    } else {
      cell.icon.image = self.toolBar[indexPath.row].object.icon
    }

    return cell
  }
}

extension ToolbarView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    let attributes = collectionView.layoutAttributesForItem(at: indexPath)
    let frame = attributes?.frame

    if let delegate = self.delegate, let rect = frame {
      delegate.toolbarTapped(forItem: self.toolBar[indexPath.row], rect: rect)
    }
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

    return CGSize(width: 40, height: 40)
  }
}


