//
//  ShiftCardViewDataSource.swift
//  ShiftCardViewController
//
//  Created by David Martinez on 15/08/2018.
//

import Foundation

public protocol ShiftCardViewDataSource: class {
    
    /**
     Determines the number of cards to be added into the controller
     
     - Parameter shiftController: controller that request to data source
    */
    func numberOfCards(shiftController: ShiftCardViewController) -> Int
    
    /**
     Provides the card view to be displayed in screen.
     
     - Parameter shiftController: controller that request to data source
     - Parameter index: index for the card to be displayed
     - Returns: A ShiftCardViewCell to display
    */
    func card(shiftController: ShiftCardViewController, forItemAtIndex index: Int) -> ShiftCardViewCell
    
    /**
     View to be displayed when no cards available
     
     - Parameter shiftController: controller that request to data source
     - Returns: optional view to be displayed at bottom of all cards
    */
    func noMoreCardsView(shiftController: ShiftCardViewController) -> UIView?
}
