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

class HighlightCell: UITableViewCell {
    var imageREPLACE: UIImage? = nil {
        didSet {
            if let image = imageREPLACE {
                imageViewREPLACE.image = image
                imageViewREPLACE.contentMode = UIViewContentMode.ScaleAspectFit

                // Force nearest neighbor scaling for small favicons
                if image.size.width < HighlightCellUX.NearestNeighbordScalingThreshold {
                    imageViewREPLACE.layer.shouldRasterize = true
                    imageViewREPLACE.layer.rasterizationScale = 2
                    imageViewREPLACE.layer.minificationFilter = kCAFilterNearest
                    imageViewREPLACE.layer.magnificationFilter = kCAFilterNearest
                }

            } else {
                imageViewREPLACE.image = HighlightCellUX.PlaceholderImage
                imageViewREPLACE.contentMode = UIViewContentMode.Center
            }
        }
    }

    lazy var textLabelREPLACE: UILabel = {
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

    lazy var imageViewREPLACE: UIImageView = {
        let imageViewREPLACE = UIImageView()
        imageViewREPLACE.contentMode = UIViewContentMode.ScaleAspectFit

        imageViewREPLACE.clipsToBounds = true
        imageViewREPLACE.layer.cornerRadius = HighlightCellUX.CornerRadius
        return imageViewREPLACE
    }()

    lazy var statusIcon: UIImageView = {
        let imageViewREPLACE = UIImageView()
        imageViewREPLACE.contentMode = UIViewContentMode.ScaleAspectFit

        imageViewREPLACE.clipsToBounds = true
        imageViewREPLACE.layer.cornerRadius = HighlightCellUX.CornerRadius
        return imageViewREPLACE
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

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale

        isAccessibilityElement = true
        contentView.addSubview(selectedOverlay)
        contentView.addSubview(backgroundImage)
        contentView.addSubview(imageViewREPLACE)
        contentView.addSubview(textLabelREPLACE)
        contentView.addSubview(timeStamp)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(statusIcon)

        imageViewREPLACE.snp_makeConstraints { make in
            make.top.equalTo(backgroundImage)
            make.leading.equalTo(backgroundImage)
            make.size.equalTo(30)
        }

        backgroundImage.snp_makeConstraints { make in
            make.top.equalTo(contentView)
            make.leading.equalTo(contentView).offset(5)
            make.trailing.equalTo(contentView).inset(5)
        }

        selectedOverlay.snp_makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        textLabelREPLACE.snp_remakeConstraints { make in
            make.leading.equalTo(contentView).offset(10)
            make.top.equalTo(backgroundImage.snp_bottom).offset(5)
            make.width.equalTo(contentView.frame.width/1.2 + 15)
        }

        descriptionLabel.snp_makeConstraints { make in
            make.top.equalTo(textLabelREPLACE.snp_bottom)
            make.leading.equalTo(contentView).offset(10)
            make.bottom.equalTo(contentView).offset(-5)
            make.width.equalTo(contentView.frame.width/1.2 + 15)
        }

        timeStamp.snp_makeConstraints { make in
            make.trailing.equalTo(backgroundImage)
            make.top.equalTo(descriptionLabel)
        }

        statusIcon.snp_makeConstraints { make in
            make.top.equalTo(textLabelREPLACE)
            make.trailing.equalTo(backgroundImage)
        }
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundImage.image = nil
        textLabelREPLACE.font = DynamicFontHelper.defaultHelper.DefaultSmallFont
    }

    func setImageWithURL(url: NSURL) {
        imageViewREPLACE.sd_setImageWithURL(url) { (img, err, type, url) -> Void in
            guard let img = img else {
                return
            }
            self.imageREPLACE = img
        }
        backgroundImage.sd_setImageWithURL(NSURL(string: "http://lorempixel.com/640/480/?r=" + String(random())))
        imageViewREPLACE.layer.masksToBounds = true
    }
}