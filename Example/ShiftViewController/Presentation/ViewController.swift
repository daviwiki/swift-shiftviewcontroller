//
//  ViewController.swift
//  ShiftViewController
//
//  Created by daviwiki on 08/15/2018.
//  Copyright (c) 2018 daviwiki. All rights reserved.
//

import UIKit
import ShiftViewController

protocol PlacesSelectorView: class {
    func showPlaces(places: [Location])
}

class ViewController: UIViewController, PlacesSelectorView {

    @IBOutlet private weak var bottomContainerView: UIView!

    private weak var shiftVC: ShiftCardViewController?
    private var presenter: PlacesSelectorPresenter = PlacesSelectorPresenterDefault()
    private var places: [Location] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        mountShiftViewController()
        presenter.bind(view: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.loadPlaces()
    }

    private func mountShiftViewController() {
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
        presenter.loadPlaces()
    }

    func showPlaces(places: [Location]) {
        self.places.removeAll()
        self.places.append(contentsOf: places)
        shiftVC?.reloadData()
    }

    @IBAction func onDislike(sender: UIButton) {
        shiftVC?.dimissCard(with: .left)
    }

    @IBAction func onLike(sender: UIButton) {
        shiftVC?.dimissCard(with: .right)
    }

    @IBAction func onSuperlike(sender: UIButton) {
        shiftVC?.dimissCard(with: .top)
    }

}

extension ViewController: ShiftCardViewDataSource {
    
    func noMoreCardsView(shiftController: ShiftCardViewController) -> UIView? {
        let emtpyView = EmptyView(frame: .zero)
        emtpyView.viewController = self
        return emtpyView
    }
    
    func numberOfCards(shiftController: ShiftCardViewController) -> Int {
        return places.count
    }
    
    func card(shiftController: ShiftCardViewController, forItemAtIndex index: Int) -> ShiftCardViewCell {
        let nib = UINib(nibName: "BeautifulPlacesShiftCell", bundle: Bundle.main)
        let cell = nib.instantiate(withOwner: nil, options: nil).first as! BeautifulPlacesShiftCell
        cell.show(location: places[index])
        return cell
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