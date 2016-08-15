/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared

struct SimpleHighlightCellUX {
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

class SimpleHighlightCell: UITableViewCell {
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
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(contentView).offset(5)
            make.size.equalTo(30)
            make.bottom.equalTo(contentView).offset(-10)
        }

        selectedOverlay.snp_makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        textLabelREPLACE.snp_remakeConstraints { make in
            make.leading.equalTo(imageViewREPLACE.snp_trailing).offset(10)
            make.top.equalTo(imageViewREPLACE).offset(-3)
            make.width.equalTo(contentView.frame.width/1.2)
        }

        descriptionLabel.snp_makeConstraints { make in
            make.top.equalTo(textLabelREPLACE.snp_bottom)
            make.leading.equalTo(imageViewREPLACE.snp_trailing).offset(10)
            make.width.equalTo(textLabelREPLACE)
            make.bottom.equalTo(imageViewREPLACE).offset(2)
        }

        timeStamp.snp_makeConstraints { make in
            make.trailing.equalTo(contentView).inset(5)
            make.bottom.equalTo(descriptionLabel)
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