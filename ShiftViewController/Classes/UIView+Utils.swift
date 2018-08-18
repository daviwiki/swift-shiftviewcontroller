//
//  UIView+Utils.swift
//  ShiftViewController
//
//  Created by David Martinez on 15/08/2018.
//

import UIKit

extension UIView {
    
    internal func edgeConstraintsTo(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
}
