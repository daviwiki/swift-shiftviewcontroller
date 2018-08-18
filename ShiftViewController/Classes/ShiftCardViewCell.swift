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
//            delegate?.didBeginSwipe(onView: self)
        case .changed:
            let rotationStrength = min(translation.x / frame.width, maxRotation)
            let rotationAngle = animationDirectionY * maxRotationAngle * rotationStrength
            var transform = CATransform3DIdentity
            transform = CATransform3DRotate(transform, rotationAngle, 0, 0, 1)
            transform = CATransform3DTranslate(transform, translation.x, translation.y, 0)
            layer.transform = transform
        case .ended:
            resetCardLocation()
            layer.shouldRasterize = false
        default:
            resetCardLocation()
            layer.shouldRasterize = false
        }

    }
}

// MARK: Animations

extension ShiftCardViewCell {

    private func removeAnimations() {
        layer.removeAllAnimations()
    }

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
