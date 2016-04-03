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

    func test01HomescreenAlexaTopFive() {
        app.buttons["IntroViewController.startBrowsingButton"].tap()
        snapshot("HomescreenAlexaTopFive")
    }

    func test02SearchResults() {
        let searchResultsPerLocale: [String: [String]] = [
            "*": [
                "https://search.yahoo.com/yhs/search?ei=UTF-8&p=firefox",
                "https://www.twitter.com/firefox",
                "https://www.mozilla.org/firefox/ios",
                "https://en.wikipedia.org/wiki/Firefox",
                "https://support.mozilla.org/en-US/products/ios",
                "https://www.mozilla.org"
            ],
            "de": [
                "https://search.yahoo.com/yhs/search?ei=UTF-8&p=firefox",
                "https://www.twitter.com/firefox",
                "https://www.mozilla.org/firefox/ios",
                "https://de.wikipedia.org/wiki/Firefox",
                "https://support.mozilla.org/de/products/ios",
                "https://www.mozilla.org"
            ],
            "fr": [
                "https://search.yahoo.com/yhs/search?ei=UTF-8&p=firefox",
                "https://www.twitter.com/firefox",
                "https://www.mozilla.org/firefox/ios",
                "https://fr.wikipedia.org/wiki/Firefox",
                "https://support.mozilla.org/fr/products/ios",
                "https://www.mozilla.org"
            ],
        ]

        for url in (searchResultsPerLocale[NSLocale.currentLocale().localeIdentifier] ?? searchResultsPerLocale["*"]!).reverse() {
            loadWebPage(url, waitForLoadToFinish: false)
            sleep(3) // TODO Need better mechanism to find out if page has finished loading. Also, mozilla.org/firefox/desktop will need more time to settle because it does animations.
        }

        app.textFields["url"].tap()
        app.textFields["address"].typeText("firefox") // TODO Needs to be localized
        app.buttons["SearchViewController.promptYesButton"].tap()

        // TODO This does not work?
        let _ = NSData(contentsOfURL: NSURL(string: "http://localhost:6571/snapshottest/hidekeyboard")!)
        sleep(3)

        snapshot("SearchResults")
    }

    func test03Tabs() {
        let tabsPerLocale: [String: [String]] = [
            "*": [
                "https://www.twitter.com",
                "https://www.mozilla.org/firefox/desktop",
                "https://www.flickr.com",
                "https://www.mozilla.org",
                "https://www.mozilla.org/firefox/developer/",
            ],
        ]

        for (index, url) in (tabsPerLocale[NSLocale.currentLocale().localeIdentifier] ?? tabsPerLocale["*"]!).enumerate() {
            // Open a new tab, load the page. Reuse the existing tab that we already have.
            if index != 0 {
                app.buttons["URLBarView.tabsButton"].tap()
                app.buttons["TabTrayController.addTabButton"].tap()
            }
            loadWebPage(url, waitForLoadToFinish: false)
            sleep(5) // TODO Need better mechanism to find out if page has finished loading. Also, mozilla.org/firefox/desktop will need more time to settle because it does animations.
        }

        // Go back to the tabs tray, swipe it back to the top
        app.buttons["URLBarView.tabsButton"].tap()
        app.collectionViews["TabTrayController.collectionView"].swipeDown()
        snapshot("Tabs")
    }

    func test04PrivateBrowsing() {
        // Enter private mode
        app.buttons["URLBarView.tabsButton"].tap()
        app.buttons["TabTrayController.togglePrivateMode"].tap()

        snapshot("PrivateBrowsingEmptyState")

        // Leave private mode
        app.buttons["TabTrayController.togglePrivateMode"].tap()
    }

            //    func test05PrivateBrowsingWithTabs() {
            //        let tabsPerLocale: [String: [String]] = [
            //            "*": [
            //                "https://www.mozilla.org/firefox/private-browsing",
            //                "https://www.ebay.com",
            //                "https://www.amazon.com",
            //                "https://www.expedia.com",
            //            ],
            //            "de": [
            //                "https://www.mozilla.org/firefox/private-browsing",
            //                "https://www.ebay.de",
            //                "https://www.amazon.de",
            //                "https://www.expedia.de",
            //            ],
            //            "fr": [
            //                "https://www.mozilla.org/firefox/private-browsing",
            //                "https://www.ebay.fr",
            //                "https://www.amazon.fr",
            //                "https://www.expedia.fr",
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
            //
            //        snapshot("PrivateBrowsingWithTabs")
            //
            //        // Leave private mode
            //        app.buttons["TabTrayController.togglePrivateMode"].tap()
            //    }

    func test06ClearPrivateData() {
        // Open the settings
        app.buttons["URLBarView.tabsButton"].tap()
        app.buttons["TabTrayController.settingsButton"].tap()

        // Open CPD Settings
        let clearPrivateDataCell = app.tables.cells["ClearPrivateData"]
        clearPrivateDataCell.tap()

        // Press CPD Button
        let clearPrivateDataButton = app.tables.cells["ClearPrivateData"]
        clearPrivateDataButton.tap()

        // Confirm dialog
        let button = app.alerts.elementBoundByIndex(0).collectionViews.buttons.elementBoundByIndex(1)
        button.tap()
    }

    func test07History() {

        // TODO Needs a Clear Private Data first

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

        for url in (historyLastMonthPerLocale[NSLocale.currentLocale().localeIdentifier] ?? historyLastMonthPerLocale["*"]!).reverse() {
            loadWebPage(url, waitForLoadToFinish: false)
            sleep(5)
        }

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

        // Create a new tab so that the location bar shows the placeholder
        app.buttons["URLBarView.tabsButton"].tap()
        app.buttons["TabTrayController.addTabButton"].tap()

        // Select the history panel
        app.textFields["url"].tap()
        app.buttons["HomePanels.History"].tap()

        let _ = NSData(contentsOfURL: NSURL(string: "http://localhost:6571/snapshottest/hidekeyboard")!)
        sleep(3)

        snapshot("History")
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
