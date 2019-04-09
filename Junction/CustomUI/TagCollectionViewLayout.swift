//
//  TagCollectionViewLayout.swift
//  Dots
//
//  Created by 林晏竹 on 2017/12/14.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import UIKit

class TagCollectionViewLayout: UICollectionViewLayout {

    // MARK: - Constants
    var cellSize: CGSize!
    var itemSpacing: CGFloat!
    var rowSpacing: CGFloat!
    var headPadding: CGFloat!
    var headSpacing: CGFloat! {
        return self.cellSize.width / 2
    }
    
    
    
    // MARK: - Variables
    var numberOfRows: Int! {
        let numberOfItems = self.collectionView!.numberOfItems(inSection: 0)
        if numberOfItems <= 12 {
            if numberOfItems % self.itemsPerRow == 0 {
                // 整除
                return numberOfItems / self.itemsPerRow
            } else {
                // 有餘數，numberOfRows + 1（多加一行）
                return (numberOfItems / self.itemsPerRow) + 1
            }
        } else {
            return 3
        }
    }
    var itemsPerRow: Int! {
        let numberOfItems = self.collectionView!.numberOfItems(inSection: 0)
        if numberOfItems <= 12 {
            return 4
        } else {
            if numberOfItems % self.numberOfRows == 0 {
                // 整除
                return numberOfItems / self.numberOfRows
            } else {
                // 有餘數，itemsPerRow + 1
                return (numberOfItems / self.numberOfRows) + 1
            }
        }
    }
    override var collectionViewContentSize: CGSize {
        let width = CGFloat(self.itemsPerRow) * self.cellSize.width + self.itemSpacing * (CGFloat(self.itemsPerRow) - 1) + self.headSpacing + self.headPadding * 2
        
        return CGSize(width: width, height: collectionView!.bounds.height)
    }

    
    
    // MARK: Layout Functions
    override func prepare() {
        super.prepare()
        
        guard let _ = self.collectionView else { return }
        self.cellSize = CGSize(width: 107, height: 40)
        self.itemSpacing = 12
        self.rowSpacing = 12
        self.headPadding = 15
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return (0 ..< collectionView!.numberOfItems(inSection: 0)).map { IndexPath(item: $0, section: 0) }
            .filter { rect.intersects(rectForItem(at: $0)) }
            .flatMap { self.layoutAttributesForItem(at: $0) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.size = self.cellSize
        attributes.center = self.locateCell(at: indexPath)
        return attributes
    }
    
    
    
    // MARK: - Helper Functions
    private func locateCell(at indexPath: IndexPath) -> CGPoint {
        var centerX: CGFloat = 0
        var centerY: CGFloat = 0
        let row: Int = indexPath.item / self.itemsPerRow
        let index: Int = indexPath.item % self.itemsPerRow
        let halfWidth = self.cellSize.width / 2
        let halfHeight = self.cellSize.height / 2
        
        
        if row % 2 == 0 {
            centerX = self.headPadding + self.headSpacing + halfWidth * (2 * CGFloat(index) + 1) + self.itemSpacing * CGFloat(index)
        } else {
            centerX = self.headPadding + halfWidth * (2 * CGFloat(index) + 1) + self.itemSpacing * CGFloat(index)
        }
        centerY = halfHeight * (2 * CGFloat(row) + 1) + self.rowSpacing * CGFloat(row)
        
        return CGPoint(x: centerX, y: centerY)
    }
    
    private func rectForItem(at indexPath: IndexPath) -> CGRect {
        let center = locateCell(at: indexPath)
        
        return CGRect(x: center.x - self.cellSize.width / 2, y: center.y - self.cellSize.height / 2, width: self.cellSize.width, height: self.cellSize.height)
    }
}
