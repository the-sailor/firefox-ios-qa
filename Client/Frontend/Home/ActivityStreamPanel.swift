//
//  ActivityStreamPanel.swift
//  Client
//
//  Created by Farhan Patel on 7/27/16.
//  Copyright © 2016 Mozilla. All rights reserved.
//

import Shared
import UIKit
import Deferred
import Storage


class ActivityStreamPanel: UIViewController, UICollectionViewDelegate {
    weak var homePanelDelegate: HomePanelDelegate? = nil
    let profile: Profile
    var collectionView: UICollectionView!

    //once things get fleshed out we can refactor and find a better home for these
    var topSites: [Site] = []
    var highlights: [Site] = []
    var history: [Site] = []

//    private lazy var dataSource: ActivityStreamDataSource = {
//        return ActivityStreamDataSource(profile: self.profile)
//    }()

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
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
}


//TopSites data source
extension ActivityStreamPanel: UICollectionViewDataSource {


    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch indexPath.section {
            case 0:
                return CGSize(width: 100, height: 100)
            case 1:
                return CGSize(width: 200, height: 100)
            default:
                return CGSize(width: self.view.frame.width, height: 50)
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //The number of items in a specfic row
        switch section {
            case 0:
                return self.topSites.count
            case 1:
                return self.highlights.count
            default:
                return self.history.count
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)

        var site: Site!
        switch indexPath.section {
        case 0:
             site = self.topSites[indexPath.row]
        case 1:
            site = self.highlights[indexPath.row]
        default:
            site = self.history[indexPath.row]
        }

        let label = UILabel(frame: cell.bounds)
        label.text = site.title
        cell.addSubview(label)
        cell.backgroundColor = UIColor.blueColor()
        return cell
    }

    private func reloadTopSitesWithLimit(limit: Int) -> Success {
        return self.profile.history.getTopSitesWithLimit(limit).bindQueue(dispatch_get_main_queue()) { result in
            //call the datasource updated with the specific wat? I dunno
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


}



