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
        //using autolayout on the contentView does not seem to work
        var squareFrame = CGRectMake(0, 0, self.frame.height, self.frame.height)
        squareFrame.center = self.frame.center
        self.contentView.frame = squareFrame
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
        titleLabel.font = DynamicFontHelper.defaultHelper.DefaultSmallFont
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.7)
        contentView.addSubview(titleLabel)

        let heightInset = Int(frame.height * 0.66)
        titleLabel.snp_makeConstraints { (make) in
            //the titlelabel should take up the bottom 33 percent of the frame
            make.edges.equalTo(self).inset(UIEdgeInsetsMake(CGFloat(heightInset), 0, 0, 0))
        }

        imageView = UIImageView()
        imageView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        imageView.snp_makeConstraints { (make) in
            make.height.equalTo(self.frame.height/2)
            make.width.equalTo(self.frame.height/2)

            // Add an offset to the image to make it appear centered with the titleLabel
            let offset = Int(self.frame.height) - heightInset
            make.centerX.equalTo(self.snp_centerX)
            make.centerY.equalTo(self.snp_centerY).offset(CGFloat(-offset/2))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        self.backgroundColor = UIColor.whiteColor()
        self.imageView.image = nil
        self.titleLabel.text = ""
        contentView.layer.borderColor = UIColor.lightGrayColor().CGColor
    }

    func setImageWithURL(url: NSURL) {
        imageView.sd_setImageWithURL(url) { (img, err, type, url) -> Void in
            guard let img = img else {
                // No favicon found. Do something!
                return
            }

            img.getColors(CGSize(width: 50, height:50)) { colors in
                //In cases where the background is white. Force the background color to a different color
                if colors.backgroundColor.isEqualToColorRGBA(UIColor.whiteColor()) {
                    self.contentView.backgroundColor = colors.primaryColor
                }
                else {
                    self.contentView.backgroundColor = colors.backgroundColor
                }

            }
        }
    }

}

/**
 Extracts the RGBA values of the colors and check if the are the same.
 http://stackoverflow.com/a/38324700
 */

extension UIColor {
    public func isEqualToColorRGBA(color : UIColor) -> Bool {
        //local type used for holding converted color values
        typealias colorType = (red : CGFloat, green : CGFloat, blue : CGFloat, alpha : CGFloat)
        var myColor         : colorType = (0,0,0,0)
        var otherColor      : colorType = (0,0,0,0)
        //getRed returns true if color could be converted so if one of them failed we assume that colors are not equal
        guard getRed(&myColor.red, green: &myColor.green, blue: &myColor.blue, alpha: &myColor.alpha) &&
            color.getRed(&otherColor.red, green: &otherColor.green, blue: &otherColor.blue, alpha: &otherColor.alpha)
            else {
                return false
        }
        //as of Swift 2.2 (Xcode 7.3.1), tuples up to arity 6 can be compared with == so this works nicely
        return myColor == otherColor
    }
}



class ASHorizontalScrollCell: UITableViewCell {
    var collectionView: UICollectionView!
    var pageControl: UIPageControl!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let layout  = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        self.backgroundColor = UIColor(white: 1.0, alpha: 0.5)

        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.registerClass(TopSiteCell.self, forCellWithReuseIdentifier: "TopSiteCell")
        collectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.pagingEnabled = true

        contentView.addSubview(collectionView)
        collectionView.snp_makeConstraints { make in
            make.edges.equalTo(contentView).offset(UIEdgeInsetsMake(18, 0, 0, 0))
            make.height.equalTo(100)
        }

        pageControl = UIPageControl()
        pageControl.numberOfPages = 2
        pageControl.pageIndicatorTintColor = UIColor.grayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.darkGrayColor()
//        pageControl.backgroundColor = UIColor.redColor()
        contentView.addSubview(pageControl)
        pageControl.snp_makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(20)
            make.top.equalTo(contentView)
            make.trailing.equalTo(self.snp_trailing).offset(-5)
        }

        let titleLabel = UILabel()
        titleLabel.text = "TOP SITES"
        titleLabel.textColor = UIColor.grayColor()
        titleLabel.font = DynamicFontHelper.defaultHelper.DefaultSmallFont
        contentView.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { make in
            make.height.equalTo(pageControl.snp_height)
            make.leading.equalTo(self.snp_leading).offset(10)
            make.width.equalTo(100)
        }

        let seperatorLine = UIView()
        seperatorLine.backgroundColor = UIColor.lightGrayColor()
        contentView.addSubview(seperatorLine)
        seperatorLine.snp_makeConstraints { make in
            make.height.equalTo(1)
            make.width.equalTo(self.snp_width).offset(5)
            make.leading.equalTo(self.snp_leading).offset(10)
            make.top.equalTo(titleLabel.snp_bottom).offset(2)
        }

    }

    func setDelegate(delegate: ASHorizontalScrollSource) {
        collectionView.delegate = delegate
        collectionView.dataSource = delegate
        delegate.pageControl = pageControl
        collectionView.reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


struct TopSiteItem {
    let urlTitle: String
    let faviconURL: NSURL
    let backgroundColor: UIColor
    let textColor: UIColor
}

class ASHorizontalScrollSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var content: [TopSiteItem] = []
    var contentPerPage: Int = 1
    var itemSize: CGSize = CGSize.zero
    var pageControl: UIPageControl?

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // The number of sections is equal to the number of pages we need to show all the content
        let perPage = Double(content.count) / Double(contentPerPage)
        return Int(ceil(perPage))
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // The number of items per section (page) is always the full page. This allows for the full page to change while swiping. The missing items on a page will be filled with empties.
        if content.isEmpty {
            return 0
        } else {
            return contentPerPage
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // All items are square and are exactly the same size.
        return itemSize
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TopSiteCell", forIndexPath: indexPath) as! TopSiteCell

        // We use sections to signify pages. But content is still stored in a single array. So add an offset based on the section.
        let row = indexPath.row + (indexPath.section * contentPerPage)

        // If the row is out of content index then we have an empty cell at an end of a page.
        if row > content.count - 1 {
            cell.contentView.layer.borderColor = UIColor.clearColor().CGColor
            cell.backgroundColor = UIColor.whiteColor()
            cell.titleLabel.backgroundColor = UIColor.whiteColor()
            cell.imageView.backgroundColor = UIColor.whiteColor()
            cell.contentView.backgroundColor = UIColor.whiteColor()
            return cell
        }

        let contentItem = content[row]
        cell.titleLabel.text = contentItem.urlTitle
        cell.setImageWithURL(contentItem.faviconURL)
        return cell
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {

        let pageWidth = CGRectGetWidth(scrollView.frame)
        pageControl?.currentPage = Int(scrollView.contentOffset.x / pageWidth)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("tapped cell indexpaty\(indexPath.row)")

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