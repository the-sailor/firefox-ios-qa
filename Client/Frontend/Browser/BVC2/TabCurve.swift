/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

class CurveBackgroundView: UIView {
    private let curveLayer = CAShapeLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        opaque = false
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setDefaults()
        curveLayer.fillColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.8).CGColor
        curveLayer.backgroundFilters = [blurFilter]
        layer.addSublayer(curveLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        curveLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        curveLayer.path = UIBezierPath.tabCurvePath(frame.width, height: bounds.height, direction: .right).CGPath
        curveLayer.backgroundFilters = [CIFilter(name: "CIGaussianBlur")!]
        curveLayer.setNeedsDisplay()
    }
}

enum TabCurveDirection {
    case right
    case left
    case both
}

extension UIBezierPath {
    static func tabCurvePath(width: CGFloat, height: CGFloat, direction: TabCurveDirection) -> UIBezierPath {
        let x1: CGFloat = 32.84
        let x2: CGFloat = 5.1
        let x3: CGFloat = 19.76
        let x4: CGFloat = 58.27
        let x5: CGFloat = -12.15

        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: width, y: height))
        switch direction {
        case .right:
            bezierPath.addCurveToPoint(CGPoint(x: width-x1, y: 0), controlPoint1: CGPoint(x: width-x3, y: height), controlPoint2: CGPoint(x: width-x2, y: 0))
            bezierPath.addCurveToPoint(CGPoint(x: 0, y: 0), controlPoint1: CGPoint(x: 0, y: 0), controlPoint2: CGPoint(x: 0, y: 0))
            bezierPath.addCurveToPoint(CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: 0, y: height), controlPoint2: CGPoint(x: 0, y: height))
            bezierPath.addCurveToPoint(CGPoint(x: width, y: height), controlPoint1: CGPoint(x: x5, y: height), controlPoint2: CGPoint(x: width-x5, y: height))
        case .left:
            bezierPath.addCurveToPoint(CGPoint(x: width, y: 0), controlPoint1: CGPoint(x: width, y: 0), controlPoint2: CGPoint(x: width, y: 0))
            bezierPath.addCurveToPoint(CGPoint(x: x1, y: 0), controlPoint1: CGPoint(x: width-x4, y: 0), controlPoint2: CGPoint(x: x4, y: 0))
            bezierPath.addCurveToPoint(CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: x2, y: 0), controlPoint2: CGPoint(x: x3, y: height))
            bezierPath.addCurveToPoint(CGPoint(x: width, y: height), controlPoint1: CGPoint(x: width, y: height), controlPoint2: CGPoint(x: width, y: height))
        case .both:
            bezierPath.addCurveToPoint(CGPoint(x: width-x1, y: 0), controlPoint1: CGPoint(x: width-x3, y: height), controlPoint2: CGPoint(x: width-x2, y: 0))
            bezierPath.addCurveToPoint(CGPoint(x: x1, y: 0), controlPoint1: CGPoint(x: width-x4, y: 0), controlPoint2: CGPoint(x: x4, y: 0))
            bezierPath.addCurveToPoint(CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: x2, y: 0), controlPoint2: CGPoint(x: x3, y: height))
            bezierPath.addCurveToPoint(CGPoint(x: width, y: height), controlPoint1: CGPoint(x: x5, y: height), controlPoint2: CGPoint(x: width-x5, y: height))
        }
        bezierPath.closePath()
        bezierPath.miterLimit = 4;
        return bezierPath
    }
}
