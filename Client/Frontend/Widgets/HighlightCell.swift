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

    var imagePadding: CGFloat = 0 {
        didSet {
            // Find out if our image is going to have fractional pixel width.
            // If so, we inset by a tiny extra amount to get it down to an integer for better
            // image scaling.
            let parentWidth = self.imageWrapper.frame.width
            let width = (parentWidth - imagePadding)
            let fractionalW = width - floor(width)
            let additionalW = fractionalW / 2

            imageView.snp_remakeConstraints { make in
                let insets = UIEdgeInsets(top: imagePadding, left: imagePadding, bottom: imagePadding, right: imagePadding)
                make.top.equalTo(self.imageWrapper).inset(insets.top)
                make.bottom.equalTo(textWrapper.snp_top).offset(-imagePadding)
                make.left.equalTo(self.imageWrapper).inset(insets.left + additionalW)
                make.right.equalTo(self.imageWrapper).inset(insets.right + additionalW)
            }
            imageView.setNeedsUpdateConstraints()
        }
    }

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

    lazy var textWrapper: UIView = {
        let wrapper = UIView()
        wrapper.backgroundColor = HighlightCellUX.LabelBackgroundColor
        return wrapper
    }()

    lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        textLabel.font = DynamicFontHelper.defaultHelper.DefaultSmallFont
        textLabel.textColor = HighlightCellUX.LabelColor
        textLabel.textAlignment = HighlightCellUX.LabelAlignment
        return textLabel
    }()

    lazy var statusText: UILabel = {
        let textLabel = UILabel()
        textLabel.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        textLabel.font = DynamicFontHelper.defaultHelper.DefaultSmallFont
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

    lazy var imageWrapper: UIView = {
        let imageWrapper = UIView()
        imageWrapper.layer.borderColor = HighlightCellUX.BorderColor.CGColor
        imageWrapper.layer.borderWidth = HighlightCellUX.BorderWidth
        imageWrapper.layer.cornerRadius = HighlightCellUX.CornerRadius
        imageWrapper.clipsToBounds = true
        return imageWrapper
    }()

    lazy var removeButton: UIButton = {
        let removeButton = UIButton()
        removeButton.exclusiveTouch = true
        removeButton.setImage(UIImage(named: "TileCloseButton"), forState: UIControlState.Normal)
        removeButton.accessibilityLabel = NSLocalizedString("Remove page", comment: "Button shown in editing mode to remove this site from the top sites panel.")
        removeButton.hidden = true
        removeButton.imageEdgeInsets = HighlightCellUX.RemoveButtonInsets
        return removeButton
    }()

    lazy var backgroundImage: UIImageView = {
        let backgroundImage = UIImageView()
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
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

        contentView.addSubview(imageWrapper)
        contentView.addSubview(textWrapper)
        imageWrapper.addSubview(backgroundImage)
        imageWrapper.addSubview(imageView)
        imageWrapper.addSubview(selectedOverlay)
        textWrapper.addSubview(textLabel)
        textWrapper.addSubview(timeStamp)
        textWrapper.addSubview(statusText)
        textWrapper.addSubview(statusIcon)
        contentView.addSubview(removeButton)

        imageView.snp_makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(contentView).offset(10)
            make.size.equalTo(30)
            //move it up a bit. Not centered correctly
        }
        textWrapper.snp_makeConstraints { make in
            make.left.right.bottom.equalTo(self.contentView)
            make.top.equalTo(imageWrapper.snp_bottom)
        }

        imageWrapper.snp_makeConstraints { make in
            make.top.left.right.equalTo(self.contentView)
            make.bottom.equalTo(textWrapper.snp_top)
        }

        backgroundImage.snp_makeConstraints { make in
            make.edges.equalTo(self.imageWrapper)
        }
//        selectedOverlay.snp_makeConstraints { make in
//            make.edges.equalTo(self.imageWrapper)
//        }

        textLabel.snp_remakeConstraints { make in
            make.leading.equalTo(textWrapper) // TODO swift-2.0 I changes insets to inset - how can that be right?
            make.trailing.equalTo(timeStamp.snp_leading)
            make.bottom.equalTo(statusText.snp_top)
        }

        // Prevents the textLabel from getting squished in relation to other view priorities.
        textLabel.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Vertical)

        timeStamp.snp_makeConstraints { make in
            make.leading.equalTo(textLabel.snp_trailing)
            make.top.equalTo(textLabel)
            make.trailing.equalTo(contentView)
        }

        statusText.snp_makeConstraints { make in
            make.top.equalTo(textLabel.snp_bottom)
            make.bottom.equalTo(textWrapper)
        }

//        statusIcon.snp_makeConstraints { make in
//            make.trailing.equalTo(statusText.snp_leading)
//        }
    }



    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // TODO: We can avoid creating this button at all if we're not in editing mode.
        var frame = removeButton.frame
        let insets = cellInsets
        frame.size = CGSize(width: HighlightCellUX.RemoveButtonSize, height: HighlightCellUX.RemoveButtonSize)
        frame.center = CGPoint(x: insets.left, y: insets.top)
        removeButton.frame = frame
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundImage.image = nil
        removeButton.hidden = true
        imageWrapper.backgroundColor = UIColor.clearColor()
        textLabel.font = DynamicFontHelper.defaultHelper.DefaultSmallFont
    }

    func setImageWithURL(url: NSURL) {
        imageView.sd_setImageWithURL(url) { (img, err, type, url) -> Void in
            guard let img = img else {
                return
            }
//            img.getColors { colors in
//                self.backgroundImage.backgroundColor = colors.backgroundColor
//            }
            self.image = img
        }
        imageView.layer.masksToBounds = true
    }
}
