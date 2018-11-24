//
//  CardViewController.swift
//  AgilePoker
//
//  Created by Astro on 6/25/17.
//  Copyright © 2017 Rock Solid Bits. All rights reserved.
//

import UIKit
//import MaterialMotion

class CardViewController: UIViewController, UIGestureRecognizerDelegate {
	
    @IBOutlet weak var topLeftLabel: UILabel!
    @IBOutlet weak var bottomRightLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!

    var card: Card?
    var backgroundImageName: String?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap))
		tap.numberOfTapsRequired = 1
		tap.delegate = self
		
		self.cardView.addGestureRecognizer(tap)
		
        self.cardView.layer.borderColor = UIColor.black.cgColor
        self.cardView.layer.borderWidth = 1
        
        self.cardView.layer.cornerRadius = 14;
        self.cardView.layer.masksToBounds = true;
        
        self.topLeftLabel.text = "?"
        self.bottomRightLabel.text = "?"

        if self.card != nil {
            self.topLeftLabel.text = self.card!.title
            self.bottomRightLabel.text = self.card!.title
        }
        
        if self.backgroundImageName != nil {
            self.backgroundImage.image = UIImage(named: self.backgroundImageName!)
        }
        
        self.topLeftLabel.sizeToFit()
        self.bottomRightLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        self.bottomRightLabel.sizeToFit()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@objc func handleSingleTap(sender: UITapGestureRecognizer) {
		self.dismiss(animated: true, completion: nil)
	}
}
