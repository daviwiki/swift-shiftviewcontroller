//
// Created by David Martinez on 19/08/2018.
//

import Foundation
import CoreGraphics

protocol ShiftCardViewCellDelegate: class {

    /**
    Notified when the user drag will begin
    - Parameter shiftCardCell: The cell that perform the animation
    - Parameter completed: Indicates that the cell will be dimissed (true) or will be recovered (false)
    - Parameter duration: The duration for the internal animations
    */
    func shiftCardCell(_ shiftCardCell: ShiftCardViewCell, willEndShift finished: Bool, duration: Double)

    /**
    Notified when the user drag ends and the animation to recover or dismiss the cell is finished
    - Parameter shiftCardCell: The cell that perform the animation
    - Parameter completed: Indicates that the cell will be dimissed (true) or will be recovered (false)
    */
    func shiftCardCell(_ shiftCardCell: ShiftCardViewCell, didEndShift finished: Bool)

    /**
    Notified each time user is dragging the card over the screen with the percent from origin point
    - Parameter shiftCardCell: The cell that perform the animation
    - Parameter percent: The percent in [0, 1]
    */
    func shiftCardCell(_ shiftCardCell: ShiftCardViewCell, didUpdateWithPercent percent: CGFloat)
}