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

class SimpleHighlightCell: UITableViewCell {
    var imageInsets: UIEdgeInsets = UIEdgeInsetsZero
    var cellInsets: UIEdgeInsets = UIEdgeInsetsZero
    var imageREPLACE: UIImage? = nil {
        didSet {
            if let image = imageREPLACE {
                imageViewREPLACE.image = image
                imageViewREPLACE.contentMode = UIViewContentMode.ScaleAspectFit

                // Force nearest neighbor scaling for small favicons
                if image.size.width < SimpleHighlightCellUX.NearestNeighbordScalingThreshold {
                    imageViewREPLACE.layer.shouldRasterize = true
                    imageViewREPLACE.layer.rasterizationScale = 2
                    imageViewREPLACE.layer.minificationFilter = kCAFilterNearest
                    imageViewREPLACE.layer.magnificationFilter = kCAFilterNearest
                }

            } else {
                imageViewREPLACE.image = SimpleHighlightCellUX.PlaceholderImage
                imageViewREPLACE.contentMode = UIViewContentMode.Center
            }
        }
    }

    lazy var textLabelREPLACE: UILabel = {
        let textLabelREPLACE = UILabel()
        textLabelREPLACE.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        textLabelREPLACE.font = DynamicFontHelper.defaultHelper.DefaultMediumBoldFont
        textLabelREPLACE.textColor = SimpleHighlightCellUX.LabelColor
        textLabelREPLACE.textAlignment = SimpleHighlightCellUX.LabelAlignment
        textLabelREPLACE.numberOfLines = 2
        return textLabelREPLACE
    }()

    lazy var descriptionLabel: UILabel = {
        let textLabelREPLACE = UILabel()
        textLabelREPLACE.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        textLabelREPLACE.font = DynamicFontHelper.defaultHelper.DefaultSmallFont
        textLabelREPLACE.textColor = SimpleHighlightCellUX.LabelColor
        textLabelREPLACE.textAlignment = SimpleHighlightCellUX.LabelAlignment
        textLabelREPLACE.numberOfLines = 1
        return textLabelREPLACE
    }()

    lazy var timeStamp: UILabel = {
        let textLabelREPLACE = UILabel()
        textLabelREPLACE.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        textLabelREPLACE.font = DynamicFontHelper.defaultHelper.DefaultSmallFont
        textLabelREPLACE.textColor = SimpleHighlightCellUX.LabelColor
        textLabelREPLACE.textAlignment = .Right
        return textLabelREPLACE
    }()

    lazy var imageViewREPLACE: UIImageView = {
        let imageViewREPLACE = UIImageView()
        imageViewREPLACE.contentMode = UIViewContentMode.ScaleAspectFit

        imageViewREPLACE.clipsToBounds = true
        imageViewREPLACE.layer.cornerRadius = SimpleHighlightCellUX.CornerRadius
        return imageViewREPLACE
    }()

    lazy var statusIcon: UIImageView = {
        let imageViewREPLACE = UIImageView()
        imageViewREPLACE.contentMode = UIViewContentMode.ScaleAspectFit
        imageViewREPLACE.clipsToBounds = true
        imageViewREPLACE.layer.cornerRadius = SimpleHighlightCellUX.CornerRadius
        return imageViewREPLACE
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

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale

        isAccessibilityElement = true

        contentView.addSubview(imageViewREPLACE)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(selectedOverlay)
        contentView.addSubview(textLabelREPLACE)
        contentView.addSubview(timeStamp)
        contentView.addSubview(statusIcon)

        imageViewREPLACE.snp_makeConstraints { make in
            make.top.leading.equalTo(contentView).offset(10)
            make.size.equalTo(30)
        }

        selectedOverlay.snp_makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        textLabelREPLACE.snp_remakeConstraints { make in
            make.leading.equalTo(imageViewREPLACE.snp_trailing).offset(10)
            make.top.equalTo(imageViewREPLACE).offset(-2)
            make.width.equalTo(contentView.frame.width/1.3)
        }

        descriptionLabel.snp_makeConstraints { make in
            make.top.equalTo(textLabelREPLACE.snp_bottom)
            make.leading.equalTo(imageViewREPLACE.snp_trailing).offset(10)
            make.width.equalTo(textLabelREPLACE)
        }

        timeStamp.snp_makeConstraints { make in
            make.trailing.equalTo(contentView).inset(10)
            make.top.equalTo(descriptionLabel)
        }

        statusIcon.snp_makeConstraints { make in
            make.top.equalTo(textLabelREPLACE)
            make.trailing.equalTo(timeStamp)
        }
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textLabelREPLACE.font = DynamicFontHelper.defaultHelper.DefaultSmallFont
    }

    func setImageWithURL(url: NSURL) {
        imageViewREPLACE.sd_setImageWithURL(url) { (img, err, type, url) -> Void in
            guard let img = img else {
                return
            }
            self.imageREPLACE = img
        }
        imageViewREPLACE.layer.masksToBounds = true
    }
}
