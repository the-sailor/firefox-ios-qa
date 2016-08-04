/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import UIKit
import Deferred
import Storage
import WebImage

/*
 Section headers
 only show a single row of highlights
 general reorg
 remove all magic numbers in favor of a struct
 fonts
 */

class ActivityStreamPanel: UIViewController, UICollectionViewDelegate {
    weak var homePanelDelegate: HomePanelDelegate? = nil
    let profile: Profile
    var collectionView: UICollectionView!

    //once things get fleshed out we can refactor and find a better home for these
    var topSites: [Site] = []
    var highlights: [Site] = []
    var history: [Site] = []

    init(profile: Profile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadTopSitesWithLimit(10)
        reloadRecentHistoryWithLimit(10)
        reloadHighlights(3)
        configureCollectionView()
    }



    func configureCollectionView() {
        let layout  = UICollectionViewFlowLayout()

        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.registerClass(TopSiteCell.self, forCellWithReuseIdentifier: "TopSite")
        collectionView.registerClass(HighlightCell.self, forCellWithReuseIdentifier: "Highlight")
        collectionView.registerClass(ActivityStreamHeaderView.self, forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "ASHeader")
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
}


//Headers layout
extension ActivityStreamPanel {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0:
            return CGSize(width: self.view.frame.width, height: 50)
        case 1:
            return CGSize(width: self.view.frame.width, height: 50)
        default:
            return CGSize(width: 0, height: 0)
        }
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ASHeader", forIndexPath: indexPath) as! ActivityStreamHeaderView
        switch indexPath.section {
        case 0:
            cell.titleLabel.text = "Top Sites"
        default:
           cell.titleLabel.text = "Highlights"
        }
        return cell

    }


}

//TopSites data source
extension ActivityStreamPanel: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch indexPath.section {
            case 0:
                return CGSize(width: 100, height: 100)
            case 1:
                return CGSize(width: (self.view.frame.width/2)-5, height: 100)
            default:
                return CGSize(width: self.view.frame.width, height: 50)
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
            case 0:
                return self.topSites.count
                //we need to only load enough for one row. This varies on different devices
                let screenMax = Int(view.frame.width/100)
                return screenMax < self.topSites.count ? screenMax : self.topSites.count
            case 1:
                return self.highlights.count
            default:
                return self.history.count
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var identifier = "Cell"
        switch indexPath.section {
            case 0:
                identifier = "TopSite"
            case 1:
                identifier = "Highlight"
            default:
                identifier = "Cell"
        }

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)

        var site: Site!
        switch indexPath.section {
        case 0:
            return configureTopSitesCell(cell, forIndexPath: indexPath)
        case 1:
            return configureHighlightCell(cell, forIndexPath: indexPath)
        default:
            site = self.history[indexPath.row]
        }

        let label = UILabel(frame: cell.bounds)
        label.text = site.title
        cell.addSubview(label)
        cell.backgroundColor = UIColor.blueColor()
        return cell
    }

    func configureTopSitesCell(cell: UICollectionViewCell, forIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let site = self.topSites[indexPath.row]
        let topSiteCell = cell as! TopSiteCell
        topSiteCell.backgroundColor = UIColor.blueColor()
        if let icon = site.icon {
           let url = icon.url
            topSiteCell.setImageWithURL(NSURL(string: url)!)
        }
        
        topSiteCell.titleLabel.text = extractDomainURL(site.url)
        return cell
    }

    func configureHighlightCell(cell: UICollectionViewCell, forIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let site = self.highlights[indexPath.row]
        let highlightCell = cell as! HighlightCell
        if let icon = site.icon {
            let url = icon.url
            highlightCell.setImageWithURL(NSURL(string: url)!)
        }
        highlightCell.textLabel.text = site.title
        highlightCell.textLabel.textColor = UIColor.blackColor()
        highlightCell.statusText.text = "Bookmarked"
        highlightCell.statusText.textColor = UIColor.blackColor()
        highlightCell.textWrapper.backgroundColor = UIColor.greenColor()
        highlightCell.timeStamp.text = "3 hrs"
        return cell
    }

    func configureRecentCell(cell: UICollectionViewCell, forIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let site = self.highlights[indexPath.row]

        return cell
    }

    private func extractDomainURL(url: String) -> String {
        return NSURL(string: url)?.normalizedHost() ?? url
    }


    private func setDefaultThumbnailBackgroundForCell(cell: ThumbnailCell) {
        cell.imageView.image = UIImage(named: "defaultTopSiteIcon")!
        cell.imageView.contentMode = UIViewContentMode.Center
    }

    private func setBlurredBackground(image: UIImage, withURL url: NSURL, forCell cell: ThumbnailCell) {
        let blurredKey = "\(url.absoluteString)!blurred"
        if let blurredImage = SDImageCache.sharedImageCache().imageFromMemoryCacheForKey(blurredKey) {
            cell.backgroundImage.image = blurredImage
        } else {
            let blurredImage = image.applyLightEffect()
            SDImageCache.sharedImageCache().storeImage(blurredImage, forKey: blurredKey, toDisk: false)
            cell.backgroundImage.alpha = 0
            cell.backgroundImage.image = blurredImage
            UIView.animateWithDuration(0.3) {
                cell.backgroundImage.alpha = 1
            }
        }
    }


    /*
     Simple methods to fetch some data from the DB
     */
    private func reloadTopSitesWithLimit(limit: Int) -> Success {
        return self.profile.history.getTopSitesWithLimit(limit).bindQueue(dispatch_get_main_queue()) { result in
            if let data = result.successValue {
                self.topSites = data.asArray() //weak?
                self.collectionView.reloadData()
            }
            return succeed()
        }
    }

    private func reloadRecentHistoryWithLimit(limit: Int) -> Success {
        return self.profile.history.getSitesByLastVisit(limit).bindQueue(dispatch_get_main_queue()) { result in
            if let data = result.successValue {
                self.history = data.asArray()
                self.collectionView.reloadData()
            }
            return succeed()
        }
    }

    private func reloadHighlights(limit: Int) -> Success {
        return self.profile.history.getSitesByFrecencyWithHistoryLimit(limit).bindQueue(dispatch_get_main_queue()) {result in
            if let data = result.successValue {
                self.highlights = data.asArray()
                self.collectionView.reloadData()
            }
            return succeed()
        }
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var site: Site!
        switch indexPath.section {
            case 0:
                site = self.topSites[indexPath.row]
            case 1:
                site = self.highlights[indexPath.row]
            default:
                site = self.history[indexPath.row]
        }
        let visitType = VisitType.Bookmark
        homePanelDelegate?.homePanel(self, didSelectURL: site.tileURL, visitType: visitType)

    }
}

extension ActivityStreamPanel: HomePanel {
    func endEditing() {
    }
}
