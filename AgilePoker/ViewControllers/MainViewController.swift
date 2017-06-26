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
import MaterialMotion

class MainViewController: UIViewController, TransitionContextViewRetriever {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundImage: UIImageView!
    var actionButton: UIButton!


    let backgroundImageName = "bg_redfelt" // "bg_table" // "bg_redfelt"
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
        
        setupSettingsButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupSettingsButton() {
        actionButton = UIButton(type: .custom)
        
        actionButton.setTitle("", for: UIControlState.normal)
        actionButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 24)
        actionButton.setTitleColor(UIColor.lightGray, for: .normal)
        
        actionButton.backgroundColor = UIColor(hexColor: 0x0971B2)
        actionButton.bounds = .init(x: 0, y: 0, width: 50, height: 50)
        actionButton.layer.cornerRadius = actionButton.bounds.width / 2
        // bottom right
//        actionButton.layer.position = .init(x: view.bounds.width - actionButton.bounds.width / 2 - 24,
//                                            y: view.bounds.height - actionButton.bounds.height / 2 - 24)
        
        // top right
        actionButton.layer.position = .init(x: view.bounds.width - actionButton.bounds.width / 2 - 24,
                                            y: 150)
        
        actionButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        actionButton.layer.shadowOpacity = 0.5
        actionButton.layer.shadowOffset = .init(width: 0, height: 3)
        actionButton.layer.shadowRadius = 2
        actionButton.layer.shadowPath = UIBezierPath(ovalIn: actionButton.bounds).cgPath
        view.addSubview(actionButton)
        
        actionButton.addTarget(self, action: #selector(didTapSettings), for: .touchUpInside)
    }
    
    func didTapSettings() {
        let settingsViewController = SettingsViewController()
//        settingsViewController.transitionController.transition = CircularRevealTransition()
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.transitionController.transition = CircularRevealTransition()
        settingsViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(settingsCancel))
        settingsViewController.title = "Settings"
        present(navigationController, animated: true)
//        present(settingsViewController, animated: true, completion: nil)
    }
    
    func settingsCancel() {
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

// MARK: - CircularRevealTransition
let floodFillOvershootRatio: CGFloat = 1.2

private class CircularRevealTransition: TransitionWithTermination {
    
    // TODO: Support for transient views.
    var floodFillView: UIView!
    var foreViewLayer: CALayer!
    
    func didEndTransition(withContext ctx: TransitionContext, runtime: MotionRuntime) {
        floodFillView.removeFromSuperview()
        foreViewLayer.mask = nil
    }
    
    func willBeginTransition(withContext ctx: TransitionContext, runtime: MotionRuntime) -> [Stateful] {
        foreViewLayer = ctx.fore.view.layer
        
        let contextView = ctx.contextView()!
        
        floodFillView = UIView()
        floodFillView.backgroundColor = contextView.backgroundColor
        floodFillView.layer.cornerRadius = contextView.layer.cornerRadius
        floodFillView.layer.shadowColor = contextView.layer.shadowColor
        floodFillView.layer.shadowOffset = contextView.layer.shadowOffset
        floodFillView.layer.shadowOpacity = contextView.layer.shadowOpacity
        floodFillView.layer.shadowRadius = contextView.layer.shadowRadius
        floodFillView.layer.shadowPath = contextView.layer.shadowPath
        floodFillView.frame = ctx.containerView().convert(contextView.bounds, from: contextView)
        ctx.containerView().addSubview(floodFillView)
        
        let maskLayer = CAShapeLayer()
        let maskPathBounds = floodFillView.frame.insetBy(dx: 1, dy: 1)
        maskLayer.path = UIBezierPath(ovalIn: maskPathBounds).cgPath
        ctx.fore.view.layer.mask = maskLayer
        
        // The distance from the center of the context view to the top left of the screen is the desired
        // radius of the circle fill. If the context view is placed in a different corner of the screen
        // then this will need to be replaced with an algorithm that determines the furthest corner from
        // the center of the view.
        let outerRadius = CGFloat(sqrt(floodFillView.center.x * floodFillView.center.x + floodFillView.center.y * floodFillView.center.y)) * floodFillOvershootRatio
        
        let expandedSize = CGSize(width: outerRadius * 2, height: outerRadius * 2)
        
        let expansion = tween(back: floodFillView.bounds.size, fore: expandedSize, ctx: ctx)
        let fadeOut = tween(back: CGFloat(1), fore: CGFloat(0), ctx: ctx)
        let radius = tween(back: floodFillView.layer.cornerRadius, fore: outerRadius, ctx: ctx)
        
        let foreShadowPath = CGRect(origin: .zero(), size: expandedSize)
        let shadowPath = tween(back: floodFillView.layer.shadowPath!, fore: UIBezierPath(ovalIn: foreShadowPath).cgPath, ctx: ctx)
        
        let floodLayer = runtime.get(floodFillView).layer
        runtime.add(expansion, to: floodLayer.size)
        runtime.add(fadeOut, to: floodLayer.opacity)
        runtime.add(radius, to: floodLayer.cornerRadius)
        runtime.add(shadowPath, to: floodLayer.shadowPath)
        
        let shiftIn = tween(back: ctx.fore.view.layer.position.y + 40, fore: ctx.fore.view.layer.position.y, ctx: ctx)
        runtime.add(shiftIn, to: runtime.get(ctx.fore.view).layer.positionY)
        
        let maskShiftIn = tween(back: CGFloat(-40), fore: CGFloat(0), ctx: ctx)
        runtime.add(maskShiftIn, to: runtime.get(maskLayer).positionY)
        
        let foreMaskBounds = CGRect(x: floodFillView.center.x - outerRadius,
                                    y: floodFillView.center.y - outerRadius,
                                    width: outerRadius * 2,
                                    height: outerRadius * 2)
        let maskReveal = tween(back: maskLayer.path!, fore: UIBezierPath(ovalIn: foreMaskBounds).cgPath, ctx: ctx)
        runtime.add(maskReveal, to: runtime.get(maskLayer).path)
        
        runtime.add(Hidden(), to: contextView)
        
        return [expansion, fadeOut, radius, shadowPath, shiftIn]
    }
    
    private func tween<T>(back: T, fore: T, ctx: TransitionContext) -> Tween<T> {
        let values: [T]
        if ctx.direction.value == .forward {
            values = [back, fore]
        } else {
            values = [fore, back]
        }
        return Tween(duration: 0.4 * simulatorDragCoefficient(), values: values)
    }
}

private class Hidden: Interaction {
    deinit {
        for view in hiddenViews {
            view.isHidden = false
        }
    }
    func add(to view: UIView, withRuntime runtime: MotionRuntime, constraints: NoConstraints) {
        view.isHidden = true
        hiddenViews.insert(view)
    }
    var hiddenViews = Set<UIView>()
}



