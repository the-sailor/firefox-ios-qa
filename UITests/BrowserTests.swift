/* This Source Code Form is subject to the terms of the Mozilla Public
* License, v. 2.0. If a copy of the MPL was not distributed with this
* file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Storage
@testable import Client

class BrowserTests: KIFTestCase {

    private var webRoot: String!

    override func setUp() {
        webRoot = SimplePageServer.start()
    }

    override func tearDown() {
        BrowserUtils.resetToAboutHome(tester())
        super.tearDown()
    }

    func testDisplaySharesheetWhileJSPromptOccurs() {
        let url = "\(webRoot)/JSPrompt.html"
        tester().tapViewWithAccessibilityIdentifier("url")
        tester().clearTextFromAndThenEnterTextIntoCurrentFirstResponder("\(url)\n")
        tester().waitForWebViewElementWithAccessibilityLabel("JS Prompt")
        // Show share sheet and wait for the JS prompt to fire
        tester().tapViewWithAccessibilityLabel("Share")
        tester().waitForTimeInterval(5)
        tester().tapViewWithAccessibilityLabel("Cancel")

        // Check to see if the JS Prompt is dequeued and showing
        tester().waitForViewWithAccessibilityLabel("OK")
        tester().tapViewWithAccessibilityLabel("OK")
    }

    func testSwitchingTabsUpdateReaderModeIcon() {
        let nonReadable = "\(webRoot)/numberedPage.html?page=1"
        let readable = "\(webRoot)/readablePage.html"

        tester().tapViewWithAccessibilityIdentifier("url")
        tester().clearTextFromAndThenEnterTextIntoCurrentFirstResponder("\(nonReadable)\n")
        tester().waitForWebViewElementWithAccessibilityLabel("Page 1")

        tester().tapViewWithAccessibilityLabel("Show Tabs")
        tester().tapViewWithAccessibilityLabel("Add Tab")

        tester().tapViewWithAccessibilityIdentifier("url")
        tester().clearTextFromAndThenEnterTextIntoCurrentFirstResponder("\(readable)\n")

        XCTAssertTrue(tester().viewExistsWithLabel("Reader View"), "Check that reader view is shown")

        tester().tapViewWithAccessibilityLabel("Show Tabs")
        tester().tapViewWithAccessibilityLabel("Page 1")

        XCTAssertFalse(tester().viewExistsWithLabel("Reader View"), "Reader view button hidden for non readable page")

        tester().tapViewWithAccessibilityLabel("Show Tabs")
        tester().tapViewWithAccessibilityLabel("Readable page")

        XCTAssertTrue(tester().viewExistsWithLabel("Reader View"), "Check that reader view is shown again when switching back")

        BrowserUtils.resetToAboutHome(tester())
    }

    func testBackForwardBetweenReadableNonReadablePages() {
        let nonReadable = "\(webRoot)/numberedPage.html?page=1"
        let readable = "\(webRoot)/readablePage.html"

        tester().tapViewWithAccessibilityIdentifier("url")
        tester().clearTextFromAndThenEnterTextIntoCurrentFirstResponder("\(nonReadable)\n")
        tester().waitForWebViewElementWithAccessibilityLabel("Page 1")

        tester().tapViewWithAccessibilityIdentifier("url")
        tester().clearTextFromAndThenEnterTextIntoCurrentFirstResponder("\(readable)\n")

        XCTAssertTrue(tester().viewExistsWithLabel("Reader View"), "Check that reader view is shown")
        tester().tapViewWithAccessibilityLabel("Back")
        XCTAssertFalse(tester().viewExistsWithLabel("Reader View"), "Reader view button hidden for non readable page")
        tester().tapViewWithAccessibilityLabel("Forward")
        XCTAssertTrue(tester().viewExistsWithLabel("Reader View"), "Check that reader view is shown again when switching back")
    }

    func testBackForwardBetweenEnabledReadablePage() {
        let nonReadable = "\(webRoot)/numberedPage.html?page=1"
        let readable = "\(webRoot)/readablePage.html"

        tester().tapViewWithAccessibilityIdentifier("url")
        tester().clearTextFromAndThenEnterTextIntoCurrentFirstResponder("\(nonReadable)\n")
        tester().waitForWebViewElementWithAccessibilityLabel("Page 1")

        tester().tapViewWithAccessibilityIdentifier("url")
        tester().clearTextFromAndThenEnterTextIntoCurrentFirstResponder("\(readable)\n")

        tester().tapViewWithAccessibilityLabel("Reader View")
        var readerButton = tester().waitForViewWithAccessibilityLabel("Reader View") as! UIButton
        XCTAssertTrue(readerButton.selected)
        XCTAssertTrue(tester().viewExistsWithLabel("Add to Reading List"), "Reader mode bar is visible when enabled")

        tester().tapViewWithAccessibilityLabel("Back")

        readerButton = tester().waitForViewWithAccessibilityLabel("Reader View") as! UIButton
        XCTAssertFalse(readerButton.selected)
        XCTAssertFalse(tester().viewExistsWithLabel("Add to Reading List"), "Reader mode bar is gone when disabled")

        tester().tapViewWithAccessibilityLabel("Forward")

        readerButton = tester().waitForViewWithAccessibilityLabel("Reader View") as! UIButton
        XCTAssertTrue(readerButton.selected)
        XCTAssertTrue(tester().viewExistsWithLabel("Add to Reading List"), "Reader mode bar is visisble when enabled")
    }
}