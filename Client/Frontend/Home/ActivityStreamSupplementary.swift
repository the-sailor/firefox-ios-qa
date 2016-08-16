import Foundation
import Shared
import WebImage

/*
 whats missing??
 long press gesture
 remove button
 select overlay (isnt that automatic)
 cache dominant image color
 handle failure cases for no favicon
 */

struct TopSiteCellUX {
    static let TitleInsetPercent: CGFloat = 0.66
    static let TitleBackgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.7)
    static let TitleTextColor = UIColor.blackColor()
    static let TitleFont = DynamicFontHelper.defaultHelper.DefaultSmallFont
    static let CellCornerRadius: CGFloat = 4
}

class TopSiteCell: UICollectionViewCell {
    var imageView: UIImageView!
    var titleLabel: UILabel!

    override func layoutSubviews() {
        //using autolayout on the contentView does not seem to work
        var squareFrame = CGRectMake(0, 0, frame.height, frame.height)
        squareFrame.center = frame.center
        contentView.frame = squareFrame
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = TopSiteCellUX.CellCornerRadius
        contentView.layer.masksToBounds = true

        titleLabel = UILabel()
        titleLabel.layer.masksToBounds = true
        titleLabel.textAlignment = .Center
        titleLabel.font = TopSiteCellUX.TitleFont
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.backgroundColor = TopSiteCellUX.TitleBackgroundColor
        contentView.addSubview(titleLabel)

        let heightInset = Int(frame.height * TopSiteCellUX.TitleInsetPercent)
        titleLabel.snp_makeConstraints { make in
            make.edges.equalTo(self).inset(UIEdgeInsetsMake(CGFloat(heightInset), 0, 0, 0))
        }

        imageView = UIImageView()
        imageView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        imageView.snp_makeConstraints { make in
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
        backgroundColor = UIColor.whiteColor()
        imageView.image = nil
        titleLabel.text = ""
    }

    func setImageWithURL(url: NSURL) {
        imageView.sd_setImageWithURL(url) { (img, err, type, url) -> Void in
            guard let img = img else {
                // No favicon found. Do something!
                return
            }

            img.getColors(CGSize(width: 50, height:50)) { colors in
                //In cases where the background is white. Force the background color to a different color
                var bgColor: UIColor
                if colors.backgroundColor.isWhite {
                    let colorArr = [colors.detailColor, colors.primaryColor].filter {return !$0.isWhite}
                    if colorArr.isEmpty {
                        ///need an array of default colors
                        bgColor = UIColor.greenColor()
                    }
                    else {
                        bgColor = colorArr[0]
                    }
                }
                else {
                    bgColor = colors.backgroundColor
                }
                contentView.backgroundColor = bgColor

            }
        }
    }

    func configureWithTopSiteItem(site: TopSiteItem) {
        titleLabel.text = site.urlTitle
        setImageWithURL(site.faviconURL)
    }

    func makeCellBlank() {
        backgroundColor = UIColor.whiteColor()
        titleLabel.backgroundColor = UIColor.whiteColor()
        imageView.backgroundColor = UIColor.whiteColor()
        contentView.backgroundColor = UIColor.whiteColor()
    }

}

class ASHorizontalScrollCell: UITableViewCell {
    private var collectionView: UICollectionView!
    private var pageControl: UIPageControl!
    private var headerView: ASHeaderView!

    var headerTitle: String = "" {
        didSet {
            headerView.title = headerTitle
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let layout  = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        backgroundColor = UIColor(white: 1.0, alpha: 0.5)

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

        //Page control will need to be swapped out with a thirdparty one. I cant customize the built in one at all
        pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = UIColor.grayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.darkGrayColor()
        contentView.addSubview(pageControl)
        pageControl.snp_makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(20)
            make.top.equalTo(contentView)
            make.trailing.equalTo(self.snp_trailing).offset(-5)
        }

        headerView = ASHeaderView(frame: CGRect.zero)
        contentView.addSubview(headerView)
        headerView.snp_makeConstraints { make in
            make.width.equalTo(self.snp_width)
            make.top.equalTo(self.snp_top)
            make.bottom.equalTo(collectionView.snp_top)
        }
    }

    func numberOfPagesChanged(sections: Int) {
        pageControl.numberOfPages = sections
    }

    func currentPageChanged(currentPage: Int) {
        pageControl.currentPage = currentPage
    }

    func setDelegate(delegate: ASHorizontalScrollSource) {
        collectionView.delegate = delegate
        collectionView.dataSource = delegate
        delegate.numberOfPagesChangedHandler = numberOfPagesChanged
        delegate.pageChangedHandler = currentPageChanged
        collectionView.reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


struct TopSiteItem {
    let urlTitle: String
    let faviconURL: NSURL
}

class ASHorizontalScrollSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var content: [TopSiteItem] = []
    var contentPerPage: Int = 1
    var itemSize: CGSize = CGSize.zero

    var numberOfPagesChangedHandler: ((Int) -> Void)?
    var pageChangedHandler: ((Int) -> Void)?
    var numberOfPages: Int = 0 {
        didSet {
            if oldValue != numberOfPages {
                numberOfPagesChangedHandler?(numberOfPages)
            }
        }
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // The number of sections is equal to the number of pages we need to show all the content
        let perPage = Double(content.count) / Double(contentPerPage)
        numberOfPages = Int(ceil(perPage))
        return numberOfPages
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
            cell.makeCellBlank()
            return cell
        }

        let contentItem = content[row]
        cell.configureWithTopSiteItem(contentItem)
        return cell
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = CGRectGetWidth(scrollView.frame)
        pageChangedHandler?(Int(scrollView.contentOffset.x / pageWidth))
    }


    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("tapped cell indexpaty\(indexPath.row)")
    }

}

struct ASHeaderViewUX {
    static let ContentColor = UIColor.grayColor()
    static let TextFont = DynamicFontHelper.defaultHelper.DefaultSmallFont
    static let SeperatorHeight = 1
    static let Insets = 10
    static let TitleHeight = 20
}

class ASHeaderView: UIView {
    var titleLabel: UILabel!
    var title: String = "" {
        willSet(newTitle) {
            titleLabel.text = newTitle
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = ASHeaderViewUX.ContentColor
        titleLabel.font = ASHeaderViewUX.TextFont
        addSubview(titleLabel)
        titleLabel.snp_makeConstraints { make in
            make.height.equalTo(ASHeaderViewUX.TitleHeight)
            make.leading.equalTo(self.snp_leading).offset(ASHeaderViewUX.Insets)
            make.trailing.equalTo(self.snp_trailing).offset(-ASHeaderViewUX.Insets)
        }

        let seperatorLine = UIView()
        seperatorLine.backgroundColor = ASHeaderViewUX.ContentColor
        addSubview(seperatorLine)
        seperatorLine.snp_makeConstraints { make in
            make.height.equalTo(ASHeaderViewUX.SeperatorHeight)
            make.leading.equalTo(self.snp_leading).offset(ASHeaderViewUX.Insets)
            make.trailing.equalTo(self.snp_trailing).offset(-ASHeaderViewUX.Insets)
            make.top.equalTo(titleLabel.snp_bottom).offset(2)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}