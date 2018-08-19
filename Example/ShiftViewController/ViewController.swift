//
//  ViewController.swift
//  ShiftViewController
//
//  Created by daviwiki on 08/15/2018.
//  Copyright (c) 2018 daviwiki. All rights reserved.
//

import UIKit
import ShiftViewController

class ViewController: UIViewController {

    private weak var shiftVC: ShiftCardViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = view.bounds.width * 0.8
        let height = view.bounds.height * 0.8
        let x = (view.bounds.width - width) / 2
        let y = (view.bounds.height - height) / 2
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        let shiftVC = ShiftCardViewController()
        addChildViewController(shiftVC)
        shiftVC.view.frame = frame
        shiftVC.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(shiftVC.view)
        didMove(toParentViewController: shiftVC)
        
        shiftVC.dataSource = self

        self.shiftVC = shiftVC
    }

    func reloadData() {
        shiftVC?.reloadData()
    }
}

extension ViewController: ShiftCardViewDataSource {
    
    func noMoreCardsView(shiftController: ShiftCardViewController) -> UIView? {
        let emtpyView = EmptyView(frame: .zero)
        emtpyView.viewController = self
        return emtpyView
    }
    
    func numberOfCards(shiftController: ShiftCardViewController) -> Int {
        return 5
    }
    
    func card(shiftController: ShiftCardViewController, forItemAtIndex index: Int) -> ShiftCardViewCell {
        return ViewCell()
    }
    
}

class ViewCell: ShiftCardViewCell {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(frame: .zero)
        clipsToBounds = true
        
        let colors = [UIColor.red, .blue, .yellow, .orange, .brown, .cyan, .gray, .green]
        let color = colors[Int(arc4random()) % colors.count]
        
        let contentView = UIView()
        contentView.backgroundColor = color
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 6.0
        contentView.layer.shadowRadius = 2.0
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor, constant: 8)
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        let leftConstraint = contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8)
        let rightConstraint = contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        rightConstraint.priority = UILayoutPriority(999)
        bottomConstraint.priority = UILayoutPriority(999)

        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leftConstraint, rightConstraint])

        layoutIfNeeded()
    }
    
}

class EmptyView: UIView {

    weak var viewController: ViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTap(gesture:)))
        self.addGestureRecognizer(gesture)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func onTap(gesture: UITapGestureRecognizer) {
        viewController?.reloadData()
    }
}