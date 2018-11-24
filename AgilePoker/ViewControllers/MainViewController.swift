//
//  MainViewController.swift
//  AgilePoker
//
//  Created by Astro on 6/24/17.
//  Copyright © 2017 Rock Solid Bits. All rights reserved.
//

/*
 Color pallete
 red: B21212    (bg_redfelt)
 yellow: FFFC19
 red: FF0000 (pure red)
 blue: 1485CC
 darker blue: 0971B2
 */

import UIKit
import CocoaLumberjack
//import MaterialMotion

class MainViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var actionButton: UIButton!


    var backgroundImageName = "bg_redfelt" // "bg_table" // "bg_redfelt"
    var deckToLoad = "Fibonacci" // "TShirt" // "Pivotal"
    var deck: [Card] = []
    var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "PlayingCardCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "PlayingCardCollectionViewCell")
        
        let deckIndex = UserDefaults.standard.integer(forKey: SettingsViewController.deckIndexSetting)
        deckToLoad = findDeckNameFromIndex(deckIndex)
        
        loadDeck(deckToLoad)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let backgroundImageIndex = UserDefaults.standard.integer(forKey: SettingsViewController.backgroundImageIndexSetting)
        self.backgroundImageName = findImageFromIndex(backgroundImageIndex)
        self.backgroundImage.image = UIImage(named: self.backgroundImageName)
        
        setupSettingsButton()
        
        MessageBroker.sharedMessageBroker.subscribe(self, messageKey: SettingsMessage.deckIndexType)
        MessageBroker.sharedMessageBroker.subscribe(self, messageKey: SettingsMessage.backgroundImageIndexType)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupSettingsButton() {
        actionButton.setTitle("", for: UIControl.State.normal)
        actionButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 24)
        actionButton.setTitleColor(UIColor.lightGray, for: .normal)
        
        actionButton.backgroundColor = UIColor(hexColor: 0x0971B2)
        actionButton.bounds = .init(x: 0, y: 0, width: 50, height: 50)
        actionButton.layer.cornerRadius = actionButton.bounds.width / 2
        
        actionButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        actionButton.layer.shadowOpacity = 0.5
        actionButton.layer.shadowOffset = .init(width: 0, height: 3)
        actionButton.layer.shadowRadius = 2
        actionButton.layer.shadowPath = UIBezierPath(ovalIn: actionButton.bounds).cgPath
        
        actionButton.addTarget(self, action: #selector(didTapSettings), for: .touchUpInside)
    }
    
    @objc func didTapSettings() {
        let settingsViewController = SettingsViewController()
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        settingsViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(settingsCancel))
        settingsViewController.title = "Settings"
        present(navigationController, animated: true)
    }
    
    @objc func settingsCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func contextViewForTransition(foreViewController: UIViewController) -> UIView? {
        return self.actionButton
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
    
    func findDeckNameFromIndex(_ index: Int) -> String {
        let array = SettingsViewController.loadDecksPlist()
        var a = 0
        for item in array {
            if a == index {
                if let name = item["name"] as? String {
                    return name
                }
            }
            a += 1
        }
        
        return "Fibonacci"
    }
    
    func findImageFromIndex(_ index: Int) -> String {
        let array = SettingsViewController.loadImagesPlist()
        var a = 0
        for item in array {
            if a == index {
                if let name = item["image"] as? String {
                    return name
                }
            }
            a += 1
        }
        
        return "bg_redfelt"
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
        let view =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "UICollectionViewCell", for: indexPath) as UIView
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

extension MainViewController: Subscriber {
    func receive(_ message: Message) {
        if let settingsMessage = message as? SettingsMessage {
            switch settingsMessage {
                case .deckIndex(let index):
                    deckToLoad = findDeckNameFromIndex(index)
                    loadDeck(deckToLoad)
                    self.collectionView.reloadData()
                
                case .backgroundImageIndex(let index):
                    self.backgroundImageName = findImageFromIndex(index)
                    self.backgroundImage.image = UIImage(named: self.backgroundImageName)
            }
        }
    }
}
