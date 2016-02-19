/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit
import Storage
import ReadingList
import Shared
import XCGLogger

private let log = Logger.browserLogger

private struct ReadingListTableViewCellUX {
    static let RowHeight: CGFloat = 86

    static let ActiveTextColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    static let DimmedTextColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.44)

    static let ReadIndicatorWidth: CGFloat =  12  // image width
    static let ReadIndicatorHeight: CGFloat = 12 // image height
    static let ReadIndicatorTopOffset: CGFloat = 36.75 // half of the cell - half of the height of the asset
    static let ReadIndicatorLeftOffset: CGFloat = 18
    static let ReadAccessibilitySpeechPitch: Float = 0.7 // 1.0 default, 0.0 lowest, 2.0 highest

    static let TitleLabelTopOffset: CGFloat = 14 - 4
    static let TitleLabelLeftOffset: CGFloat = 16 + 16 + 16
    static let TitleLabelRightOffset: CGFloat = -40

    static let HostnameLabelBottomOffset: CGFloat = 11

    static let DeleteButtonBackgroundColor = UIColor(rgb: 0xef4035)
    static let DeleteButtonTitleColor = UIColor.whiteColor()
    static let DeleteButtonTitleEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

    static let MarkAsReadButtonBackgroundColor = UIColor(rgb: 0x2193d1)
    static let MarkAsReadButtonTitleColor = UIColor.whiteColor()
    static let MarkAsReadButtonTitleEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

    // Localizable strings
    static let DeleteButtonTitleText = NSLocalizedString("Remove", comment: "Title for the button that removes a reading list item")
    static let MarkAsReadButtonTitleText = NSLocalizedString("Mark as Read", comment: "Title for the button that marks a reading list item as read")
    static let MarkAsUnreadButtonTitleText = NSLocalizedString("Mark as Unread", comment: "Title for the button that marks a reading list item as unread")
}

private struct ReadingListPanelUX {
    // Welcome Screen
    static let WelcomeScreenTopPadding: CGFloat = 16
    static let WelcomeScreenPadding: CGFloat = 15

    static let WelcomeScreenHeaderTextColor = UIColor.darkGrayColor()

    static let WelcomeScreenItemTextColor = UIColor.grayColor()
    static let WelcomeScreenItemWidth = 220
    static let WelcomeScreenItemOffset = -20

    static let WelcomeScreenCircleWidth = 40
    static let WelcomeScreenCircleOffset = 20
    static let WelcomeScreenCircleSpacer = 10
}

class ReadingListTableViewCell: SWTableViewCell {
    var title: String = "Example" {
        didSet {
            titleLabel.text = title
            updateAccessibilityLabel()
        }
    }

    var url: NSURL = NSURL(string: "http://www.example.com")! {
        didSet {
            hostnameLabel.text = simplifiedHostnameFromURL(url)
            updateAccessibilityLabel()
        }
    }

    var unread: Bool = true {
        didSet {
            readStatusImageView.image = UIImage(named: unread ? "MarkAsRead" : "MarkAsUnread")
            titleLabel.textColor = unread ? ReadingListTableViewCellUX.ActiveTextColor : ReadingListTableViewCellUX.DimmedTextColor
            hostnameLabel.textColor = unread ? ReadingListTableViewCellUX.ActiveTextColor : ReadingListTableViewCellUX.DimmedTextColor
            markAsReadButton.setTitle(unread ? ReadingListTableViewCellUX.MarkAsReadButtonTitleText : ReadingListTableViewCellUX.MarkAsUnreadButtonTitleText, forState: UIControlState.Normal)
            if let text = markAsReadButton.titleLabel?.text {
                markAsReadAction.name = text
            }
            updateAccessibilityLabel()
        }
    }

    private var deleteAction: UIAccessibilityCustomAction!
    private var markAsReadAction: UIAccessibilityCustomAction!

    let readStatusImageView: UIImageView!
    let titleLabel: UILabel!
    let hostnameLabel: UILabel!
    let deleteButton: UIButton!
    let markAsReadButton: UIButton!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        readStatusImageView = UIImageView()
        titleLabel = UILabel()
        hostnameLabel = UILabel()
        deleteButton = UIButton()
        markAsReadButton = UIButton()

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = UIColor.clearColor()

        separatorInset = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 0)
        layoutMargins = UIEdgeInsetsZero
        preservesSuperviewLayoutMargins = false

        contentView.addSubview(readStatusImageView)
        readStatusImageView.contentMode = UIViewContentMode.ScaleAspectFit
        readStatusImageView.snp_makeConstraints { (make) -> () in
            make.width.equalTo(ReadingListTableViewCellUX.ReadIndicatorWidth)
            make.height.equalTo(ReadingListTableViewCellUX.ReadIndicatorHeight)
            make.top.equalTo(self.contentView).offset(ReadingListTableViewCellUX.ReadIndicatorTopOffset)
            make.left.equalTo(self.contentView).offset(ReadingListTableViewCellUX.ReadIndicatorLeftOffset)
        }

        contentView.addSubview(titleLabel)
        contentView.addSubview(hostnameLabel)

        titleLabel.textColor = ReadingListTableViewCellUX.ActiveTextColor
        titleLabel.numberOfLines = 2
        titleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.contentView).offset(ReadingListTableViewCellUX.TitleLabelTopOffset)
            make.left.equalTo(self.contentView).offset(ReadingListTableViewCellUX.TitleLabelLeftOffset)
            make.right.equalTo(self.contentView).offset(ReadingListTableViewCellUX.TitleLabelRightOffset) // TODO Not clear from ux spec
            make.bottom.lessThanOrEqualTo(hostnameLabel.snp_top).priorityHigh()
        }

        hostnameLabel.textColor = ReadingListTableViewCellUX.ActiveTextColor
        hostnameLabel.numberOfLines = 1
        hostnameLabel.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.contentView).offset(-ReadingListTableViewCellUX.HostnameLabelBottomOffset)
            make.left.right.equalTo(self.titleLabel)
        }

        deleteButton.backgroundColor = ReadingListTableViewCellUX.DeleteButtonBackgroundColor
        deleteButton.titleLabel?.textColor = ReadingListTableViewCellUX.DeleteButtonTitleColor
        deleteButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        deleteButton.titleLabel?.textAlignment = NSTextAlignment.Center
        deleteButton.setTitle(ReadingListTableViewCellUX.DeleteButtonTitleText, forState: UIControlState.Normal)
        deleteButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        deleteButton.titleEdgeInsets = ReadingListTableViewCellUX.DeleteButtonTitleEdgeInsets
        deleteAction = UIAccessibilityCustomAction(name: ReadingListTableViewCellUX.DeleteButtonTitleText, target: self, selector: "deleteActionActivated")

        rightUtilityButtons = [deleteButton]

        markAsReadButton.backgroundColor = ReadingListTableViewCellUX.MarkAsReadButtonBackgroundColor
        markAsReadButton.titleLabel?.textColor = ReadingListTableViewCellUX.MarkAsReadButtonTitleColor
        markAsReadButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        markAsReadButton.titleLabel?.textAlignment = NSTextAlignment.Center
        markAsReadButton.setTitle(ReadingListTableViewCellUX.MarkAsReadButtonTitleText, forState: UIControlState.Normal)
        markAsReadButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        markAsReadButton.titleEdgeInsets = ReadingListTableViewCellUX.MarkAsReadButtonTitleEdgeInsets
        markAsReadAction = UIAccessibilityCustomAction(name: ReadingListTableViewCellUX.MarkAsReadButtonTitleText, target: self, selector: "markAsReadActionActivated")

        leftUtilityButtons = [markAsReadButton]

        accessibilityCustomActions = [deleteAction, markAsReadAction]
        setupDynamicFonts()
    }

    func setupDynamicFonts() {
        titleLabel.font = DynamicFontHelper.defaultHelper.DeviceFont
        hostnameLabel.font = DynamicFontHelper.defaultHelper.DeviceFontSmallLight
        deleteButton.titleLabel?.font = DynamicFontHelper.defaultHelper.DeviceFontLight
        markAsReadButton.titleLabel?.font = DynamicFontHelper.defaultHelper.DeviceFontLight
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setupDynamicFonts()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let prefixesToSimplify = ["www.", "mobile.", "m.", "blog."]

    private func simplifiedHostnameFromURL(url: NSURL) -> String {
        let hostname = url.host ?? ""
        for prefix in prefixesToSimplify {
            if hostname.hasPrefix(prefix) {
                return hostname.substringFromIndex(hostname.startIndex.advancedBy(prefix.characters.count))
            }
        }
        return hostname
    }

    @objc private func markAsReadActionActivated() -> Bool {
        self.delegate?.swipeableTableViewCell?(self, didTriggerLeftUtilityButtonWithIndex: 0)
        return true
    }

    @objc private func deleteActionActivated() -> Bool {
        self.delegate?.swipeableTableViewCell?(self, didTriggerRightUtilityButtonWithIndex: 0)
        return true
    }

    private func updateAccessibilityLabel() {
        if let hostname = hostnameLabel.text,
                  title = titleLabel.text {
            let unreadStatus = unread ? NSLocalizedString("unread", comment: "Accessibility label for unread article in reading list. It's a past participle - functions as an adjective.") : NSLocalizedString("read", comment: "Accessibility label for read article in reading list. It's a past participle - functions as an adjective.")
            let string = "\(title), \(unreadStatus), \(hostname)"
            var label: AnyObject
            if !unread {
                // mimic light gray visual dimming by "dimming" the speech by reducing pitch
                let lowerPitchString = NSMutableAttributedString(string: string as String)
                lowerPitchString.addAttribute(UIAccessibilitySpeechAttributePitch, value: NSNumber(float: ReadingListTableViewCellUX.ReadAccessibilitySpeechPitch), range: NSMakeRange(0, lowerPitchString.length))
                label = NSAttributedString(attributedString: lowerPitchString)
            } else {
                label = string
            }
            // need to use KVC as accessibilityLabel is of type String! and cannot be set to NSAttributedString other way than this
            // see bottom of page 121 of the PDF slides of WWDC 2012 "Accessibility for iOS" session for indication that this is OK by Apple
            // also this combined with Swift's strictness is why we cannot simply override accessibilityLabel and return the label directly...
            setValue(label, forKey: "accessibilityLabel")
        }
    }
}

class ReadingListPanel: UITableViewController, HomePanel, SWTableViewCellDelegate {
    weak var homePanelDelegate: HomePanelDelegate? = nil
    var profile: Profile!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificationReceived:", name: "ESSBeaconScannerDiscoveredURL", object: nil)
    }

    required init!(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ESSBeaconScannerDiscoveredURL", object: nil)
    }

    func notificationReceived(notification: NSNotification) {
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DiscoveredURLs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = DiscoveredURLs[indexPath.row].absoluteDisplayString()
        return cell
    }
}

