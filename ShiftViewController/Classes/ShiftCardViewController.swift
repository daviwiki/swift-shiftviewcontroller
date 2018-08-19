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
    
    // Visible Cells array
    private var visibleCards: [ShiftCardViewCell] = []
    
    // MARK - Services
    public func reloadData() {

        removeAllCards()
        removeEmptyView()

        guard let dataSource = dataSource else { return }
        
        remainingCards = dataSource.numberOfCards(shiftController: self)
        
        for index in 0..<min(remainingCards, maxVisibleCards) {
            let card = dataSource.card(shiftController: self, forItemAtIndex: index)
            card.delegate = self
            add(cardView: card, at: index)
        }
        
        if remainingCards == 0, let emptyView = dataSource.noMoreCardsView(shiftController: self) {
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
    Remove the emptyView displayed (if this exists)
    */
    private func removeEmptyView() {
        view.subviews
                .filter({ !($0 is ShiftCardViewCell) })
                .forEach({ $0.removeFromSuperview() })
    }

    /**
    Include the card given in the view tree and set it display with the index given
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
    }
    
    /**
     Include the empty view to displayed when no cards available into the view tree
     - Parameter emptyView: the view to be displayed at the bottom of the screen when no cards available
     - Parameter animated: Indicates that the view will be present or not with animation
    */
    private func add(emptyView: UIView, animated: Bool = false) {
        view.addSubview(emptyView)
        view.edgeConstraintsTo(view: emptyView)
        view.sendSubview(toBack: emptyView)

        if animated {
            view.alpha = 0.0
            UIView.animate(withDuration: 0.2) { [unowned self] in self.view.alpha = 1.0 }
        }
    }
}

extension ShiftCardViewController: ShiftCardViewCellDelegate {

    func shiftCardCell(_ shiftCardCell: ShiftCardViewCell, didEndShift finished: Bool) {
        guard finished else { return }

        // Remove cell from view tree
        shiftCardCell.removeFromSuperview()
        if let index = visibleCards.index(of: shiftCardCell) {
            visibleCards.remove(at: index)
        }

        // Include new cells if needed
        if let card = requestNewCellToAddAtEnd() {
            add(cardView: card, at: maxVisibleCards)
        }

        // perform new view state for new cells
        UIView.animate(withDuration: 0.2) { [unowned self] in
            var index = 0
            self.visibleCards.forEach {
                self.setFrame(forCard: $0, atIndex: index)
                index += 1
            }
        }

        if visibleCards.count == 0, let emptyView = dataSource?.noMoreCardsView(shiftController: self) {
            add(emptyView: emptyView, animated: true)
        }
    }

    private func requestNewCellToAddAtEnd() -> ShiftCardViewCell? {
        guard remainingCards > 0 else { return nil }
        guard let cellCount = dataSource?.numberOfCards(shiftController: self) else { return nil }
        let nextCellIndex = cellCount - remainingCards
        guard let cell = dataSource?.card(shiftController: self, forItemAtIndex: nextCellIndex) else { return nil }
        cell.delegate = self
        return cell
    }
}
