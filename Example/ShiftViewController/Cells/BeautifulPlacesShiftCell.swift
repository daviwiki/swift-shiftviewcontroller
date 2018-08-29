//
// Created by David Martinez on 28/08/2018.
// Copyright (c) 2018 CocoaPods. All rights reserved.
//

import Foundation
import ShiftViewController
import SDWebImage

class BeautifulPlacesShiftCell: ShiftCardViewCell {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var veilContainerView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!

    @IBOutlet private weak var likeLabel: UILabel!
    @IBOutlet private weak var dislikeLabel: UILabel!
    @IBOutlet private weak var superlikeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = veilContainerView.bounds
        let gradientColors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.1).cgColor,
            UIColor.black.withAlphaComponent(0.1).cgColor,
            UIColor.black.withAlphaComponent(0.2).cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor,
        ]
        gradientLayer.colors = gradientColors
        veilContainerView.layer.addSublayer(gradientLayer)

        let colors = [UIColor.red, .blue, .yellow, .orange, .brown, .cyan, .gray, .green]
        let color = colors[Int(arc4random()) % colors.count]
        containerView.backgroundColor = color
        containerView.layer.cornerRadius = 6.0
        containerView.clipsToBounds = true
    }

    // MARK: Services
    func show(location: Location) {
        nameLabel.text = location.name
        countryLabel.text = location.country
        self.loadingView.startAnimating()
        photoImageView.sd_setImage(with: location.imageUrl) { image, error, type, url in
            self.loadingView.stopAnimating()
            self.photoImageView.image = image
        }
    }

    // MARK: Overrides

    override func cellPanShift(with percent: CGFloat, andDirection direction: ShiftCardDirection?) {
        guard let direction = direction else { return }
        switch direction {
        case .topLeft, .top, .topRight:
            setAlphaPercent(percent: percent, to: superlikeLabel)
        case .left, .bottomLeft:
            setAlphaPercent(percent: percent, to: dislikeLabel)
        case .right, .bottomRight:
            setAlphaPercent(percent: percent, to: likeLabel)
        default:
            break
        }
    }

    private func setAlphaPercent(percent: CGFloat, to label:UILabel) {
        [likeLabel, dislikeLabel, superlikeLabel].filter({ $0 != label })
            .forEach({ $0.alpha = 0 })
        label.alpha = percent
    }

    override func cellReset(animationDuration: Double) {
        UIView.animate(withDuration: animationDuration) { [unowned self] () -> Void in
            self.likeLabel.alpha = 0.0
            self.dislikeLabel.alpha = 0.0
            self.superlikeLabel.alpha = 0.0
        }
    }
}
