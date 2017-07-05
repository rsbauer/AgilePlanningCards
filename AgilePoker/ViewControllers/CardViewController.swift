//
//  CardViewController.swift
//  AgilePoker
//
//  Created by Astro on 6/25/17.
//  Copyright © 2017 Rock Solid Bits. All rights reserved.
//

import UIKit
import MaterialMotion

class CardViewController: MaterialMotion.UIViewController, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var topLeftLabel: UILabel!
    @IBOutlet weak var bottomRightLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!

    var card: Card?
    var backgroundImageName: String?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        transitionController.transition = PushBackTransition()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = .init(width: view.bounds.width, height: view.bounds.height * 10)
        view.addSubview(scrollView)
        
        let pan = UIPanGestureRecognizer()
        pan.delegate = transitionController.topEdgeDismisserDelegate(for: scrollView)
        transitionController.dismissWhenGestureRecognizerBegins(pan)
        scrollView.panGestureRecognizer.require(toFail: pan)
        view.addGestureRecognizer(pan)
        
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
}

private class PushBackTransition: Transition {
    
    func willBeginTransition(withContext ctx: TransitionContext, runtime: MotionRuntime) -> [Stateful] {
        let draggable = Draggable(withFirstGestureIn: ctx.gestureRecognizers)
        
        runtime.add(ChangeDirection(withVelocityOf: draggable.nextGestureRecognizer, whenNegative: .forward),
                    to: ctx.direction)
        
        let bounds = ctx.containerView().bounds
        let backPosition = CGPoint(x: bounds.midX, y: bounds.maxY + ctx.fore.view.bounds.height / 2)
        let forePosition = CGPoint(x: bounds.midX, y: bounds.midY)
        let movement = TransitionSpring(back: backPosition,
                                        fore: forePosition,
                                        direction: ctx.direction)
        
        let scale = runtime.get(ctx.back.view.layer).scale
        
        let tossable = Tossable(spring: movement, draggable: draggable)
        
        runtime.connect(runtime.get(ctx.fore.view.layer).position.y()
            .rewriteRange(start: movement.backwardDestination.y,
                          end: movement.forwardDestination.y,
                          destinationStart: 1,
                          destinationEnd: 0.95),
                        to: scale)
        
        runtime.add(tossable, to: ctx.fore.view) { $0.xLocked(to: bounds.midX) }
        
        return [tossable]
    }
}

