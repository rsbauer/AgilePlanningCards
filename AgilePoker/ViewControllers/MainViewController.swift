//
//  MainViewController.swift
//  AgilePoker
//
//  Created by Astro on 6/24/17.
//  Copyright © 2017 Rock Solid Bits. All rights reserved.
//

import UIKit
import CocoaLumberjack

class MainViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundImage: UIImageView!

    let backgroundImageName = "bg_table" // "bg_redfelt"
    let deckToLoad = "Fibonacci" // "TShirt" // "Pivotal"
    var deck: [Card] = []
    var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "PlayingCardCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "PlayingCardCollectionViewCell")
        
        loadDeck(deckToLoad)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
//        self.collectionView.isPagingEnabled = true
        
        self.backgroundImage.image = UIImage(named: self.backgroundImageName)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Methods
    
    func loadDeck(_ deckName: String) {
        self.deck = []

        if let path = Bundle.main.path(forResource: deckName, ofType: "plist") {
            if let array = NSArray(contentsOfFile: path) as? Array<Dictionary<String, AnyObject>> {
                for item in array {
                    let card = Card()
                    card.title = item["title"] as! String
                    
                    self.deck.append(card)
                }
            }
        }
        
        self.reloadData()
    }
    
    func reloadData() {
        self.collectionView.reloadData()
    }
    

}

extension MainViewController: UICollectionViewDataSource {
    //MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.collectionView.collectionViewLayout.invalidateLayout()
        return deck.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayingCardCollectionViewCell", for: indexPath) as! PlayingCardCollectionViewCell
        
        let card = deck[indexPath.item]
        cell.configureCell(with: card)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "UICollectionViewCell", for: indexPath) as UIView
        return view as! UICollectionReusableView
    }
}

extension MainViewController: UICollectionViewDelegate {
    //MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let cell = collectionView.cellForItem(at: indexPath) as? PlayingCardCollectionViewCell else { return }

        self.selectedIndexPath = indexPath
        
        let cardViewController = CardViewController()
        let card = deck[indexPath.item]
        cardViewController.backgroundImageName = self.backgroundImageName
        cardViewController.card = card
        present(cardViewController, animated: true, completion: nil)
    }
 
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}

