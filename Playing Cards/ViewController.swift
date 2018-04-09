//
//  ViewController.swift
//  Playing Cards
//
//  Created by Hugo Ángeles Chávez on 4/8/18.
//  Copyright © 2018 Hugo Ángeles Chávez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var cardViews: [PlayingCardView]!
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var cardBehavior = PlayingCardBehavior(in: animator)
    
    private var flipsCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCardViews(hasToAddGesture: true)
    }
    
    private var cardsMatch: Bool {
        return faceUpCardViews.count == 2 &&
                faceUpCardViews[0].rank == faceUpCardViews[1].rank &&
                faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    
    private var faceUpCardViews: [PlayingCardView] {
        return cardViews.filter { $0.isFaceUp && !$0.isHidden }
    }
    
    private var isGameEnded: Bool {
        return cardViews.filter { !$0.isHidden }.count == 0
    }
    
    @objc
    func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let choosenCardView = recognizer.view as? PlayingCardView {
                handleCardViewTap(choosenCardView)
            }
        default:
            break
        }
    }
    
    fileprivate func handleCardViewTap(_ choosenCardView: PlayingCardView) {
        if faceUpCardViews.count >= 2 {
            return
        }
        
        flipsCount += 1
        cardBehavior.removeItem(choosenCardView)
        UIView.transition(with: choosenCardView,
              duration: 0.5,
              options: [.transitionFlipFromLeft],
              animations: {
                choosenCardView.isFaceUp = !choosenCardView.isFaceUp
              },
              completion: { finished in
                let faceUpCards = self.faceUpCardViews
                if self.cardsMatch {
                    faceUpCards.forEach { cardView in
                        self.animateMatchedCards(cardView)
                    }
                } else if faceUpCards.count == 2 {
                    self.faceDownCards(faceUpCards)
                }
            })
    }
    
    fileprivate func faceDownCards(_ faceUpCards: [PlayingCardView]) {
        faceUpCards.forEach { cardView in
            UIView.transition(with: cardView,
                              duration: 0.5,
                              options: [.transitionFlipFromLeft],
                              animations: {
                                cardView.isFaceUp = false
                              },
                              completion: { finished in
                                    self.cardBehavior.addItem(cardView)
                              })
        }
    }
    
    fileprivate func animateMatchedCards(_ cardView: PlayingCardView) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 1.0,
            delay: 0,
            options: [],
            animations: {
                cardView.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
        },
            completion: { finished in
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 1.0,
                    delay: 0,
                    options: [],
                    animations: {
                        cardView.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                        cardView.alpha = 0
                },
                    completion: { finished in
                        cardView.isHidden = true
                        cardView.alpha = 1
                        cardView.transform = CGAffineTransform.identity
                        
                        if self.isGameEnded {
                            self.showGameEnd()
                        }
                })
        })
    }
    
    func showGameEnd() {
        let alert = UIAlertController(title: "Game over", message: "Total flips: \(flipsCount)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Jugar otra vez", style: .default, handler: { _ in
            self.restartGame()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func restartGame() {
        setupCardViews(hasToAddGesture: false)
    }
    
    func setupCardViews(hasToAddGesture addGesture: Bool) {
        var deck = PlayingCardDeck()
        var cards = [PlayingCard]()
        
        for _ in 1...((cardViews.count + 1) / 2) {
            let card = deck.draw()!
            cards += [card, card]
        }
        
        for cardView in cardViews {
            cardView.isFaceUp = false
            cardView.isHidden = false
            cardView.alpha = 1
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardBehavior.removeItem(cardView)
            cardBehavior.addItem(cardView)
            if addGesture {
              cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            }
        }
    }
}

