/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

struct LayoutMetrics {
    static let toolbarHeight: CGFloat = 44
    static let urlFieldHeight: CGFloat = 44
}

@available(iOS 9.0, *)
class ChromeView: UIView {
    private(set) var content: UIView?

    let toolbar: UIStackView = {
        let view = UIStackView.toolbar([
            .backButton(), .forwardButton(), .refreshButton(), .shareButton()
        ])
        view.distribution = .FillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let urlBar: URLBarViewV2 = {
        let view = URLBarViewV2()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let topThemeView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "fox"))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    private let curveBlurLayer = CAShapeLayer()

    private var toolbarBottomConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(toolbar)
        addSubview(topThemeView)
        addSubview(urlBar)

        NSLayoutConstraint.activateConstraints([
            topThemeView.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
            topThemeView.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
            topThemeView.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
            topThemeView.topAnchor.constraintEqualToAnchor(topAnchor),
            topThemeView.heightAnchor.constraintEqualToConstant(LayoutMetrics.urlFieldHeight + 20),

            urlBar.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
            urlBar.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
            urlBar.heightAnchor.constraintEqualToConstant(LayoutMetrics.urlFieldHeight),
            urlBar.bottomAnchor.constraintEqualToAnchor(topThemeView.bottomAnchor),

            toolbar.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
            toolbar.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
            toolbar.heightAnchor.constraintEqualToConstant(LayoutMetrics.toolbarHeight)
        ])

        toolbarBottomConstraint = toolbar.bottomAnchor.constraintEqualToAnchor(bottomAnchor)
        toolbarBottomConstraint?.active = true
    }

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if isWideTraitCollection(traitCollection) {
            toolbarBottomConstraint?.constant = 44
        } else {
            toolbarBottomConstraint?.constant = 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setContentView(view: UIView) {
        content = view
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        NSLayoutConstraint.activateConstraints([
            view.topAnchor.constraintEqualToAnchor(urlBar.bottomAnchor),
            view.bottomAnchor.constraintEqualToAnchor(toolbar.topAnchor),
            view.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
            view.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
        ])

        setNeedsLayout()
    }
}
