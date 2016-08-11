/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

class ToolbarButton: UIButton {
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 40, height: 40)
    }
}

extension ToolbarButton {
    private static func createButton(imageNamed: String) -> ToolbarButton {
        let button = ToolbarButton()
        button.setImage(UIImage(named: imageNamed), forState: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}

extension ToolbarButton {
    static func backButton() -> ToolbarButton { return createButton("back") }
    static func forwardButton() -> ToolbarButton { return createButton("forward") }
    static func refreshButton() -> ToolbarButton { return createButton("refresh") }
    static func shareButton() -> ToolbarButton { return createButton("send") }
}
