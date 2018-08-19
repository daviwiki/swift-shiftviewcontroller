//
// Created by David Martinez on 19/08/2018.
//

import Foundation

protocol ShiftCardViewCellDelegate: class {

    /**
    Notified when the user drag ends and the animation to recover or dismiss the cell is finished
    - Parameter shiftCardCell: The cell that perform the animation
    - Parameter completed: Indicates that the cell will be dimissed (true) or will be recovered (false)
    */
    func shiftCardCell(_ shiftCardCell: ShiftCardViewCell, didEndShift finished: Bool)

}