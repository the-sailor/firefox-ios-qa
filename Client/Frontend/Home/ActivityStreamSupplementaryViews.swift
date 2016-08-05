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
        titleLabel.layer.masksToBounds = true
        titleLabel.textAlignment = .Center
        titleLabel.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.5)
        titleLabel.font = DynamicFontHelper.defaultHelper.DefaultSmallFontBold
        contentView.addSubview(titleLabel)

        let heightInset = Int(frame.height * 0.8)
        titleLabel.snp_makeConstraints { (make) in
            //the titlelabel should take up the bottom 20 percent of the frame
            make.edges.equalTo(self).inset(UIEdgeInsetsMake(CGFloat(heightInset), 0, 0, 0))
        }

        imageView = UIImageView()
        contentView.addSubview(imageView)
        imageView.snp_makeConstraints { (make) in
            make.height.equalTo(self.frame.height/2)
            make.width.equalTo(self.frame.width/2)
            let offset = Int(self.frame.height) - heightInset
            make.centerX.equalTo(self.snp_centerX)
            make.centerY.equalTo(self.snp_centerY).offset(CGFloat(-offset/2))
        }
    }

    override func prepareForReuse() {
        self.backgroundColor = UIColor.whiteColor()
        self.contentView.backgroundColor = UIColor.whiteColor()
        titleLabel.textColor = UIColor.blackColor()
    }

    func setImageWithURL(url: NSURL) {
        imageView.sd_setImageWithURL(url) { (img, err, type, url) -> Void in
            guard let img = img else {
                return
            }
            img.getColors(CGSize(width: 50, height:50)) { colors in
                self.contentView.backgroundColor = colors.backgroundColor
                self.backgroundColor = colors.backgroundColor
                self.titleLabel.textColor = colors.detailColor
            }
        }
        imageView.layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ASVerticalScrollCell: UICollectionViewCell {
    var collectionView: UICollectionView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        let layout  = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.itemSize = CGSize(width: 100, height: 100)

        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.registerClass(TopSiteCell.self, forCellWithReuseIdentifier: "TopSiteCell")
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.pagingEnabled = true

        addSubview(collectionView)
        collectionView.snp_makeConstraints { make in
            make.edges.equalTo(self)
        }
    }


    func setDelegate(delegate: ASVerticalScrollSource) {
        collectionView.delegate = delegate
        collectionView.dataSource = delegate
        collectionView.reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//both should conform to a protocol. Where the title is given. and the image is given? and other basic stuff is given
//this will allow both to work in the ASVerticalScrollSource
struct TopSiteItem {
    let urlTitle: String
    let faviconURL: NSURL
    let backgroundColor: UIColor
    let textColor: UIColor
    let size: CGSize
}

struct ASAction {
    let title: String
    let image: UIImage
}

class ASVerticalScrollSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var content: [TopSiteItem] =  []

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let contentItem = content[indexPath.row]
        return contentItem.size
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TopSiteCell", forIndexPath: indexPath) as! TopSiteCell
        //go through content and set stuff based on type of the struct provided
        let contentItem = content[indexPath.row]
        cell.titleLabel.text = contentItem.urlTitle
        cell.setImageWithURL(contentItem.faviconURL)
//        cell.backgroundColor = contentItem.backgroundColor
//        cell.titleLabel.textColor = contentItem.textColor
        return cell
    }

//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return 22
//    }


}


class ActivityStreamHeaderView: UICollectionReusableView {
    var titleLabel: UILabel!
    var moreLabel: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel = UILabel()
        titleLabel.font = DynamicFontHelper.defaultHelper.DefaultMediumFont
        addSubview(titleLabel)

        titleLabel.snp_makeConstraints {(make) in
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.left.equalTo(self.snp_left).offset(5)
            make.centerY.equalTo(self.snp_centerY)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}