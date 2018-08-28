//
// Created by David Martinez on 28/08/2018.
// Copyright (c) 2018 CocoaPods. All rights reserved.
//

import Foundation
import ShiftViewController
import SDWebImage

class BeautifulPlacesShiftCell: ShiftCardViewCell {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()

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

    }

    override func cellReset(animationDuration: Double) {

    }
}
