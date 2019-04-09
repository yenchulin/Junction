//
//  UICollectionViewX.swift
//  Junction
//
//  Created by 林晏竹 on 2018/3/19.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import UIKit
import os.log

class UICollectionViewX: UICollectionView {
    
    // Change collectionViewCell UI when selected/deselected
    func changeUI(for cell: UICollectionViewCell, selected: Bool) {
        switch cell {
        case is TagCollectionViewCell:
            let tagCell = cell as! TagCollectionViewCell
            if selected {
                tagCell.backgroundColor = Junction.Color.light_blue
                tagCell.titleLabel.textColor = UIColor.white
                tagCell.layer.borderColor = UIColor.clear.cgColor
                
            } else {
                tagCell.backgroundColor = UIColor.clear
                tagCell.titleLabel.textColor = Junction.Color.black
                tagCell.layer.borderColor = Junction.Color.black.cgColor
            }
        default:
            os_log("UICollectionViewX: changeCellUI(at:) unexpected cell.")
        }
    }
    
    func collectSelectedItems(based_on dataSource: [String]) -> [String]? {
        
        guard let selectedIndexPaths = self.indexPathsForSelectedItems else {
            os_log("UICollectionViewX: collectSelecteItems(from:) no items are selected.")
            return nil
        }
        
        var result = [String]()
        for selectedIndexPath in selectedIndexPaths {
            // print("Collected: \(dataSource[selectedIndexPath.item])")
            result.append(dataSource[selectedIndexPath.item])
        }
        return result
    }
    
    
    func preselect(items: [String: Any]?, at cell: UICollectionViewCell, _ indexPath: IndexPath) {
        guard let myitems = items else {
            os_log("UICollectionViewX: preselect(items:at:_:) has nil items.")
            return
        }

        switch cell {
        case is TagCollectionViewCell:
            let tagCell = cell as! TagCollectionViewCell
            
            var tagsNeedSelect = [String]()
            
            for (key, value) in myitems {
                if value is Int {
                    let intValue = value as! Int
                    if intValue >= 3 {
                        tagsNeedSelect.append(key)
                    }
                } else {
                    let strValue = value as! String
                    if !strValue.isEmpty {
                        tagsNeedSelect.append(key)
                    }
                }
            }
            
            if tagsNeedSelect.contains(tagCell.titleLabel.text!) {
                self.select(cell: tagCell, at: indexPath, scrollPosition: .right)
            }
        default:
            os_log("UICollectionViewX: preselect(items:at:_:) unexpected cell.")
        }
    }
    
    func select(cell: UICollectionViewCell, at indexPath: IndexPath, scrollPosition: UICollectionViewScrollPosition) {
        self.selectItem(at: indexPath, animated: true, scrollPosition: scrollPosition)
        self.changeUI(for: cell, selected: true)
    }
}
