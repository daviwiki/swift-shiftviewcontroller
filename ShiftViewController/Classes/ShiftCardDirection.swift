//
// Created by David Martinez on 18/08/2018.
//

import CoreGraphics

enum ShiftCardDirection {
    case top
    case topRight
    case right
    case bottomRight
    case bottom
    case bottomLeft
    case left
    case topLeft

    static let allDirections: [ShiftCardDirection] = [.top, .topRight, .right, bottomRight, .bottom, .bottomLeft, .left, .topLeft]

    enum HorizontalPosition: CGFloat {
        case left = -1
        case middle = 0
        case right = 1
    }

    enum VerticalPosition: CGFloat {
        case top = -1
        case middle = 0
        case bottom = 1
    }

    var horizontalPosition: HorizontalPosition {
        switch self {
        case .left:
            return .left
        case .right:
            return .right
        case .top:
            return .middle
        case .bottom:
            return .middle
        case .topLeft:
            return .left
        case .topRight:
            return .right
        case .bottomLeft:
            return .left
        case .bottomRight:
            return .right
        }
    }

    var verticalPosition: VerticalPosition {
        switch self {
        case .left:
            return .middle
        case .right:
            return .middle
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .topLeft:
            return .top
        case .topRight:
            return .top
        case .bottomLeft:
            return .bottom
        case .bottomRight:
            return .bottom
        }
    }

    var point: CGPoint {
        return CGPoint(x: horizontalPosition.rawValue, y: verticalPosition.rawValue)
    }

    // Return the rectangle { (0, 0) (2, 2) } that represents the bounds of the coordinate system
    static var coordinateRect: CGRect {
        let w = HorizontalPosition.right.rawValue - HorizontalPosition.left.rawValue
        let h = VerticalPosition.bottom.rawValue - VerticalPosition.top.rawValue
        return CGRect(x: HorizontalPosition.left.rawValue, y: VerticalPosition.top.rawValue, width: w, height: h)
    }
}

extension CGRect {

    private var topLine: CGLine {
        return (ShiftCardDirection.topLeft.point, ShiftCardDirection.topRight.point)
    }

    private var leftLine: CGLine {
        return (ShiftCardDirection.topLeft.point, ShiftCardDirection.bottomLeft.point)
    }

    private var bottomLine: CGLine {
        return (ShiftCardDirection.bottomLeft.point, ShiftCardDirection.bottomRight.point)
    }

    private var rightLine: CGLine {
        return (ShiftCardDirection.topRight.point, ShiftCardDirection.bottomRight.point)
    }

    var perimeterLines: [CGLine] {
        return [topLine, leftLine, bottomLine, rightLine]
    }

}