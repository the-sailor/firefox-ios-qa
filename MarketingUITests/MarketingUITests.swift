/* This Source Code Form is subject to the terms of the Mozilla Public
* License, v. 2.0. If a copy of the MPL was not distributed with this
* file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class MarketingSnapshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            XCUIDevice.sharedDevice().orientation = .LandscapeLeft
        }
    }

    func test01Homescreen() {
        app.buttons["IntroViewController.startBrowsingButton"].tap()
        snapshot("01-HomeScreen")
    }

//    func test02HomescreenWithTiles() {
//        app.buttons["IntroViewController.startBrowsingButton"].tap()
//        snapshot("01-HomeScreen")
//    }

//    func test02Bookmarks() {
//    }

    func test03History() {
        let historyLastMonthPerLocale: [String: [String]] = [
            "*": [
                "http://www.techcrunch.com",
                "http://www.bbc.com/news",
                "https://search.yahoo.com/mobile/s?p=privacy",
                "https://www.eff.org/issues/privacy",
                "http://www.reuters.com/news",
                "https://www.nasa.gov",
                "https://support.mozilla.org",
                "https://blog.mozilla.org/blog/2016/02/25/mozilla-introduces-surveillance-principles-for-a-secure-trusted-internet-2/",
                "https://www.smashingmagazine.com"
            ],
            "de": [
                "http://www.spiegel.de",
                "http://www.ebay.de",
                "https://search.yahoo.com/mobile/s?p=privatsphäre",
                "https://www.eff.org/issues/privacy",
                "http://de.reuters.com",
                "https://support.mozilla.org",
                "https://blog.mozilla.org/blog/2016/02/25/mozilla-introduces-surveillance-principles-for-a-secure-trusted-internet-2/"
            ],
            "fr": [
                "https://support.mozilla.org",
                "https://blog.mozilla.org/blog/2016/02/25/mozilla-introduces-surveillance-principles-for-a-secure-trusted-internet-2/"
            ],
            ]

        //        for url in (historyLastMonthPerLocale[NSLocale.currentLocale().localeIdentifier] ?? historyLastMonthPerLocale["*"]!).reverse() {
        //            loadWebPage(url, waitForLoadToFinish: false)
        //            sleep(5)
        //        }

        let historyTodayPerLocale: [String: [String]] = [
            "*": [
                "https://www.mozilla.org",
                "https://www.youtube.com",
                "https://www.twitter.com",
                "https://www.reddit.com",
                "https://support.mozilla.org/products/ios",
                "https://search.yahoo.com/mobile/s?p=firefox"
            ],
            "de": [
                "https://www.mozilla.org",
                "https://www.youtube.com",
                "https://www.twitter.com",
                "https://www.wikipedia.org",
                "https://support.mozilla.org/products/ios",
                "https://search.yahoo.com/mobile/s?p=firefox"
            ],
            "fr": [
                "https://www.mozilla.org",
                "https://www.youtube.com",
                "https://www.twitter.com",
                "https://www.wikipedia.org",
                "https://support.mozilla.org/products/ios",
                "https://search.yahoo.com/mobile/s?p=firefox",
            ]
        ]

        for url in (historyTodayPerLocale[NSLocale.currentLocale().localeIdentifier] ?? historyTodayPerLocale["*"]!).reverse() {
            loadWebPage(url, waitForLoadToFinish: false)
            sleep(5)
        }

        app.textFields["url"].tap()
        app.buttons["HomePanels.History"].tap()

        snapshot("03-History")
    }

//    func test04Sync() {
//    }
//
//    func test05ReadingList() {
//    }

    func test06Tabs() {
        let tabsPerLocale: [String: [String]] = [
            "*": [
                "https://www.twitter.com",
                "https://www.mozilla.org/firefox/desktop",
                "https://www.flickr.com",
                "https://www.mozilla.org",
                "https://www.mozilla.org/firefox/developer/",
            ],
        ]

        for url in tabsPerLocale[NSLocale.currentLocale().localeIdentifier] ?? tabsPerLocale["*"]! {
            // Open a new tab, load the page
            app.buttons["URLBarView.tabsButton"].tap()
            app.buttons["TabTrayController.addTabButton"].tap()
            loadWebPage(url, waitForLoadToFinish: false)
            sleep(5) // TODO Need better mechanism to find out if page has finished loading. Also, mozilla.org/firefox/desktop will need more time to settle because it does animations.
        }

        // Go back to the tabs tray, swipe it back to the top
        app.buttons["URLBarView.tabsButton"].tap()
        app.collectionViews["TabTrayController.collectionView"].swipeDown()
        snapshot("06-Tabs")
    }

    func test07PrivateBrowsing() {
        let app = XCUIApplication()
        app.buttons["URLBarView.tabsButton"].tap()
        app.buttons["TabTrayController.togglePrivateMode"].tap()
        snapshot("07-PrivateBrowsing")
        app.buttons["TabTrayController.togglePrivateMode"].tap()
    }

//    func test08PrivateBrowsingWithTabs() {
//        let tabsPerLocale: [String: [String]] = [
//            "*": [
//                "https://www.mozilla.org",
//            ],
//        ]
//
//        for (index, url) in (tabsPerLocale[NSLocale.currentLocale().localeIdentifier] ?? tabsPerLocale["*"]!).enumerate() {
//            // Open a new tab, load the page
//            app.buttons["URLBarView.tabsButton"].tap()
//            if index == 0 {
//                app.buttons["TabTrayController.togglePrivateMode"].tap()
//            }
//            app.buttons["TabTrayController.addTabButton"].tap()
//            loadWebPage(url, waitForLoadToFinish: false)
//            sleep(5) // TODO Need better mechanism to find out if page has finished loading. Also, mozilla.org/firefox/desktop will need more time to settle because it does animations.
//        }
//
//        // Go back to the tabs tray, swipe it back to the top
//        app.buttons["URLBarView.tabsButton"].tap()
//        app.collectionViews["TabTrayController.collectionView"].swipeDown()
//        snapshot("08-PrivateBrowsingWithTabs")
//        app.buttons["TabTrayController.togglePrivateMode"].tap()
//    }

    func test09SearchResults() {
        app.textFields["url"].tap()
        app.textFields["address"].typeText("firefox") // TODO Needs to be localized
        app.buttons["SearchViewController.promptYesButton"].tap()
        let _ = NSData(contentsOfURL: NSURL(string: "http://localhost:6571/snapshottest/hidekeyboard")!)
        sleep(3)
        snapshot("08-SearchResults")
    }

    private func loadWebPage(url: String, waitForLoadToFinish: Bool = true) {
        let LoadingTimeout: NSTimeInterval = 10
        let exists = NSPredicate(format: "exists = true")
        let loaded = NSPredicate(format: "value BEGINSWITH '100'")

        let app = XCUIApplication()

        UIPasteboard.generalPasteboard().string = url
        app.textFields["url"].pressForDuration(2.0)
        app.sheets.elementBoundByIndex(0).buttons.elementBoundByIndex(0).tap()

        if waitForLoadToFinish {
            let progressIndicator = app.progressIndicators.elementBoundByIndex(0)
            expectationForPredicate(exists, evaluatedWithObject: progressIndicator, handler: nil)
            expectationForPredicate(loaded, evaluatedWithObject: progressIndicator, handler: nil)
            waitForExpectationsWithTimeout(LoadingTimeout, handler: nil)
        }
    }
}
