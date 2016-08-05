/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared

struct HighlightCellUX {
    /// Ratio of width:height of the thumbnail image.
    static let ImageAspectRatio: Float = 1.0
    static let BorderColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
    static let BorderWidth: CGFloat = 1
    static let LabelColor = UIAccessibilityDarkerSystemColorsEnabled() ? UIColor.blackColor() : UIColor(rgb: 0x353535)
    static let LabelBackgroundColor = UIColor(white: 1.0, alpha: 0.5)
    static let LabelAlignment: NSTextAlignment = .Center
    static let SelectedOverlayColor = UIColor(white: 0.0, alpha: 0.25)
    static let InsetSize: CGFloat = 20
    static let InsetSizeCompact: CGFloat = 6
    static func insetsForCollectionViewSize(size: CGSize, traitCollection: UITraitCollection) -> UIEdgeInsets {
        let largeInsets = UIEdgeInsets(
            top: HighlightCellUX.InsetSize,
            left: HighlightCellUX.InsetSize,
            bottom: HighlightCellUX.InsetSize,
            right: HighlightCellUX.InsetSize
        )
        let smallInsets = UIEdgeInsets(
            top: HighlightCellUX.InsetSizeCompact,
            left: HighlightCellUX.InsetSizeCompact,
            bottom: HighlightCellUX.InsetSizeCompact,
            right: HighlightCellUX.InsetSizeCompact
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
            top: HighlightCellUX.ImagePaddingWide,
            left: HighlightCellUX.ImagePaddingWide,
            bottom: HighlightCellUX.ImagePaddingWide,
            right: HighlightCellUX.ImagePaddingWide
        )

        let smallInsets = UIEdgeInsets(
            top: HighlightCellUX.ImagePaddingCompact,
            left: HighlightCellUX.ImagePaddingCompact,
            bottom: HighlightCellUX.ImagePaddingCompact,
            right: HighlightCellUX.ImagePaddingCompact
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

class HighlightCell: UICollectionViewCell {
    var imageInsets: UIEdgeInsets = UIEdgeInsetsZero
    var cellInsets: UIEdgeInsets = UIEdgeInsetsZero

//    var imagePadding: CGFloat = 0 {
//        didSet {
//            // Find out if our image is going to have fractional pixel width.
//            // If so, we inset by a tiny extra amount to get it down to an integer for better
//            // image scaling.
//            let parentWidth = self.imageWrapper.frame.width
//            let width = (parentWidth - imagePadding)
//            let fractionalW = width - floor(width)
//            let additionalW = fractionalW / 2
//
//            imageView.snp_remakeConstraints { make in
//                let insets = UIEdgeInsets(top: imagePadding, left: imagePadding, bottom: imagePadding, right: imagePadding)
//                make.top.equalTo(self.imageWrapper).inset(insets.top)
//                make.bottom.equalTo(textWrapper.snp_top).offset(-imagePadding)
//                make.left.equalTo(self.imageWrapper).inset(insets.left + additionalW)
//                make.right.equalTo(self.imageWrapper).inset(insets.right + additionalW)
//            }
//            imageView.setNeedsUpdateConstraints()
//        }
//    }

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
            make.top.equalTo(contentView)
            make.leading.equalTo(contentView)
            make.size.equalTo(30)
        }

        backgroundImage.snp_makeConstraints { make in
            make.top.leading.trailing.equalTo(contentView)
            make.bottom.equalTo(textLabel.snp_top)
        }

        selectedOverlay.snp_makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        textLabel.snp_remakeConstraints { make in
            make.leading.equalTo(contentView).offset(10)
            make.bottom.equalTo(descriptionLabel.snp_top)
        }

        // Prevents the textLabel from getting squished in relation to other view priorities.
        textLabel.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Vertical)

        timeStamp.snp_makeConstraints { make in
            make.leading.equalTo(descriptionLabel.snp_trailing)
            make.top.equalTo(descriptionLabel)
            make.trailing.equalTo(contentView)
        }

        descriptionLabel.snp_makeConstraints { make in
            make.top.equalTo(textLabel.snp_bottom)
            make.leading.equalTo(contentView).offset(10)
            make.bottom.equalTo(contentView)
        }

        statusIcon.snp_makeConstraints { make in
            make.leading.equalTo(textLabel.snp_trailing)
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
