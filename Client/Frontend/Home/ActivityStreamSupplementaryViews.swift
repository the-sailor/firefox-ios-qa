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

    override func layoutSubviews() {
        var squareFrame = CGRectMake(0, 0, self.frame.height, self.frame.height)
        squareFrame.center = self.frame.center
        self.contentView.frame = squareFrame
        self.contentView.backgroundColor = UIColor.whiteColor()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = UIColor.lightGrayColor().CGColor
        contentView.layer.borderWidth = 1


        titleLabel = UILabel()
        titleLabel.layer.masksToBounds = true
        titleLabel.textAlignment = .Center
        titleLabel.font = DynamicFontHelper.defaultHelper.DefaultSmallFontBold
        self.titleLabel.textColor = UIColor.blackColor()
        titleLabel.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.7)
        contentView.addSubview(titleLabel)

        let heightInset = Int(frame.height * 0.66)
        titleLabel.snp_makeConstraints { (make) in
            //the titlelabel should take up the bottom 33 percent of the frame
            make.edges.equalTo(self).inset(UIEdgeInsetsMake(CGFloat(heightInset), 0, 0, 0))
        }

        imageView = UIImageView()
        contentView.addSubview(imageView)
        imageView.snp_makeConstraints { (make) in
            make.height.equalTo(self.frame.height/2)
            make.width.equalTo(self.frame.height/2)
            let offset = Int(self.frame.height) - heightInset
            make.centerX.equalTo(self.snp_centerX)
            make.centerY.equalTo(self.snp_centerY).offset(CGFloat(-offset/2))
        }
    }

    override func prepareForReuse() {
        self.backgroundColor = UIColor.whiteColor()
        self.imageView.image = nil
        self.titleLabel.text = ""
        contentView.layer.borderColor = UIColor.lightGrayColor().CGColor


     //   self.contentView.backgroundColor = UIColor.whiteColor()
    }

    func setImageWithURL(url: NSURL) {

        imageView.sd_setImageWithURL(url) { (img, err, type, url) -> Void in
            guard let img = img else {
                return
            }
            img.getColors(CGSize(width: 50, height:50)) { colors in
                if colors.backgroundColor == UIColor.clearColor() {
                    self.contentView.backgroundColor = colors.primaryColor
                }
                else {
                    self.contentView.backgroundColor = colors.backgroundColor
                }

            }
        }
        imageView.layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//I need this becuause spacing is hard in flow layout
// http://stackoverflow.com/questions/13228600/uicollectionview-align-logic-missing-in-horizontal-paging-scrollview
//class ASVerticalySpacedLayout: UICollectionViewFlowLayout {
//    func collectionViewContentSize() -> CGSize {
//
//    }
//
////
//
//}

class ASHorizontalScrollCell: UITableViewCell {
    var collectionView: UICollectionView!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let layout  = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.minimumLineSpacing = 0
        self.backgroundColor = UIColor(white: 1.0, alpha: 0.5)

        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.registerClass(TopSiteCell.self, forCellWithReuseIdentifier: "TopSiteCell")
        collectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.pagingEnabled = true

        addSubview(collectionView)
        collectionView.snp_makeConstraints { make in
            make.edges.equalTo(self)
        }

    }


    func setDelegate(delegate: ASHorizontalScrollSource) {
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

class ASHorizontalScrollSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var content: [TopSiteItem] =  []
    var contentPerPage: Int = 1

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let perPage = Double(content.count) / Double(contentPerPage)
        if perPage != floor(perPage) {
           return contentPerPage * Int(ceil(perPage))
        }
        return content.count
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.row > content.count - 1 {
            return content[0].size
        }
        let contentItem = content[indexPath.row]
        return contentItem.size
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TopSiteCell", forIndexPath: indexPath) as! TopSiteCell
        //empty cell
        if indexPath.row > content.count - 1 {
            cell.contentView.layer.borderColor = UIColor.clearColor().CGColor

            return cell
        }
        //go through content and set stuff based on type of the struct provided
        let contentItem = content[indexPath.row]
        cell.titleLabel.text = contentItem.urlTitle
        cell.setImageWithURL(contentItem.faviconURL)
//        cell.backgroundColor = contentItem.backgroundColor
//        cell.titleLabel.textColor = contentItem.textColor
        return cell
    }


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