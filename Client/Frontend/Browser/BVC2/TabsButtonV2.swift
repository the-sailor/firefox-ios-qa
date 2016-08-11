/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

class TabsButtonV2: UIView {
    let count: Int = 3
    private let countFont = UIFont.boldSystemFontOfSize(10)

    override init(frame: CGRect) {
        super.init(frame: frame)
        opaque = false
        clearsContextBeforeDrawing = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }

        let squareSize = CGSize(width: 18, height: 18)
        var containerFrame = CGRect(x: 0, y: 0, width: squareSize.width + 5, height: squareSize.height + 5)
        containerFrame.origin = CGPoint(
            x: (rect.width / 2) - (containerFrame.width / 2),
            y: (rect.height / 2) - (containerFrame.height / 2)
        )

        // Create frames for each of the paths we're going to draw and offset them to make sure they
        // all appear center within this view's rect.
        let backFrame = CGRect(x: 1, y: 1, width: squareSize.width, height: squareSize.height)
            .offsetBy(dx: containerFrame.origin.x, dy: containerFrame.origin.y)

        let cutFrame = CGRect(x: 3, y: 3, width: squareSize.width - 2, height: squareSize.height - 2)
            .offsetBy(dx: containerFrame.origin.x, dy: containerFrame.origin.y)

        let frontFrame = CGRect(x: 5, y: 5, width: squareSize.width, height: squareSize.height)
            .offsetBy(dx: containerFrame.origin.x, dy: containerFrame.origin.y)

        // Draw back box with a square cut out.
        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
        let backPath = UIBezierPath(roundedRect: backFrame, cornerRadius: 2)
        let squareCutPath = UIBezierPath(roundedRect: cutFrame, byRoundingCorners: [.TopLeft], cornerRadii: CGSize(width: 2, height: 2))
        backPath.appendPath(squareCutPath)
        backPath.usesEvenOddFillRule = true
        backPath.fill()

        // Draw front box
        let frontPath = UIBezierPath(roundedRect: frontFrame, cornerRadius: 2)
        frontPath.fill()

        // Draw text by subtracting text out of the front box to show background through.
        CGContextSetBlendMode(ctx, .DestinationOut)
        let nsCountText: NSString
        if count > 99 {
            nsCountText = NSString(string: "\u{221E}")
        } else {
            nsCountText = NSString(string: "\(count)")
        }

        let textAttributes = [NSFontAttributeName: countFont]
        var textRect = nsCountText.boundingRectWithSize(frontFrame.size, options: .UsesLineFragmentOrigin, attributes: textAttributes, context: nil)

        // Center label inside front button box.
        textRect.origin = CGPoint(
            x: frontFrame.origin.x + (frontFrame.width / 2) - (textRect.width / 2),
            y: frontFrame.origin.y + (frontFrame.height / 2) - (textRect.height / 2)
        )

        nsCountText.drawInRect(textRect, withAttributes: textAttributes)
    }
}
