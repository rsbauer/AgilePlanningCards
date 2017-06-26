//
//  PlayingCardCollectionViewCell.swift
//  AgilePoker
//
//  Created by Astro on 6/24/17.
//  Copyright © 2017 Rock Solid Bits. All rights reserved.
//

import UIKit

class PlayingCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var topLeftLabel: UILabel!
    @IBOutlet weak var bottomRightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureCell(with card: Card) {
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        
        self.layer.cornerRadius = 7;
        self.layer.masksToBounds = true;

        self.topLeftLabel.text = card.title
        self.bottomRightLabel.text = card.title
        
        self.topLeftLabel.sizeToFit()
        self.bottomRightLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        self.bottomRightLabel.sizeToFit()
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        let circularlayoutAttributes = layoutAttributes as! CircularCollectionViewLayoutAttributes
        self.layer.anchorPoint = circularlayoutAttributes.anchorPoint
        self.center.y += (circularlayoutAttributes.anchorPoint.y - 0.5) * self.bounds.height
    }
}
