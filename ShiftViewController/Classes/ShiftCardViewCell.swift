//
//  ShiftCardViewCell.swift
//  ShiftCardViewController
//
//  Created by David Martinez on 15/08/2018.
//

import UIKit

open class ShiftCardViewCell: UIView {

    private enum AnimationKeys: String {
        case resetCard
        case dismissCard
    }

    private enum AnimationDuration: Double {
        case reset = 0.6
        case dismiss = 0.3
    }

    private var panGestureRecognizer: UIPanGestureRecognizer?

    private let shiftThreshold: CGFloat = 0.6
    private let maxRotation: CGFloat = 1.0
    private let animationDirectionY: CGFloat = 1.0
    private let maxRotationAngle: CGFloat = CGFloat(Double.pi) / 10.0

    weak var delegate: ShiftCardViewCellDelegate?

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGestureRecognizers()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureRecognizers()
    }
    
    deinit {
        if let panGesture = panGestureRecognizer {
            removeGestureRecognizer(panGesture)
        }
    }
    
    private func setupGestureRecognizers() {
        // Pan Gesture Recognizer
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized(_:)))
        self.panGestureRecognizer = panGestureRecognizer
        addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func panGestureRecognized(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: self)

        switch panGesture.state {
        case .began:
            let initialTouchPoint = panGesture.location(in: self)
            let newAnchorPoint = CGPoint(x: initialTouchPoint.x / bounds.width, y: initialTouchPoint.y / bounds.height)
            let oldPosition = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)
            let newPosition = CGPoint(x: bounds.size.width * newAnchorPoint.x, y: bounds.size.height * newAnchorPoint.y)
            layer.anchorPoint = newAnchorPoint
            layer.position = CGPoint(x: layer.position.x - oldPosition.x + newPosition.x, y: layer.position.y - oldPosition.y + newPosition.y)

            removeAnimations()
            layer.rasterizationScale = UIScreen.main.scale
            layer.shouldRasterize = true
        case .changed:
            let rotationStrength = min(translation.x / frame.width, maxRotation)
            let rotationAngle = animationDirectionY * maxRotationAngle * rotationStrength
            var transform = CATransform3DIdentity
            transform = CATransform3DRotate(transform, rotationAngle, 0, 0, 1)
            transform = CATransform3DTranslate(transform, translation.x, translation.y, 0)
            layer.transform = transform

            let percent = getDragPercentage(from: translation)
            let direction = try? getDragDirection(from: translation)
            delegate?.shiftCardCell(self, didUpdateWithPercent: percent)
            cellPanShift(with: percent, andDirection: direction)
        case .ended:
            onUserEndPan(from: translation)
            layer.shouldRasterize = false
        default:
            cellReset(animationDuration: AnimationDuration.reset.rawValue)
            resetCardLocation()
            layer.shouldRasterize = false
        }
    }

    /**
    Eject the card outside the stack with animation in the direction selected
    - Parameter direction: The direction selected to dismiss the card
    */
    public func dismissCard(with direction: ShiftCardDirection) {
        applyDismissCardAnimation(with: direction)
    }

    // MARK - Override methods

    /**
    This method could be overwritten by all subclasses. Its notify each time the user drag the card through the
    screen with the percent (in range [0, 1]) from the origin point. By default do nothing
    - Parameter percent: shift percent at range [0, 1]
    - Parameter direction: direction mark by the user. If nil -> unknown / reset
    */
    open func cellPanShift(with percent: CGFloat, andDirection direction: ShiftCardDirection? = nil) {
        // to override
    }

    /**
    This method is called when cell try to reset its position to notify the current cell to perform an action
    - Parameter animationDuration: Duration for the animation
    */
    open func cellReset(animationDuration: Double) {
        // to override
    }
}

// MARK: Error
private enum ShiftCardError: Error {
    case noShiftDirection
}

// MARK: Animations

private extension ShiftCardViewCell {

    /**
    Execute the action when user end pan gesture. If state determine that the card is near of initial state, recover
    it, otherwise eject the card outside the stack and notify this case
    - Parameter translation: last drag user point using 'self' coordinate system
    */
    private func onUserEndPan(from translation: CGPoint) {
        guard getDragPercentage(from: translation) > shiftThreshold else {
            cellReset(animationDuration: AnimationDuration.reset.rawValue)
            delegate?.shiftCardCell(self, willEndShift: false, duration: AnimationDuration.reset.rawValue)
            resetCardLocation()
            return
        }

        guard let direction = try? getDragDirection(from: translation) else {
            cellReset(animationDuration: AnimationDuration.reset.rawValue)
            delegate?.shiftCardCell(self, willEndShift: false, duration: AnimationDuration.reset.rawValue)
            resetCardLocation()
            return
        }

        delegate?.shiftCardCell(self, willEndShift: true, duration: AnimationDuration.dismiss.rawValue)
        applyDismissCardAnimation(with: direction)
    }

    /**
    Apply the animation to the cell using the same way that when user drag (all items will be notified)
    - Parameter direction: The direction selected to dismiss the card
    */
    private func applyDismissCardAnimation(with direction: ShiftCardDirection) {
        removeAnimations()

        layer.removeAllAnimations()
        delegate?.shiftCardCell(self, willEndShift: true, duration: AnimationDuration.dismiss.rawValue)
        let destination = dismissAnimationDestination(for: direction)
        let rotationStrength = min(destination.x / frame.width, maxRotation)
        let rotationAngle = animationDirectionY * maxRotationAngle * rotationStrength

        var destinationTransform = CATransform3DIdentity
        destinationTransform = CATransform3DRotate(destinationTransform, rotationAngle, 0, 0, 1)
        destinationTransform = CATransform3DTranslate(destinationTransform, destination.x, destination.y, 0)

        let basicAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        basicAnimation.duration = AnimationDuration.dismiss.rawValue
        basicAnimation.delegate = self
        basicAnimation.fromValue = self.transform
        basicAnimation.toValue = destinationTransform
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        layer.add(basicAnimation, forKey: AnimationKeys.dismissCard.rawValue)
    }

    /**
    Return the destination point for the card that will be dismissed for the direction given. Destination is calculated
    based on the conversion of coordinates [-1, 1] to UIScreen coordinates with the formula:

        let x = 0.5 * (1 + self.x) * screenSize.width
        let y = 0.5 * (1 + self.y) * screenSize.height
        let result = (x, y)

    - Parameter direction: Dismiss direction that determine the destination point for the animation
    - Returns destination point (in screen coordinates)
    */
    private func dismissAnimationDestination(`for` direction: ShiftCardDirection) -> CGPoint {
        let screenSize = UIScreen.main.bounds.size
        let screenPointSize = CGPoint(x: screenSize.width, y: screenSize.height)

        let x: CGFloat = 1
        let y: CGFloat = 1

        switch direction {
        case .topLeft: return CGPoint(x: -x, y: -2*y) * screenPointSize
        case .top: return CGPoint(x: 0, y: (-3/2)*y) * screenPointSize
        case .topRight: return CGPoint(x: x, y: -2*y) * screenPointSize
        case .right: return CGPoint(x: (3/2)*x, y: -(1/3)*y) * screenPointSize
        case .bottomRight: return CGPoint(x: 2*x, y: y) * screenPointSize
        case .bottom: return CGPoint(x: 0, y: y) * screenPointSize
        case .bottomLeft: return CGPoint(x: -(7/2)*x, y: (1/2)*y) * screenPointSize
        case .left: return CGPoint(x: -(3/2)*x, y: -(1/2)*y) * screenPointSize
        }
    }

    /**
    Return the drag percentage status based on the location into the view
    - Parameter translation: reference point
    - Returns the percentage based on distance from translation in [0, 1]
    */
    private func getDragPercentage(from translation: CGPoint) -> CGFloat {
        guard let direction = try? getDragDirection(from: translation) else { return 0 }

        // Convert the point into coordinate system [-1, 1]
        let normalizedDragPoint = translation.normalizedDistanceForSize(bounds.size)

        // Project vector where user stop drag on the vector that normalize the direction
        // taken based on where user drag too
        let swipePoint = normalizedDragPoint.scalarProjection(over: direction.point)

        // Distance from user drag to the center
        let centerDistance = swipePoint.distanceTo(.zero)
        // Line that connects the user end drag point to the center
        let targetLine: CGLine = (swipePoint, CGPoint.zero)

        let percent = ShiftCardDirection
                        .coordinateRect
                        .perimeterLines
                        .compactMap { CGPoint.intersectionBetweenLines(targetLine, line2: $0) }
                        .map { centerDistance / $0.distanceTo(.zero) }
                        .min() ?? 0.0
        return min(percent, 1.0)
    }

    /**
     Return the drag direction based on the location of the translation.
     - Throw ShiftCardError.noShiftDirection if couldn't identify a direction
    */
    private func getDragDirection(from translation: CGPoint) throws -> ShiftCardDirection {
        // Convert the point into coordinate system [-1, 1]
        let normalizedDragPoint = translation.normalizedDistanceForSize(bounds.size)

        // Now we calculate the nearest distance to the normalized point based on [-1 | 0 | 1] coordinate system.
        typealias Closest = (distance: CGFloat, direction: ShiftCardDirection?)
        let initial: Closest = (CGFloat.infinity, nil)
        let result = ShiftCardDirection.allDirections.reduce(initial) { (closest: Closest, direction: ShiftCardDirection) -> Closest in
            let distance = direction.point.distanceTo(normalizedDragPoint)
            if distance < closest.distance {
                return (distance, direction)
            }
            return closest
        }

        if result.direction == nil {
            throw ShiftCardError.noShiftDirection
        }

        return result.direction!
    }

    /**
     Remove all animations from the layer
    */
    private func removeAnimations() {
        layer.removeAllAnimations()
    }

    /**
     Recover card to initial state into the view
     - Parameter animated: Indicate if this recover will perform with animation or not (default true)
     */
    private func resetCardLocation(animated: Bool = true) {
        removeAnimations()
        
        if !animated {
            layer.transform = CATransform3DIdentity
            return
        }

        let springAnimation = CASpringAnimation(keyPath: #keyPath(CALayer.transform))
        springAnimation.duration = AnimationDuration.reset.rawValue
        springAnimation.fromValue = layer.transform
        springAnimation.toValue = CATransform3DIdentity
        springAnimation.damping = 10
        springAnimation.stiffness = 100
        springAnimation.isRemovedOnCompletion = false
        springAnimation.fillMode = kCAFillModeRemoved
        springAnimation.delegate = self

        let key = AnimationKeys.resetCard.rawValue
        layer.add(springAnimation, forKey: key)
    }

}

extension ShiftCardViewCell: CAAnimationDelegate {

    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let isResetCardAnimation = anim === layer.animation(forKey: AnimationKeys.resetCard.rawValue)

        if isResetCardAnimation {
            layer.transform = CATransform3DIdentity
            delegate?.shiftCardCell(self, didEndShift: false)
            return
        }

        let isDismissCardAnimation = anim === layer.animation(forKey: AnimationKeys.dismissCard.rawValue)
        if isDismissCardAnimation {
            delegate?.shiftCardCell(self, didEndShift: true)
            return
        }
    }
}
