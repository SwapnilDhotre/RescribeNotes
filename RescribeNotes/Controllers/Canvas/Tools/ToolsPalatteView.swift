//
//  ObjectsPalatteView.swift
//  RescribeNotes
//
//  Created by Swapnil Dhotre on 07/09/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

struct Tool {
  var title: String
  var tool: ToolIcon
}

protocol ToolsPalatteDelegate {

  func selectedTool(rect: CGRect, tool: ToolIcon)
}

enum ToolIcon: String {
  case clipArt = "clipArt"
  case imageTool = "imageTool"
  case shapeTool = "shapeTool"
  case paintBrush = "paintBrush"
  case pencilTool = "pencilTool"
  case textTool = "textTool"

  var icon: UIImage {

    return UIImage(named: self.rawValue)!
  }
}

class ToolsPalatteView: NibView {

  var tools: [Tool] = []

  var toolDelegate: ToolsPalatteDelegate?

  @IBOutlet var visualEffect: UIView!
  @IBOutlet var btnExpandTools: UIButton!
  @IBOutlet var collectionView: UICollectionView!

  var lastSelectedTool: ToolIcon? = nil

  override func awakeFromNib() {
    super.awakeFromNib()

    self.tools = [

      Tool(title: "Brush", tool: .paintBrush),
      Tool(title: "Pencil", tool: .pencilTool),
      Tool(title: "Text", tool: .textTool),
      Tool(title: "Shape", tool: .shapeTool),
      Tool(title: "Clipart", tool: .clipArt),
      Tool(title: "Image", tool: .imageTool)
    ]

    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.collectionView.register(UINib(nibName: "ToolCell", bundle: nil), forCellWithReuseIdentifier: "toolCell")

    self.setUIAppearance()
  }

  func setUIAppearance() {

    self.collectionView.backgroundColor = UIColor.clear
    self.collectionView.backgroundView = UIView(frame: CGRect.zero)

    // Set Expand button images
    self.btnExpandTools.setImage(#imageLiteral(resourceName: "arrowLeft.png").maskWithColor(color: #colorLiteral(red: 0.01568627451, green: 0.6823529412, blue: 0.8941176471, alpha: 1)), for: .normal)
    self.btnExpandTools.setImage(#imageLiteral(resourceName: "arrowRight.png").maskWithColor(color: #colorLiteral(red: 0.01568627451, green: 0.6823529412, blue: 0.8941176471, alpha: 1)), for: .selected)
  }
}

extension ToolsPalatteView: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

    return self.tools.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell: ToolCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "toolCell", for: indexPath) as! ToolCell

    cell.toolIcon.image = self.tools[indexPath.row].tool.icon
    cell.toolTitle.text = self.tools[indexPath.row].title
    if (self.tools.count - 1) == indexPath.row {
      cell.customLine.isHidden = true
    } else {
      cell.customLine.isHidden = false
    }

    if let lastTool = lastSelectedTool, lastTool == self.tools[indexPath.row].tool {
      cell.backgroundColor = .black
    } else {
      cell.backgroundColor = UIColor(hexString: "#33363B")
    }

    return cell
  }
}

extension ToolsPalatteView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    let attributes = collectionView.layoutAttributesForItem(at: indexPath)
    let frame = attributes?.frame

    if let delegate = self.toolDelegate, let rect = frame {
      delegate.selectedTool(rect: rect, tool: self.tools[indexPath.row].tool)
    }
    self.lastSelectedTool = self.tools[indexPath.row].tool
    self.collectionView.reloadData()
  }
}

extension ToolsPalatteView: UICollectionViewDelegateFlowLayout {
  func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {

    let cellSize = collectionView.bounds.width

    return CGSize(width: cellSize, height: cellSize + 10)
  }
}
