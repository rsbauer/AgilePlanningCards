//
//  CircularCollectionViewLayout.swift
//  AgilePoker
//
//  Created by Astro on 6/24/17.
//  Copyright © 2017 Rock Solid Bits. All rights reserved.
//

import UIKit
import CocoaLumberjack

// code mostly from: https://www.raywenderlich.com/107687/uicollectionview-custom-layout-tutorial-spinning-wheel

class CircularCollectionViewLayout: UICollectionViewLayout {
    let itemSize = CGSize(width: 200, height: 280)      // ratio is 1.4 so height = width * 1.4
    let verticleOffset: CGFloat = 25.0
    let cardSpacing: CGFloat = 0.0
    
    var angleAtExtreme: CGFloat {
        return collectionView!.numberOfItems(inSection: 0) > 0 ?
            -CGFloat(collectionView!.numberOfItems(inSection: 0) - 1) * anglePerItem : 0
    }
    
    var angle: CGFloat {
        return angleAtExtreme * collectionView!.contentOffset.x / (collectionViewContentSize.width -
            collectionView!.bounds.width)
    }
    
    var radius: CGFloat = 500 {
        didSet {
            invalidateLayout()
        }
    }
    
    var anglePerItem: CGFloat {
        let angleItem = atan(itemSize.width / radius)        // -100 will tighten up the spacing between cards
        return angleItem / 2
    }
    
    var attributesList = [CircularCollectionViewLayoutAttributes]()
    
    // declare how big the content will be
    override var collectionViewContentSize: CGSize {
        return CGSize(width: CGFloat(collectionView!.numberOfItems(inSection: 0)) * itemSize.width, height: collectionView!.bounds.height)
    }

    override class var layoutAttributesClass: AnyClass {
        return CircularCollectionViewLayoutAttributes.self
    }
    
    override func prepare() {
        super.prepare()
        
        let centerX = collectionView!.contentOffset.x + (collectionView!.bounds.width / 2.0)
        let anchorPointY = ((itemSize.height / 2.0) + radius) / itemSize.height
        
        // optimization to only apply attributes to cells in view
        // find theta - this is the angle of the cards in view
        let theta = atan2(collectionView!.bounds.width / 2.0,
                          radius + (itemSize.height / 2.0) - (collectionView!.bounds.height / 2.0))

        var startIndex = 0
        var endIndex = collectionView!.numberOfItems(inSection: 0) - 1
        
        // If the angular position of the 0th item is less than -theta, then it lies outside the screen. In that case, the first item on the screen will be the difference between -θ and angle divided by anglePerItem;
        if (angle < -theta) {
            startIndex = Int(floor((-theta - angle) / anglePerItem))
        }
        
        // the last element on the screen will be the difference between θ and angle divided by anglePerItem, and min serves as an additional check to ensure endIndex doesn’t go beyond the total number of items;
        endIndex = min(endIndex, Int(ceil((theta - angle) / anglePerItem) + 1))
       
        // add a safety check to make the range 0...0 if endIndex is less than startIndex. This edge case occurs when you scroll with a very high velocity and all the cells go completely off-screen.
        if (endIndex < startIndex) {
            endIndex = 0
            startIndex = 0
        }
        
        if endIndex > collectionView!.numberOfItems(inSection: 0) {
            endIndex = collectionView!.numberOfItems(inSection: 0)
        }
        
        // end optimization
        
        if startIndex == endIndex && endIndex == 0 {
            attributesList = []
            return
        }
        
        attributesList = (startIndex...endIndex).map { (i)
            -> CircularCollectionViewLayoutAttributes in

            let attributes = CircularCollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
            attributes.size = self.itemSize
            
            // position each item at the center of the screen
            attributes.center = CGPoint(x: centerX, y: self.collectionView!.bounds.midY + verticleOffset)
            
            // rotate each item
            attributes.angle = self.angle + (self.anglePerItem * CGFloat(i))
            
            // set the anchor so it is not at the center of the screen
            attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)
            return attributes
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesList
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesList[indexPath.row]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
