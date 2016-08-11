/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

@objc protocol URLInputFieldDelegate: class {
    func didSubmitText(text: String)
}

class URLInputField: UITextField {
    weak var urlDelegate: URLInputFieldDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        autocorrectionType = .No
        autocapitalizationType = .None

        layer.backgroundColor = UIColor.whiteColor().CGColor
        layer.cornerRadius = 4
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 2)
    }

    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 2)
    }
}

extension URLInputField: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        dispatch_async(dispatch_get_main_queue()) {
            self.selectedTextRange = self.textRangeFromPosition(self.beginningOfDocument, toPosition: self.endOfDocument)
        }
    }

    func textFieldDidEndEditing(textField: UITextField) {
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        urlDelegate?.didSubmitText(text ?? "")
        endEditing(true)
        return true
    }
}
