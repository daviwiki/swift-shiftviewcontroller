//
//  ShiftCardViewCell.swift
//  ShiftCardViewController
//
//  Created by David Martinez on 15/08/2018.
//

import UIKit

open class ShiftCardViewCell: UIView {
    
    private var panGestureRecognizer: UIPanGestureRecognizer?
    
    private let maxRotation: CGFloat = 1.0
    private let animationDirectionY: CGFloat = 1.0
    private let maxRotationAngle: CGFloat = CGFloat(Double.pi) / 10.0
    
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
            // todo: notify begin swipe
            print("Being element animate")
        case .changed:
            let rotationStrength = min(translation.x / frame.width, maxRotation)
            let rotationAngle = animationDirectionY * maxRotationAngle * rotationStrength
            var transform = CATransform3DIdentity
            transform = CATransform3DRotate(transform, rotationAngle, 0, 0, 1)
            transform = CATransform3DTranslate(transform, translation.x, translation.y, 0)
            layer.transform = transform
            // todo: notify percent location
        case .ended:
            onUserEndPan(from: translation)
            layer.shouldRasterize = false
        default:
            // todo: notify end with recoveral
            resetCardLocation()
            layer.shouldRasterize = false
        }

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
        let swipeThreshold: CGFloat = 0.6
        guard getDragPercentage(from: translation) > swipeThreshold else {
            print("Recover the cell")
            resetCardLocation()
            return
        }

        // todo: notificar sacar elemento fuera
        print("Animate element outside the stack -> direction \(try! getDragDirection(from: translation))")
        resetCardLocation()
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

        return ShiftCardDirection
                .coordinateRect
                .perimeterLines
                .compactMap { CGPoint.intersectionBetweenLines(targetLine, line2: $0) }
                .map { centerDistance / $0.distanceTo(.zero) }
                .min() ?? 0.0
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
        layer.removeAllAnimations()
        
        if !animated {
            layer.transform = CATransform3DIdentity
            return
        }
        
        let springAnimation = CASpringAnimation(keyPath: #keyPath(CALayer.transform))
        springAnimation.duration = 1
        springAnimation.fromValue = layer.transform
        springAnimation.toValue = CATransform3DIdentity
        springAnimation.damping = 10
        springAnimation.stiffness = 100
        springAnimation.isRemovedOnCompletion = false
        springAnimation.fillMode = kCAFillModeForwards
        springAnimation.delegate = self
        
        let key = "resetCardLocation"
        layer.add(springAnimation, forKey: key)
    }

}

extension ShiftCardViewCell: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let propertyAnimation = anim as? CAPropertyAnimation else { return }
        if propertyAnimation.keyPath == #keyPath(CALayer.transform) {
            layer.transform = CATransform3DIdentity
        }
    }
}
