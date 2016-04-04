/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
import UIKit


protocol MenuPageViewDelegate: class {
    func menuPageView(menuPageView: MenuPageCollectionViewCell, didSelectMenuItem menuItem: MenuItemView, atIndexPath indexPath: NSIndexPath)
}

class MenuPageCollectionViewCell: UICollectionViewCell {

    lazy private var pageView: UICollectionView = {
        let view = UICollectionView(frame: CGRectZero, collectionViewLayout: self.pageLayout)
        view.backgroundColor = UIColor.clearColor()
        view.registerClass(MenuItemCollectionViewCell.self, forCellWithReuseIdentifier: self.menuItemCellReuseIdentifier)
        view.delegate = self
        view.dataSource = self
        view.showsVerticalScrollIndicator = false
        return view
    }()
    lazy private var pageLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        return layout
    }()
    private let menuItemCellReuseIdentifier = "MenuItemCell"

    weak var menuItemDelegate: MenuPageViewDelegate?

    var itemPadding: CGFloat = 0
    var menuRowHeight: CGFloat = 0

    var pageIndex: Int = 0

    var numberOfItemsInRow:CGFloat = 0

    var items = [MenuItemView]()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.addSubview(self.pageView)
        self.pageView.snp_makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MenuPageCollectionViewCell: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(menuItemCellReuseIdentifier, forIndexPath: indexPath)
        let cellView = items[indexPath.item]
        cell.contentView.addSubview(cellView)
        cellView.snp_makeConstraints { make in
            make.edges.equalTo(cell.contentView)
        }
        return cell
    }
}

extension MenuPageCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (collectionView.bounds.size.width - ((numberOfItemsInRow+1) * pageLayout.minimumInteritemSpacing)) / numberOfItemsInRow
        let numberOfRows = ceil(CGFloat(items.count) / numberOfItemsInRow)
        let height = collectionView.bounds.size.height / numberOfRows
        return CGSizeMake(width, height)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("selected item at index \(indexPath)")
        let selectedItemIndex = indexPath.item
        menuItemDelegate?.menuPageView(self, didSelectMenuItem: items[selectedItemIndex], atIndexPath: NSIndexPath(forItem: selectedItemIndex, inSection: pageIndex))
    }
}
