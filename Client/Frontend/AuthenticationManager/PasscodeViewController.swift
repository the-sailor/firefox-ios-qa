/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import SnapKit

private struct PasscodeUX {
    static let TitleVerticalSpacing: CGFloat = 32
    static let DigitSize: CGFloat = 30
    static let TopMargin: CGFloat = 80
    static let PaneSwipeDuration: NSTimeInterval = 0.3
    static let PasscodeFieldSize: CGSize = CGSize(width: 160, height: 32)
}

@objc protocol PasscodeInputViewDelegate: class {
    func passcodeInputView(inputView: PasscodeInputView, didFinishEnteringCode code: String)
}

/// A custom, keyboard-able view that displays the blank/filled digits when entrering a passcode.
class PasscodeInputView: UIView, UIKeyInput {
    weak var delegate: PasscodeInputViewDelegate?

    var digitFont: UIFont = UIConstants.PasscodeEntryFont

    var blankCharacter: Character = "-"

    var filledCharacter: Character = "•"

    private let passcodeSize: Int

    private var inputtedCode: String = ""

    private var blankDigitString: NSAttributedString {
        return NSAttributedString(string: "\(blankCharacter)", attributes: [NSFontAttributeName: digitFont])
    }

    private var filledDigitString: NSAttributedString {
        return NSAttributedString(string: "\(filledCharacter)", attributes: [NSFontAttributeName: digitFont])
    }

    @objc var keyboardType: UIKeyboardType = .NumberPad

    init(frame: CGRect, passcodeSize: Int) {
        self.passcodeSize = passcodeSize
        super.init(frame: frame)
        opaque = false
    }

    convenience init(passcodeSize: Int) {
        self.init(frame: CGRectZero, passcodeSize: passcodeSize)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    func resetCode() {
        inputtedCode = ""
        setNeedsDisplay()
    }

    @objc func hasText() -> Bool {
        return inputtedCode.characters.count > 0
    }

    @objc func insertText(text: String) {
        guard inputtedCode.characters.count < passcodeSize else {
            return
        }

        inputtedCode += text
        setNeedsDisplay()
        if inputtedCode.characters.count == passcodeSize {
            delegate?.passcodeInputView(self, didFinishEnteringCode: inputtedCode)
            resignFirstResponder()
        }
    }

    @objc func deleteBackward() {}

    override func drawRect(rect: CGRect) {
        let offset = floor(rect.width / CGFloat(passcodeSize))
        let size = CGSize(width: offset, height: rect.height)
        let containerRect = CGRect(origin: CGPointZero, size: size)
        // Chop up our rect into n containers and draw each digit centered inside.
        (0..<passcodeSize).forEach { index in
            let characterToDraw = index < inputtedCode.characters.count ? filledDigitString : blankDigitString
            var boundingRect = characterToDraw.boundingRectWithSize(size, options: [], context: nil)
            boundingRect.center = containerRect.center
            boundingRect = CGRectApplyAffineTransform(boundingRect, CGAffineTransformMakeTranslation(floor(CGFloat(index) * offset), 0))
            characterToDraw.drawInRect(boundingRect)
        }
    }
}

/// A pane that gets displayed inside the PasscodeViewController that displays a title and a passcode input field.
private class PasscodePane: UIView {
    let codeInputView = PasscodeInputView(passcodeSize: 4)

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIConstants.DefaultChromeFont
        return label
    }()

    private let centerContainer = UIView()

    init(title: String) {
        super.init(frame: CGRectZero)
        backgroundColor = UIConstants.TableViewHeaderBackgroundColor

        titleLabel.text = title
        centerContainer.addSubview(titleLabel)
        centerContainer.addSubview(codeInputView)
        addSubview(centerContainer)

        centerContainer.snp_makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(PasscodeUX.TopMargin)
        }

        titleLabel.snp_makeConstraints { make in
            make.centerX.equalTo(centerContainer)
            make.top.equalTo(centerContainer)
            make.bottom.equalTo(codeInputView.snp_top).offset(-PasscodeUX.TitleVerticalSpacing)
        }

        codeInputView.snp_makeConstraints { make in
            make.centerX.equalTo(centerContainer)
            make.bottom.equalTo(centerContainer)
            make.size.equalTo(PasscodeUX.PasscodeFieldSize)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/**
 Enum describing the three modes available for configuring the PasscodeViewController

 - NewPasscode:     User is setting up a new passcode. Requires input and confirmation panes.
 - EnterPasscode:   User is entering their passcode. A single pane is displayed asking for their code.
 - TurnOffPasscode: User is turning off passcode support so we display input and confirmation panes.
 */
enum PasscodeEntryType {
    case NewPasscode
    case EnterPasscode
    case TurnOffPasscode
}

/// Delegate available for PasscodeViewController consumers to be notified of the validation/entry of a passcode.
@objc protocol PasscodeEntryDelegate: class {
    func passcodeValidationDidSucceed()
    func passcodeValidationDidFail()
    func didCreateNewPasscode(passcode: String)
}

/// View controller which can be configured to manage creation, removal, and entering of a passcode.
class PasscodeViewController: UIViewController {
    weak var delegate: PasscodeEntryDelegate?

    private lazy var pager: UIScrollView  = {
        let scrollView = UIScrollView()
        scrollView.pagingEnabled = true
        scrollView.userInteractionEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private var panes = [PasscodePane]()
    private var confirmCode: String?
    private var currentPaneIndex: Int = 0

    private let passcodeEntryType: PasscodeEntryType

    init(passcodeEntryType: PasscodeEntryType) {
        self.passcodeEntryType = passcodeEntryType
        super.init(nibName: nil, bundle: nil)
        configureForType(passcodeEntryType)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIConstants.TableViewHeaderBackgroundColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("dismiss"))
        view.addSubview(pager)
        automaticallyAdjustsScrollViewInsets = false
        panes.forEach { pager.addSubview($0) }
        pager.snp_makeConstraints { make in
            make.bottom.left.right.equalTo(self.view)
            make.top.equalTo(self.snp_topLayoutGuideBottom)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        panes.enumerate().forEach { index, pane in
            pane.frame = CGRect(origin: CGPoint(x: CGFloat(index) * pager.frame.width, y: 0), size: pager.frame.size)
        }
        pager.contentSize = CGSize(width: CGFloat(panes.count) * pager.frame.width, height: pager.frame.height)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        panes.first?.codeInputView.delegate = self
        panes.first?.codeInputView.becomeFirstResponder()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    private func scrollToNextPane() {
        guard (currentPaneIndex + 1) < panes.count else {
            return
        }
        currentPaneIndex += 1
        scrollToPaneAtIndex(currentPaneIndex)
    }

    private func scrollToPreviousPane() {
        guard (currentPaneIndex - 1) >= 0 else {
            return
        }
        currentPaneIndex -= 1
        scrollToPaneAtIndex(currentPaneIndex)
    }

    private func scrollToPaneAtIndex(index: Int) {
        UIView.animateWithDuration(PasscodeUX.PaneSwipeDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.pager.contentOffset = CGPoint(x: CGFloat(self.currentPaneIndex) * self.pager.frame.width, y: 0)
        }, completion: nil)
    }

    private func configureForType(type: PasscodeEntryType) {
        let enterPasscode = NSLocalizedString("Enter a passcode", tableName: "AuthenticationManager", comment: "Title for entering a passcode")
        let reenterPasscode = NSLocalizedString("Re-enter passcode", tableName: "AuthenticationManager", comment: "Title for re-entering a passcode")
        let turnOffPasscode = NSLocalizedString("Turn Passcode Off", tableName: "AuthenticationManager", comment: "Title for setting to turn off passcode")
        let setPasscode = NSLocalizedString("Set Passcode", tableName: "AuthenticationManager", comment: "Screen title for Set Passcode")
        switch type {
        case .EnterPasscode:
            panes = [PasscodePane(title: enterPasscode)]
            title = enterPasscode
        case .NewPasscode:
            panes = [PasscodePane(title: enterPasscode), PasscodePane(title: reenterPasscode)]
            title = setPasscode
        case .TurnOffPasscode:
            panes = [PasscodePane(title: enterPasscode), PasscodePane(title: reenterPasscode)]
            title = turnOffPasscode
        }
    }

    @objc private func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension PasscodeViewController: PasscodeInputViewDelegate {
    func passcodeInputView(inputView: PasscodeInputView, didFinishEnteringCode code: String) {
        if passcodeEntryType == .EnterPasscode {
            if true {
                delegate?.passcodeValidationDidSucceed()
            } else {
                delegate?.passcodeValidationDidFail()
            }
        } else if currentPaneIndex == 0 {
            confirmCode = code
            scrollToNextPane()
            let nextPane = panes[currentPaneIndex]
            nextPane.codeInputView.becomeFirstResponder()
            nextPane.codeInputView.delegate = self
        } else if currentPaneIndex == 1 {
            if confirmCode == code {
                delegate?.didCreateNewPasscode(code)
            } else {
                scrollToPreviousPane()
                confirmCode = nil
                let previousPane = panes[currentPaneIndex]
                panes.forEach { $0.codeInputView.resetCode() }
                previousPane.codeInputView.becomeFirstResponder()
            }
        }
    }
}