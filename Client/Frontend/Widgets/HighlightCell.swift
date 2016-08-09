/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared

struct HighlightCellUX {
    static let BorderColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
    static let BorderWidth: CGFloat = 1
    static let LabelColor = UIAccessibilityDarkerSystemColorsEnabled() ? UIColor.blackColor() : UIColor(rgb: 0x353535)
    static let LabelBackgroundColor = UIColor(white: 1.0, alpha: 0.5)
    static let LabelAlignment: NSTextAlignment = .Left
    static let SelectedOverlayColor = UIColor(white: 0.0, alpha: 0.25)
    static let PlaceholderImage = UIImage(named: "defaultTopSiteIcon")
    static let CornerRadius: CGFloat = 3
    static let NearestNeighbordScalingThreshold: CGFloat = 24
}

class HighlightCell: UICollectionViewCell {
    var image: UIImage? = nil {
        didSet {
            if let image = image {
                imageView.image = image
                imageView.contentMode = UIViewContentMode.ScaleAspectFit

                // Force nearest neighbor scaling for small favicons
                if image.size.width < HighlightCellUX.NearestNeighbordScalingThreshold {
                    imageView.layer.shouldRasterize = true
                    imageView.layer.rasterizationScale = 2
                    imageView.layer.minificationFilter = kCAFilterNearest
                    imageView.layer.magnificationFilter = kCAFilterNearest
                }

            } else {
                imageView.image = HighlightCellUX.PlaceholderImage
                imageView.contentMode = UIViewContentMode.Center
            }
        }
    }

    lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        textLabel.font = DynamicFontHelper.defaultHelper.DefaultMediumBoldFont
        textLabel.textColor = HighlightCellUX.LabelColor
        textLabel.textAlignment = HighlightCellUX.LabelAlignment
        textLabel.numberOfLines = 2
        return textLabel
    }()

    lazy var timeStamp: UILabel = {
        let textLabel = UILabel()
        textLabel.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        textLabel.font = DynamicFontHelper.defaultHelper.DefaultSmallFont
        textLabel.textColor = HighlightCellUX.LabelColor
        textLabel.textAlignment = HighlightCellUX.LabelAlignment
        return textLabel
    }()

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.ScaleAspectFit

        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = HighlightCellUX.CornerRadius
        return imageView
    }()

    lazy var statusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.ScaleAspectFit

        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = HighlightCellUX.CornerRadius
        return imageView
    }()

    lazy var descriptionLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        textLabel.font = DynamicFontHelper.defaultHelper.DefaultSmallFont
        textLabel.textColor = SimpleHighlightCellUX.LabelColor
        textLabel.textAlignment = SimpleHighlightCellUX.LabelAlignment
        textLabel.numberOfLines = 1
        return textLabel
    }()

    lazy var backgroundImage: UIImageView = {
        let backgroundImage = UIImageView()
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
        backgroundImage.layer.borderColor = HighlightCellUX.BorderColor.CGColor
        backgroundImage.layer.borderWidth = HighlightCellUX.BorderWidth
        backgroundImage.layer.cornerRadius = HighlightCellUX.CornerRadius
        backgroundImage.clipsToBounds = true
        return backgroundImage
    }()

    lazy var selectedOverlay: UIView = {
        let selectedOverlay = UIView()
        selectedOverlay.backgroundColor = HighlightCellUX.SelectedOverlayColor
        selectedOverlay.hidden = true
        return selectedOverlay
    }()

    override var selected: Bool {
        didSet {
            self.selectedOverlay.hidden = !selected
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale

        isAccessibilityElement = true
        contentView.addSubview(selectedOverlay)
        contentView.addSubview(backgroundImage)
        contentView.addSubview(imageView)
        contentView.addSubview(textLabel)
        contentView.addSubview(timeStamp)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(statusIcon)

        imageView.snp_makeConstraints { make in
            make.top.equalTo(backgroundImage)
            make.leading.equalTo(backgroundImage)
            make.size.equalTo(35)
        }

        backgroundImage.snp_makeConstraints { make in
            make.top.equalTo(contentView)
            make.leading.equalTo(contentView).offset(10)
            make.trailing.equalTo(contentView).inset(10)
        }

        selectedOverlay.snp_makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        textLabel.snp_remakeConstraints { make in
            make.leading.equalTo(contentView).offset(10)
            make.top.equalTo(backgroundImage.snp_bottom).offset(5)
            make.width.equalTo(contentView.frame.width/1.25 + imageView.frame.width)
        }

        descriptionLabel.snp_makeConstraints { make in
            make.top.equalTo(textLabel.snp_bottom)
            make.leading.equalTo(contentView).offset(10)
            make.bottom.equalTo(contentView).offset(-5)
            make.width.equalTo(textLabel)
        }

        timeStamp.snp_makeConstraints { make in
            make.trailing.equalTo(backgroundImage)
            make.top.equalTo(descriptionLabel)
        }

        statusIcon.snp_makeConstraints { make in
            make.top.equalTo(textLabel)
            make.trailing.equalTo(backgroundImage)
        }
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundImage.image = nil
        textLabel.font = DynamicFontHelper.defaultHelper.DefaultSmallFont
    }

    func setImageWithURL(url: NSURL) {
        imageView.sd_setImageWithURL(url) { (img, err, type, url) -> Void in
            guard let img = img else {
                return
            }
            self.image = img
        }
        backgroundImage.sd_setImageWithURL(NSURL(string: "http://lorempixel.com/640/480/?r=" + String(random())))
        imageView.layer.masksToBounds = true
    }
}
