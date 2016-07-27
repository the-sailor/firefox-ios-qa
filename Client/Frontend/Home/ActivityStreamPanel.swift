//
//  ActivityStreamPanel.swift
//  Client
//
//  Created by Farhan Patel on 7/27/16.
//  Copyright © 2016 Mozilla. All rights reserved.
//

import Shared
import UIKit

class ActivityStreamPanel: UIViewController, UITableViewDelegate {
    weak var homePanelDelegate: HomePanelDelegate? = nil
    let profile: Profile

    private lazy var dataSource: ActivityStreamDataSource = {
        return ActivityStreamDataSource(profile: self.profile)
    }()
    let tableView = UITableView()

    init(profile: Profile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
    }

    func configureTableView() {
        view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(AStreamRowCell.self, forCellReuseIdentifier: "ASRow")
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.backgroundColor = UIConstants.PanelBackgroundColor
        tableView.separatorColor = UIConstants.PanelBackgroundColor

        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
    }
}


//TopSites data source
extension ActivityStreamPanel: UITableViewDataSource, UICollectionViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ASRow", forIndexPath: indexPath) as! AStreamRowCell
        cell.collectionView.delegate = self
        cell.collectionView.dataSource = self

        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.blueColor()
        return cell
    }

}

extension ActivityStreamPanel: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width:100, height:100)
    }

}

class AStreamRowCell: UITableViewCell {
    var collectionView: UICollectionView!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        let layout  = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        layout.scrollDirection = .Horizontal
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.redColor()
        addSubview(collectionView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        collectionView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct ActivityStreamDataSource {
    //var content = []
    var profile: Profile


    init(profile: Profile) {
        self.profile = profile
    }

    private func reloadTopSitesWithLimit(limit: Int) -> Success {
        return self.profile.history.getTopSitesWithLimit(limit).bindQueue(dispatch_get_main_queue()) { result in
//            self.updateDataSourceWithSites(result)
//            self.collection?.reloadData()
            return succeed()
        }
    }


}

