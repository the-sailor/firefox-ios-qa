//
//  TopSiteCell.swift
//  Client
//
//  Created by Farhan Patel on 7/29/16.
//  Copyright © 2016 Mozilla. All rights reserved.
//

import Foundation
import Shared
import WebImage

/*
 whats missing??
 long press gesture
 remove button
 select overlay (isnt that automatic)
 handle resuse
 cache dominant image color
 fonts
 handle failure cases for no favicon
 */

class TopSiteCell: UICollectionViewCell {
    var imageView: UIImageView!
    var titleLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        layer.cornerRadius = 4
        layer.masksToBounds = true

        titleLabel = UILabel()
        titleLabel.backgroundColor = UIColor.whiteColor()
        titleLabel.layer.masksToBounds = true
        titleLabel.textAlignment = .Center
        titleLabel.textColor = UIColor.blackColor()
        contentView.addSubview(titleLabel)

        titleLabel.snp_makeConstraints { (make) in
            //the titlelabel should take up the bottom 20 percent of the frame
            let heightInset = Int(frame.height * 0.8)
            make.edges.equalTo(self).inset(UIEdgeInsetsMake(CGFloat(heightInset), 0, 0, 0))
        }

        imageView = UIImageView()
        contentView.addSubview(imageView)
        imageView.snp_makeConstraints { (make) in
            make.height.equalTo(self.frame.height/2)
            make.width.equalTo(self.frame.width/2)
            make.center.equalTo(self.snp_center)
            //move it up a bit. Not centered correctly
        }
    }

    func setImageWithURL(url: NSURL) {
        self.backgroundColor = UIColor.whiteColor()
        self.contentView.backgroundColor = UIColor.whiteColor()
        imageView.sd_setImageWithURL(url) { (img, err, type, url) -> Void in
            guard let img = img else {
                return
            }
            //intensive. dont calculate here. this needs to be cached
            img.getColors { colors in
                self.contentView.backgroundColor = colors.backgroundColor
                self.backgroundColor = colors.backgroundColor
            }

        }
        imageView.layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}