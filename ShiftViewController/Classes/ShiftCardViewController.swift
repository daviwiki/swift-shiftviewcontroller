//
//  ShiftCardViewController.swift
//  ShiftCardViewController
//
//  Created by David Martinez on 15/08/2018.
//

import UIKit

public class ShiftCardViewController: UIViewController {
    
    public weak var dataSource: ShiftCardViewDataSource? {
        didSet {
            reloadData()
        }
    }
    
    // Number of cards displayed plus to pending to display
    private var remainingCards: Int = 0
    
    // Max number of cards visible into the display
    private let maxVisibleCards = 3
    
    //
    private var visibleCards: [ShiftCardViewCell] = []
    
    // MARK - Services
    public func reloadData() {
        removeAllCards()
        guard let dataSource = dataSource else { return }
        
        remainingCards = dataSource.numberOfCards(shiftController: self)
        
        for index in 0..<min(remainingCards, maxVisibleCards) {
            let card = dataSource.card(shiftController: self, forItemAtIndex: index)
            add(cardView: card, at: index)
        }
        
        if let emptyView = dataSource.noMoreCardsView(shiftController: self) {
            add(emptyView: emptyView)
        }
        
        view.setNeedsDisplay()
    }
    
    /**
     Remove all visible cards
    */
    private func removeAllCards() {
        visibleCards.forEach({ $0.removeFromSuperview() })
        visibleCards.removeAll()
    }
    
    /**
    */
    private func add(cardView: ShiftCardViewCell, at index: Int) {
        setFrame(forCard: cardView, atIndex: index)
        visibleCards.append(cardView)
        view.insertSubview(cardView, at: 0)
        remainingCards -= 1
    }
    
    /**
     Set the frame for the view
     - Parameter cardView: card view to be framed
     - Parameter index: location index into view tree where starting at 0 (top most view)
    */
    private func setFrame(forCard cardView: ShiftCardViewCell, atIndex index: Int) {
        let inset: CGFloat = 12
        var cardViewFrame = view.bounds
        let horizontalInset = CGFloat(index) * inset
        let verticalInset = CGFloat(index) * inset
        
        cardViewFrame.size.width -= 2 * horizontalInset
        cardViewFrame.origin.x += horizontalInset
        cardViewFrame.origin.y += verticalInset
        
        cardView.frame = cardViewFrame
        print("Frame at index \(index) -> \(cardViewFrame)")
    }
    
    /**
     Include the empty view to displayed when no cards available into the view tree
    */
    private func add(emptyView: UIView) {
        view.addSubview(emptyView)
        view.edgeConstraintsTo(view: emptyView)
        view.sendSubview(toBack: emptyView)
    }
}
