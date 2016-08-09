/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared

struct SimpleHighlightCellUX {
    /// Ratio of width:height of the thumbnail image.
    static let ImageAspectRatio: Float = 1.0
    static let BorderColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
    static let BorderWidth: CGFloat = 1
    static let LabelColor = UIAccessibilityDarkerSystemColorsEnabled() ? UIColor.blackColor() : UIColor(rgb: 0x353535)
    static let LabelBackgroundColor = UIColor(white: 1.0, alpha: 0.5)
    static let LabelAlignment: NSTextAlignment = .Left
    static let SelectedOverlayColor = UIColor(white: 0.0, alpha: 0.25)
    static let InsetSize: CGFloat = 20
    static let InsetSizeCompact: CGFloat = 6
    static func insetsForCollectionViewSize(size: CGSize, traitCollection: UITraitCollection) -> UIEdgeInsets {
        let largeInsets = UIEdgeInsets(
            top: SimpleHighlightCellUX.InsetSize,
            left: SimpleHighlightCellUX.InsetSize,
            bottom: SimpleHighlightCellUX.InsetSize,
            right: SimpleHighlightCellUX.InsetSize
        )
        let smallInsets = UIEdgeInsets(
            top: SimpleHighlightCellUX.InsetSizeCompact,
            left: SimpleHighlightCellUX.InsetSizeCompact,
            bottom: SimpleHighlightCellUX.InsetSizeCompact,
            right: SimpleHighlightCellUX.InsetSizeCompact
        )

        if traitCollection.horizontalSizeClass == .Compact {
            return smallInsets
        } else {
            return largeInsets
        }
    }

    static let ImagePaddingWide: CGFloat = 20
    static let ImagePaddingCompact: CGFloat = 10
    static func imageInsetsForCollectionViewSize(size: CGSize, traitCollection: UITraitCollection) -> UIEdgeInsets {
        let largeInsets = UIEdgeInsets(
            top: SimpleHighlightCellUX.ImagePaddingWide,
            left: SimpleHighlightCellUX.ImagePaddingWide,
            bottom: SimpleHighlightCellUX.ImagePaddingWide,
            right: SimpleHighlightCellUX.ImagePaddingWide
        )

        let smallInsets = UIEdgeInsets(
            top: SimpleHighlightCellUX.ImagePaddingCompact,
            left: SimpleHighlightCellUX.ImagePaddingCompact,
            bottom: SimpleHighlightCellUX.ImagePaddingCompact,
            right: SimpleHighlightCellUX.ImagePaddingCompact
        )
        if traitCollection.horizontalSizeClass == .Compact {
            return smallInsets
        } else {
            return largeInsets
        }
    }

    static let LabelInsets = UIEdgeInsetsMake(10, 3, 10, 3)
    static let PlaceholderImage = UIImage(named: "defaultTopSiteIcon")
    static let CornerRadius: CGFloat = 3

    // Make the remove button look 20x20 in size but have the clickable area be 44x44
    static let RemoveButtonSize: CGFloat = 44
    static let RemoveButtonInsets = UIEdgeInsets(top: 11, left: 11, bottom: 11, right: 11)
    static let RemoveButtonAnimationDuration: NSTimeInterval = 0.4
    static let RemoveButtonAnimationDamping: CGFloat = 0.6

    static let NearestNeighbordScalingThreshold: CGFloat = 24
}

class SimpleHighlightCell: UICollectionViewCell {
    var imageInsets: UIEdgeInsets = UIEdgeInsetsZero
    var cellInsets: UIEdgeInsets = UIEdgeInsetsZero

    var image: UIImage? = nil {
        didSet {
            if let image = image {
                imageView.image = image
                imageView.contentMode = UIViewContentMode.ScaleAspectFit

                // Force nearest neighbor scaling for small favicons
                if image.size.width < SimpleHighlightCellUX.NearestNeighbordScalingThreshold {
                    imageView.layer.shouldRasterize = true
                    imageView.layer.rasterizationScale = 2
                    imageView.layer.minificationFilter = kCAFilterNearest
                    imageView.layer.magnificationFilter = kCAFilterNearest
                }

            } else {
                imageView.image = SimpleHighlightCellUX.PlaceholderImage
                imageView.contentMode = UIViewContentMode.Center
            }
        }
    }

    lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        textLabel.font = DynamicFontHelper.defaultHelper.DefaultMediumBoldFont
        textLabel.textColor = SimpleHighlightCellUX.LabelColor
        textLabel.textAlignment = SimpleHighlightCellUX.LabelAlignment
        textLabel.numberOfLines = 2
        return textLabel
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

    lazy var timeStamp: UILabel = {
        let textLabel = UILabel()
        textLabel.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        textLabel.font = DynamicFontHelper.defaultHelper.DefaultSmallFont
        textLabel.textColor = SimpleHighlightCellUX.LabelColor
        textLabel.textAlignment = .Right
        return textLabel
    }()

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.ScaleAspectFit

        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = SimpleHighlightCellUX.CornerRadius
        return imageView
    }()

    lazy var statusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = SimpleHighlightCellUX.CornerRadius
        return imageView
    }()

    lazy var selectedOverlay: UIView = {
        let selectedOverlay = UIView()
        selectedOverlay.backgroundColor = SimpleHighlightCellUX.SelectedOverlayColor
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

        contentView.addSubview(imageView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(selectedOverlay)
        contentView.addSubview(textLabel)
        contentView.addSubview(timeStamp)
        contentView.addSubview(statusIcon)

        imageView.snp_makeConstraints { make in
            make.leading.equalTo(contentView)
            make.centerY.equalTo(contentView)
            make.size.equalTo(30)
        }

        selectedOverlay.snp_makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        textLabel.snp_remakeConstraints { make in
            make.leading.equalTo(imageView.snp_trailing).offset(10)
            make.top.equalTo(imageView)
            make.width.equalTo(contentView.frame.width/1.25)
        }

        // Prevents the textLabel from getting squished in relation to other view priorities.
        textLabel.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Vertical)

        descriptionLabel.snp_makeConstraints { make in
            make.top.equalTo(textLabel.snp_bottom)
            make.leading.equalTo(imageView.snp_trailing).offset(10)
            make.width.equalTo(textLabel)
        }

        timeStamp.snp_makeConstraints { make in
            make.trailing.equalTo(contentView)
            make.top.equalTo(descriptionLabel)
        }

        statusIcon.snp_makeConstraints { make in
            make.top.equalTo(textLabel)
            make.leading.equalTo(timeStamp).offset(4)
        }
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel.font = DynamicFontHelper.defaultHelper.DefaultSmallFont
    }

    func setImageWithURL(url: NSURL) {
        imageView.sd_setImageWithURL(url) { (img, err, type, url) -> Void in
            guard let img = img else {
                return
            }
            self.image = img
        }
        imageView.layer.masksToBounds = true
    }
}
