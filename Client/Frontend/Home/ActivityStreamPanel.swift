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
    var tableView: UITableView!
    var topSiteHandler: ASHorizontalScrollSource!

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

        tableView = UITableView()
        tableView.registerClass(SimpleHighlightCell.self, forCellReuseIdentifier: "Cell")
        tableView.registerClass(ASHorizontalScrollCell.self, forCellReuseIdentifier: "TopSite")
        tableView.registerClass(HighlightCell.self, forCellReuseIdentifier: "Highlight")
//        collectionView.registerClass(ActivityStreamHeaderView.self, forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "ASHeader")
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
}


//Headers layout
extension ActivityStreamPanel {

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            return 50
        default:
            return 0
        }
    }


    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return ""
            default:
                return "Highlights"
        }
    }
}

//TopSites data source
extension ActivityStreamPanel: UITableViewDelegate, UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 100
        default:
            //for now every other cell will have a full image
            if indexPath.row % 3 == 0 {
                return 250
            }
            else {
                return 65
            }
        }
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        switch identifier {
        case "TopSite":
            return configureTopSitesCell(cell, forIndexPath: indexPath)
        case "Highlight":
            return configureHighlightCell(cell, forIndexPath: indexPath)
        default:
            return configureSimpleHighlightCell(cell, forIndexPath: indexPath)
        }
    }

    func configureTopSitesCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let topSiteCell = cell as! ASHorizontalScrollCell
        topSiteCell.setDelegate(self.topSiteHandler)
        return cell
    }

    func configureHighlightCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let site = self.history[indexPath.row]
        let highlightCell = cell as! HighlightCell
        if let icon = site.icon {
            let url = icon.url
            highlightCell.setImageWithURL(NSURL(string: url)!)
        } else {
            highlightCell.imageREPLACE = FaviconFetcher.getDefaultFavicon(NSURL(string: site.url)!)
            highlightCell.imageView!.layer.borderWidth = 0.5
        }
        highlightCell.textLabelREPLACE.text = site.title
        highlightCell.textLabelREPLACE.textColor = UIColor.blackColor()
        highlightCell.textLabelREPLACE.font = DynamicFontHelper.defaultHelper.DeviceFontHistoryPanel
        highlightCell.descriptionLabel.text = "description      description      description    description description    description description    description"
        highlightCell.descriptionLabel.font = DynamicFontHelper.defaultHelper.DeviceFontSmallHistoryPanel
        highlightCell.statusIcon.image = UIImage(named: "bookmarked_passive")
        highlightCell.timeStamp.text = "3 hrs"
        return cell
    }

    func configureSimpleHighlightCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let site = self.history[indexPath.row]
        let highlightCell = cell as! SimpleHighlightCell
        if let icon = site.icon {
            let url = icon.url
            highlightCell.setImageWithURL(NSURL(string: url)!)
        } else {
            highlightCell.imageREPLACE = FaviconFetcher.getDefaultFavicon(NSURL(string: site.url)!)
            highlightCell.imageViewREPLACE.layer.borderWidth = 0.5
        }
        highlightCell.textLabelREPLACE.text = site.title
        highlightCell.textLabelREPLACE.font = DynamicFontHelper.defaultHelper.DeviceFontHistoryPanel
        highlightCell.descriptionLabel.text = "description    description    description   description  description    description description    description"
        highlightCell.descriptionLabel.font = DynamicFontHelper.defaultHelper.DeviceFontSmallHistoryPanel
        highlightCell.textLabelREPLACE.textColor = UIColor.blackColor()
        highlightCell.statusIcon.image = UIImage(named: "bookmarked_passive")
        highlightCell.timeStamp.text = "5 hrs"
        return cell
    }

    private func extractDomainURL(url: String) -> String {
        return NSURL(string: url)?.normalizedHost() ?? url
    }


    /*
     We use this to figure out how big a button in a TopSite should be. This tries to allow as many cells in a single page as possible.
     */
    func sizeForItemsInASScrollView() -> CGSize {
        let width = self.view.frame.size.width
        var maxHeight = 100.0
        var numItems = Double(width) / maxHeight
        if Int(numItems) <= 3 {
            numItems = 4
            maxHeight = Double(width) / numItems
        }
        if floor(numItems) == numItems {
            //we have an exact fit. Make the cell slightly smaller.
            maxHeight = maxHeight - 5
        }
        let cellWidth =  Double(width) / floor(numItems)

        return CGSize(width: cellWidth, height: maxHeight)
    }

    func numberOfItemsPerPageInASScrollView() -> Int {
        let width = self.view.frame.size.width
        var maxHeight = 100.0
        var numItems = Double(width) / maxHeight
        if Int(numItems) <= 3 {
            numItems = 4
        }
        return Int(numItems)
    }

    /*
     Simple methods to fetch some data from the DB
     */
    private func reloadTopSitesWithLimit(limit: Int) -> Success {
        return self.profile.history.getTopSitesWithLimit(limit).bindQueue(dispatch_get_main_queue()) { result in
            if let data = result.successValue {
                let rect = self.sizeForItemsInASScrollView()
                self.topSites = data.asArray().map { site in
                    if let imgURL = site.icon?.url {
                        let topSite = TopSiteItem(urlTitle: self.extractDomainURL(site.url), faviconURL: NSURL(string:imgURL)!, backgroundColor: UIColor.redColor(), textColor: UIColor.blueColor(), size: rect)
                        return topSite
                    }
                    else {
                        let topSite = TopSiteItem(urlTitle: self.extractDomainURL(site.url), faviconURL: NSURL(string:"http://google.com")!, backgroundColor: UIColor.redColor(), textColor: UIColor.blueColor(), size: rect)
                        return topSite
                    }


                }
                self.topSiteHandler = ASHorizontalScrollSource()
                self.topSiteHandler.contentPerPage = self.numberOfItemsPerPageInASScrollView()
                self.topSiteHandler.content = self.topSites


                self.tableView.reloadData()
            }
            return succeed()
        }
    }

    private func reloadRecentHistoryWithLimit(limit: Int) -> Success {
        return self.profile.history.getSitesByLastVisit(limit).bindQueue(dispatch_get_main_queue()) { result in
            if let data = result.successValue {
                self.history = data.asArray()
                self.tableView.reloadData()
            }
            return succeed()
        }
    }

    private func reloadHighlights(limit: Int) -> Success {
        return self.profile.history.getSitesByFrecencyWithHistoryLimit(limit).bindQueue(dispatch_get_main_queue()) {result in
            if let data = result.successValue {
                self.highlights = data.asArray()
                self.tableView.reloadData()
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
