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
        configureTableView()
    }



    func configureTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .Grouped)
        tableView.registerClass(SimpleHighlightCell.self, forCellReuseIdentifier: "Cell")
        tableView.registerClass(ASHorizontalScrollCell.self, forCellReuseIdentifier: "TopSite")
        tableView.registerClass(HighlightCell.self, forCellReuseIdentifier: "Highlight")
        tableView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        tableView.separatorStyle = .None
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.estimatedRowHeight = 65
        tableView.estimatedSectionHeaderHeight = 15
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
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
            return 40
        default:
            return 0
        }
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if section == 0 {
            return nil
        }
        let view = ASHeaderView()
        view.title = "HIGHLIGHTS"
        return view
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
            let highlightCell = cell as! HighlightCell
            highlightCell.configureHighlightCell(history[indexPath.row])
            return highlightCell
        default:
            let simpleHighlightCell = cell as! SimpleHighlightCell
            simpleHighlightCell.configureSimpleHighlightCell(history[indexPath.row])
            return simpleHighlightCell
        }
    }

    func configureTopSitesCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let topSiteCell = cell as! ASHorizontalScrollCell
        topSiteCell.setDelegate(self.topSiteHandler)
        return cell
    }

    private func extractDomainURL(url: String) -> String {
        let urlString =  NSURL(string: url)?.normalizedHost() ?? url
        var arr = urlString.componentsSeparatedByString(".")
        if (arr.count >= 2) {
            arr.popLast()
            return arr.joinWithSeparator(".")
        }
        return urlString
    }


    /*
     Simple methods to fetch some data from the DB
     */
    private func reloadTopSitesWithLimit(limit: Int) -> Success {
        return self.profile.history.getTopSitesWithLimit(limit).bindQueue(dispatch_get_main_queue()) { result in
            if let data = result.successValue {
                self.topSites = data.asArray().map { site in
                    if let imgURL = site.icon?.url {
                        let topSite = TopSiteItem(urlTitle: self.extractDomainURL(site.url), faviconURL: NSURL(string:imgURL)!, siteURL: site.tileURL)
                        return topSite
                    }
                    else {
                        let topSite = TopSiteItem(urlTitle: self.extractDomainURL(site.url), faviconURL: NSURL(string:"http://google.com")!, siteURL: site.tileURL)
                        return topSite
                    }
                }
                self.topSiteHandler = ASHorizontalScrollSource()
                self.topSiteHandler.content = self.topSites
                self.topSiteHandler.urlPressedHandler = self.showSiteWithURL
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

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var site: Site!
        switch indexPath.section {
            case 0:
                return
            default:
                site = self.history[indexPath.row]
        }
        showSiteWithURL(site.tileURL)
    }

    func showSiteWithURL(url: NSURL) {
        let visitType = VisitType.Bookmark
        homePanelDelegate?.homePanel(self, didSelectURL: url, visitType: visitType)
    }
}

extension ActivityStreamPanel: HomePanel {
    func endEditing() {
    }
}