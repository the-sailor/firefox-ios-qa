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
    var topSiteHandler: ASVerticalScrollSource!

    //once things get fleshed out we can refactor and find a better home for these
    var topSites: [TopSiteItem] = []
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
        collectionView.registerClass(SimpleHighlightCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.registerClass(ASVerticalScrollCell.self, forCellWithReuseIdentifier: "TopSite")
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

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch indexPath.section {
            case 0:
                return CGSize(width: self.view.frame.width, height: 100)
            default:
                //for now every other cell will have a full image
                if indexPath.row % 3 == 0 {
                    return CGSize(width: self.view.frame.width, height: 250)
                }
                else {
                    return CGSize(width: self.view.frame.width, height: 50)
                }
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
            case 0:
                if topSiteHandler != nil && topSiteHandler.content.count != 0 {
                    return 1
                }
                else {
                    return 0
                }
            default:
                return self.history.count
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var identifier = "Cell"
        switch indexPath.section {
            case 0:
                identifier = "TopSite"
            default:
                if indexPath.row % 3 == 0 {
                    identifier = "Highlight"
                }
                else {
                    identifier = "Cell"
                }
        }

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)

        switch identifier {
        case "TopSite":
            return configureTopSitesCell(cell, forIndexPath: indexPath)
        case "Highlight":
            return configureHighlightCell(cell, forIndexPath: indexPath)
        default:
            return configureSimpleHighlightCell(cell, forIndexPath: indexPath)
        }
    }

    func configureTopSitesCell(cell: UICollectionViewCell, forIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let topSiteCell = cell as! ASVerticalScrollCell
        topSiteCell.setDelegate(self.topSiteHandler)
        return cell
    }

    func configureHighlightCell(cell: UICollectionViewCell, forIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let site = self.history[indexPath.row]
        let highlightCell = cell as! HighlightCell
        if let icon = site.icon {
            let url = icon.url
            highlightCell.setImageWithURL(NSURL(string: url)!)
        } else {
            highlightCell.image = UIImage(named: "defaultFavicon")
        }
        highlightCell.textLabel.text = site.title
        highlightCell.textLabel.textColor = UIColor.blackColor()
        highlightCell.textLabel.font = DynamicFontHelper.defaultHelper.DeviceFontHistoryPanel
        highlightCell.descriptionLabel.text = "descriptiondescriptiondescriptiondescription"
        highlightCell.descriptionLabel.font = DynamicFontHelper.defaultHelper.DeviceFontSmallHistoryPanel
        highlightCell.timeStamp.text = "3 hrs"
        return cell
    }

    func configureSimpleHighlightCell(cell: UICollectionViewCell, forIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let site = self.history[indexPath.row]
        let highlightCell = cell as! SimpleHighlightCell
        if let icon = site.icon {
            let url = icon.url
            highlightCell.setImageWithURL(NSURL(string: url)!)
        } else {
            highlightCell.image = UIImage(named: "defaultFavicon")
        }
        highlightCell.textLabel.text = site.title
        highlightCell.textLabel.font = DynamicFontHelper.defaultHelper.DeviceFontHistoryPanel
        highlightCell.descriptionLabel.text = "descriptiondescriptiondescriptiondescription"
        highlightCell.descriptionLabel.font = DynamicFontHelper.defaultHelper.DeviceFontSmallHistoryPanel
        highlightCell.textLabel.textColor = UIColor.blackColor()
        highlightCell.timeStamp.text = "5 hrs"
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

                self.topSites = data.asArray().map { site in
                    if let imgURL = site.icon?.url {
                        let topSite = TopSiteItem(urlTitle: self.extractDomainURL(site.url), faviconURL: NSURL(string:imgURL)!, backgroundColor: UIColor.redColor(), textColor: UIColor.blueColor(), size: CGSize(width: 100, height: 100))
                        return topSite
                    }
                    else {
                        let topSite = TopSiteItem(urlTitle: self.extractDomainURL(site.url), faviconURL: NSURL(string:"http://google.com")!, backgroundColor: UIColor.redColor(), textColor: UIColor.blueColor(), size: CGSize(width: 100, height: 100))
                        return topSite
                    }


                }
                self.topSiteHandler = ASVerticalScrollSource()
                self.topSiteHandler.content = self.topSites


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
                return
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
