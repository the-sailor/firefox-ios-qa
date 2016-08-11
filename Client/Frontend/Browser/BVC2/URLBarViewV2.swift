/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import pop

public func isWideTraitCollection(traitCollection: UITraitCollection) -> Bool {
    return (traitCollection.horizontalSizeClass == .Compact && traitCollection.verticalSizeClass == .Compact) ||
           (traitCollection.horizontalSizeClass == .Regular)
}

@available(iOS 9.0, *)
extension UIStackView {
    static func toolbar(buttons: [ToolbarButton]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .Horizontal
        stackView.alignment = .Center
        stackView.spacing = 8
        return stackView
    }
}

@available(iOS 9.0, *)
class URLBarViewV2: UIView {
    private let backgroundCurve: CurveBackgroundView = {
        let view = CurveBackgroundView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let backButton: ToolbarButton = .backButton()
    let forwardButton: ToolbarButton = .forwardButton()
    let refreshButton: ToolbarButton = .refreshButton()
    let shareButton: ToolbarButton = .shareButton()

    let urlTextField: URLInputField = {
        let textField = URLInputField(frame: CGRect.zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    let tabButton: UIView = {
        let view = TabsButtonV2()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let cancelButton: UIView = {
        let view = UILabel()
        view.text = "Cancel"
        view.backgroundColor = .greenColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var leftToolbar: UIStackView = .toolbar([self.backButton, self.forwardButton])
    private lazy var rightToolbar: UIStackView = .toolbar([self.shareButton])

    private var toggled: Bool = false

    private var tabsTrailingConstraint: NSLayoutConstraint?
    private var urlFieldTrailingConstraint: NSLayoutConstraint?

    private var staticNarrowConstraints: [NSLayoutConstraint]!
    private var staticWideConstraints: [NSLayoutConstraint]!

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(backgroundCurve)
        addSubview(cancelButton)
        addSubview(urlTextField)
        addSubview(tabButton)
        addSubview(cancelButton)
        addSubview(leftToolbar)
        addSubview(rightToolbar)

        cancelButton.alpha = 0;

        staticWideConstraints = buildWideConstraints()
        staticNarrowConstraints = buildNarrowConstraints()

        tabsTrailingConstraint = tabButton.trailingAnchor.constraintEqualToAnchor(trailingAnchor, constant: -10)
        tabsTrailingConstraint?.active = true
    }

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        leftToolbar.hidden = !isWideTraitCollection(traitCollection)
        rightToolbar.hidden = !isWideTraitCollection(traitCollection)

        if isWideTraitCollection(traitCollection) {
            // 1. Deactivate previous constraints for narrow layout
            urlFieldTrailingConstraint?.active = false
            NSLayoutConstraint.deactivateConstraints(staticNarrowConstraints)

            // 2. Active static wide constraints
            NSLayoutConstraint.activateConstraints(staticWideConstraints)

            // 3. Setup priorities to resolve ambigious layouts
            leftToolbar.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
            leftToolbar.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)

            rightToolbar.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
            rightToolbar.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)

            // 4. Bind dynamic constraints for animations
            urlFieldTrailingConstraint = urlTextField.trailingAnchor.constraintEqualToAnchor(rightToolbar.leadingAnchor, constant: -10)
            urlFieldTrailingConstraint?.active = true

        } else {
            NSLayoutConstraint.deactivateConstraints(staticWideConstraints)
            NSLayoutConstraint.activateConstraints(staticNarrowConstraints)

            urlFieldTrailingConstraint = urlTextField.trailingAnchor.constraintEqualToAnchor(backgroundCurve.trailingAnchor, constant: -30)
            urlFieldTrailingConstraint?.active = true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: Static Constraints
@available(iOS 9.0, *)
private extension URLBarViewV2 {
    private func buildWideConstraints() -> [NSLayoutConstraint] {
        return [
            backgroundCurve.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
            backgroundCurve.trailingAnchor.constraintEqualToAnchor(tabButton.leadingAnchor),
            backgroundCurve.topAnchor.constraintEqualToAnchor(topAnchor),
            backgroundCurve.bottomAnchor.constraintEqualToAnchor(bottomAnchor),

            tabButton.widthAnchor.constraintEqualToConstant(30),
            tabButton.heightAnchor.constraintEqualToConstant(30),
            tabButton.centerYAnchor.constraintEqualToAnchor(centerYAnchor),

            leftToolbar.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
            leftToolbar.centerYAnchor.constraintEqualToAnchor(centerYAnchor),

            rightToolbar.trailingAnchor.constraintEqualToAnchor(backgroundCurve.trailingAnchor, constant: -30),
            rightToolbar.centerYAnchor.constraintEqualToAnchor(centerYAnchor),

            urlTextField.leadingAnchor.constraintEqualToAnchor(leftToolbar.trailingAnchor),
            urlTextField.centerYAnchor.constraintEqualToAnchor(centerYAnchor),
            urlTextField.heightAnchor.constraintEqualToConstant(30),

            cancelButton.trailingAnchor.constraintEqualToAnchor(backgroundCurve.trailingAnchor, constant: -30),
            cancelButton.centerYAnchor.constraintEqualToAnchor(centerYAnchor)
        ]
    }

    private func buildNarrowConstraints() -> [NSLayoutConstraint] {
        return [
            backgroundCurve.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
            backgroundCurve.trailingAnchor.constraintEqualToAnchor(tabButton.leadingAnchor),
            backgroundCurve.topAnchor.constraintEqualToAnchor(topAnchor),
            backgroundCurve.bottomAnchor.constraintEqualToAnchor(bottomAnchor),

            tabButton.widthAnchor.constraintEqualToConstant(30),
            tabButton.heightAnchor.constraintEqualToConstant(30),
            tabButton.centerYAnchor.constraintEqualToAnchor(centerYAnchor),

            urlTextField.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 10),
            urlTextField.centerYAnchor.constraintEqualToAnchor(centerYAnchor),
            urlTextField.heightAnchor.constraintEqualToConstant(30),

            cancelButton.trailingAnchor.constraintEqualToAnchor(backgroundCurve.trailingAnchor, constant: -30),
            cancelButton.centerYAnchor.constraintEqualToAnchor(centerYAnchor)
        ]
    }
}

// MARK: Animators
@available(iOS 9.0, *)
extension URLBarViewV2 {
    func tappedURLTextField() {
        toggled ? unselectURLTextField() : selectURLTextField()
        toggled = !toggled
    }

    func unselectURLTextField() {
        guard let moveTrailing = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant),
            let shrinkTextField = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant),
            let showCancel = POPBasicAnimation(propertyNamed: kPOPViewAlpha) else {
                return
        }
        moveTrailing.toValue = -10
        tabsTrailingConstraint?.pop_addAnimation(moveTrailing, forKey: "animate_trailing")

        shrinkTextField.toValue = -30
        urlFieldTrailingConstraint?.pop_addAnimation(shrinkTextField, forKey: "animate_trailing")

        showCancel.toValue = 0
        cancelButton.pop_addAnimation(showCancel, forKey: "show_cancel")
    }

    func selectURLTextField() {
        guard let moveTrailing = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant),
              let shrinkTextField = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant),
              let showCancel = POPBasicAnimation(propertyNamed: kPOPViewAlpha) else {
            return
        }
        moveTrailing.toValue = 40
        tabsTrailingConstraint?.pop_addAnimation(moveTrailing, forKey: "animate_trailing")

        shrinkTextField.toValue = -95
        urlFieldTrailingConstraint?.pop_addAnimation(shrinkTextField, forKey: "animate_trailing")

        showCancel.toValue = 1
        cancelButton.pop_addAnimation(showCancel, forKey: "show_cancel")
    }
}

