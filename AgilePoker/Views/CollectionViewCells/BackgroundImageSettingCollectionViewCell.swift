//
//  BackgroundImageSettingCollectionViewCell.swift
//  AgilePoker
//
//  Created by Astro on 7/4/17.
//  Copyright © 2017 Rock Solid Bits. All rights reserved.
//

import UIKit

class BackgroundImageSettingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(imageName: String) {
        self.imageView.image = UIImage(named: imageName)
        self.layer.cornerRadius = 7;
        self.layer.masksToBounds = true;
    }

    func wasSelected() {
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 2
    }
    
    func wasDeselected() {
        self.layer.borderWidth = 0
    }
}
