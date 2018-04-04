//
//  ViewController.swift
//  PlayingCard
//
//  Created by 牧野 壽永 on 2018/04/03.
//  Copyright © 2018年 牧野 壽永. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var deck = PlayingCardDeck()
    
    @IBOutlet private var cardViews: [PlayingCardView]!
    
    lazy var animator = UIDynamicAnimator(referenceView: self.view)
    lazy var cardBehavior = CardBehavior(in: animator)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cards = [PlayingCard]()
        for _ in 1...((cardViews.count) / 2) {
            let card = deck.draw()!
            cards += [card, card]
        }
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            cardBehavior.addItem(cardView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private var faceUpCardViews: [PlayingCardView] {
        return cardViews.filter({ $0.isFaceUp && !$0.isHidden && $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) && $0.alpha == 1})
    }
    
    private var faceUpCardViewsMatch: Bool {
        return faceUpCardViews.count == 2
            && faceUpCardViews[0].rank == faceUpCardViews[1].rank
            && faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    
    var lastChosenCardView: PlayingCardView?
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView, faceUpCardViews.count < 2 {
                lastChosenCardView = chosenCardView
                cardBehavior.removeItem(chosenCardView)
                UIView.transition(
                    with: chosenCardView,
                    duration: 0.6,
                    options: [.transitionFlipFromLeft],
                    animations: {
                        chosenCardView.isFaceUp = !chosenCardView.isFaceUp
                    },
                    completion: { fnished in
                        let cardToAnimate = self.faceUpCardViews
                        if self.faceUpCardViewsMatch {
                            UIViewPropertyAnimator.runningPropertyAnimator(
                                withDuration: 0.6,
                                delay: 0,
                                options: [],
                                animations: {
                                    cardToAnimate.forEach({
                                        $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                                    })
                                },
                                completion: { (cardView) in
                                    UIViewPropertyAnimator.runningPropertyAnimator(
                                        withDuration: 0.75,
                                        delay: 0,
                                        options: [],
                                        animations: {
                                            cardToAnimate.forEach({
                                                $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                                $0.alpha = 0
                                            })
                                        },
                                        completion: { (cardView) in
                                            cardToAnimate.forEach({
                                                $0.isHidden = true
                                                $0.alpha = 1
                                                $0.transform = .identity
                                            })
                                        }
                                    )
                                }
                            )
                        } else if cardToAnimate.count == 2 {
                            if chosenCardView == self.lastChosenCardView {
                                cardToAnimate.forEach({ (cardView) in
                                    UIView.transition(
                                        with: cardView,
                                        duration: 0.6,
                                        options: [.transitionFlipFromLeft],
                                        animations: {
                                            cardView.isFaceUp = !cardView.isFaceUp
                                        },
                                        completion: { finished in
                                            self.cardBehavior.addItem(cardView)
                                        }
                                    )
                                })
                            }
                        } else {
                            if !chosenCardView.isFaceUp {
                                self.cardBehavior.addItem(chosenCardView)
                            }
                        }
                    }
                )
            }
        default:
            break;
        }
    }


//    @IBOutlet weak var playingCardView: PlayingCardView! {
//        didSet {
//            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
//            swipe.direction = [.left, .right]
//            playingCardView.addGestureRecognizer(swipe)
//
//            let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(playingCardView.adjustFaceCardScale(byHandlingGestureRecognizedBy:)))
//            playingCardView.addGestureRecognizer(pinch)
//        }
//    }
    
//    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
//        switch sender.state {
//        case .ended:
//            playingCardView.isFaceUp = !playingCardView.isFaceUp
//        default:
//            break;
//        }
//    }
//
//    @objc func nextCard() {
//        if let card = deck.draw() {
//            playingCardView.rank = card.rank.order
//            playingCardView.suit = card.suit.rawValue
//        }
//    }
    
}


extension CGFloat {
    var arc4random: CGFloat {
        if self > 0.0 {
            return CGFloat(arc4random_uniform(UINT32_MAX)) / CGFloat(UINT32_MAX) * self
        } else if self < 0 {
            return CGFloat(arc4random_uniform(UINT32_MAX)) / CGFloat(UINT32_MAX) * abs(self)
        } else {
            return CGFloat(0.0)
        }
    }
}
extension Double {
    var arc4random: Double {
        if self > 0.0 {
            return Double(arc4random_uniform(UINT32_MAX)) / Double(UINT32_MAX) * self
        } else if self < 0 {
            return Double(arc4random_uniform(UINT32_MAX)) / Double(UINT32_MAX) * abs(self)
        } else {
            return Double(0.0)
        }
    }
}
