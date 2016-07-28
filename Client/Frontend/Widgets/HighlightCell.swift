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

@objc protocol HighlightCellDelegate {
    func didRemoveThumbnail(highlightCell: HighlightCell)
    func didLongPressThumbnail(highlightCell: HighlightCell)
}

class HighlightCell: UICollectionViewCell {
    weak var delegate: HighlightCellDelegate?

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

    lazy var longPressGesture: UILongPressGestureRecognizer = {
        return UILongPressGestureRecognizer(target: self, action: #selector(HighlightCell.SELdidLongPress))
    }()

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
        removeButton.addTarget(self, action: #selector(HighlightCell.SELdidRemove), forControlEvents: UIControlEvents.TouchUpInside)
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
        addGestureRecognizer(longPressGesture)

        contentView.addSubview(imageWrapper)
        imageWrapper.addSubview(backgroundImage)
        backgroundImage.snp_remakeConstraints { make in
            make.top.bottom.left.right.equalTo(self.imageWrapper)
        }
        imageWrapper.addSubview(imageView)
        imageWrapper.addSubview(textWrapper)
        imageWrapper.addSubview(selectedOverlay)
        textWrapper.addSubview(textLabel)
        textWrapper.addSubview(timeStamp)
        textWrapper.addSubview(statusText)
        textWrapper.addSubview(statusIcon)
        contentView.addSubview(removeButton)

        textWrapper.snp_makeConstraints { make in
            make.bottom.equalTo(self.imageWrapper.snp_bottom) // .offset(HighlightCellUX.BorderWidth)
            make.left.right.equalTo(self.imageWrapper) // .offset(HighlightCellUX.BorderWidth)
        }

        selectedOverlay.snp_makeConstraints { make in
            make.edges.equalTo(self.imageWrapper)
        }

        textLabel.snp_remakeConstraints { make in
            make.edges.equalTo(self.textWrapper).inset(HighlightCellUX.LabelInsets) // TODO swift-2.0 I changes insets to inset - how can that be right?
        }

        // Prevents the textLabel from getting squished in relation to other view priorities.
        textLabel.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Vertical)

        timeStamp.snp_makeConstraints { make in
            make.leading.equalTo(textLabel)
        }

        statusText.snp_makeConstraints { make in
            make.top.equalTo(textLabel.snp_bottom)
        }

        statusIcon.snp_makeConstraints { make in
            make.trailing.equalTo(statusText.snp_leading)
        }

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

    func SELdidRemove() {
        delegate?.didRemoveThumbnail(self)
    }


    func SELdidLongPress() {
        delegate?.didLongPressThumbnail(self)
    }

    func toggleRemoveButton(show: Bool) {
        // Only toggle if we change state
        if removeButton.hidden != show {
            return
        }

        if show {
            removeButton.hidden = false
        }

        let scaleTransform = CGAffineTransformMakeScale(0.01, 0.01)
        removeButton.transform = show ? scaleTransform : CGAffineTransformIdentity
        UIView.animateWithDuration(HighlightCellUX.RemoveButtonAnimationDuration,
                                   delay: 0,
                                   usingSpringWithDamping: HighlightCellUX.RemoveButtonAnimationDamping,
                                   initialSpringVelocity: 0,
                                   options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.CurveEaseInOut],
                                   animations: {
                                    self.removeButton.transform = show ? CGAffineTransformIdentity : scaleTransform
            }, completion: { _ in
                if !show {
                    self.removeButton.hidden = true
                }
        })
    }

    /**
     Updates the insets and padding of the cell based on the size of the container collection view

     - parameter size: Size of the container collection view
     */
    func updateLayoutForCollectionViewSize(size: CGSize, traitCollection: UITraitCollection, forSuggestedSite: Bool) {
        let cellInsets = HighlightCellUX.insetsForCollectionViewSize(size,
                                                                     traitCollection: traitCollection)
        let imageInsets = HighlightCellUX.imageInsetsForCollectionViewSize(size,
                                                                           traitCollection: traitCollection)

        if cellInsets != self.cellInsets {
            self.cellInsets = cellInsets
            imageWrapper.snp_remakeConstraints { make in
                make.edges.equalTo(self.contentView).inset(cellInsets)
            }
        }

        if forSuggestedSite {
            self.imagePadding = 0.0
            return
        }
        
        if imageInsets != self.imageInsets {
            imageView.snp_remakeConstraints { make in
                make.top.equalTo(self.imageWrapper).inset(imageInsets.top)
                make.left.right.equalTo(self.imageWrapper).inset(imageInsets.left)
                make.right.equalTo(self.imageWrapper).inset(imageInsets.right)
                make.bottom.equalTo(textWrapper.snp_top).offset(-imageInsets.top)
            }
        }
    }
}
