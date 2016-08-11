/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

@available(iOS 9.0, *)
class BrowserViewControllerV2: UIViewController {
    private var chromeView: ChromeView {
        return view as! ChromeView
    }

    private let browserModel: BrowserModel
    private let toolbarController: BrowserToolbarController

    init(
        browserModel: BrowserModel,
        toolbarController: BrowserToolbarController = BrowserToolbarController()
    ) {
        self.browserModel = browserModel
        self.toolbarController = toolbarController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let chrome = ChromeView(frame: UIScreen.mainScreen().bounds)
        chrome.translatesAutoresizingMaskIntoConstraints = false
        self.view = chrome
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindToolbarSelectors()
        showWebView()

        browserModel.webView.loadRequest(NSURLRequest(URL: NSURL(string: "https://www.mozilla.org")!))
    }
}

// MARK: Content Management
@available(iOS 9.0, *)
extension BrowserViewControllerV2 {
    func showWebView() {
        let webViewController = FirefoxWebViewController(browserModel: browserModel)
        webViewController.willMoveToParentViewController(self)
        chromeView.setContentView(webViewController.view)
        webViewController.didMoveToParentViewController(self)
    }

    func showHomeView() {
        
    }
}

// MARK: Selectors
@available(iOS 9.0, *)
extension BrowserViewControllerV2 {
    private func bindToolbarSelectors() {
        // Bind bottom toolbar buttons
//        chromeView.toolbar.backButton.addTarget(self, action: #selector(BrowserViewController.tappedBack), for: .touchUpInside)
//        chromeView.toolbar.forwardButton.addTarget(self, action: #selector(BrowserViewController.tappedForward), for: .touchUpInside)
//        chromeView.toolbar.refreshButton.addTarget(self, action: #selector(BrowserViewController.tappedRefresh), for: .touchUpInside)
//        chromeView.toolbar.shareButton.addTarget(self, action: #selector(BrowserViewController.tappedShare), for: .touchUpInside)

        // Bind URL bar toolbar buttons
        chromeView.urlBar.backButton.addTarget(self, action: #selector(BrowserViewControllerV2.tappedBack), forControlEvents: .TouchUpInside)
        chromeView.urlBar.forwardButton.addTarget(self, action: #selector(BrowserViewControllerV2.tappedForward), forControlEvents: .TouchUpInside)
        chromeView.urlBar.refreshButton.addTarget(self, action: #selector(BrowserViewControllerV2.tappedRefresh), forControlEvents: .TouchUpInside)
        chromeView.urlBar.shareButton.addTarget(self, action: #selector(BrowserViewControllerV2.tappedShare), forControlEvents: .TouchUpInside)
    }

    func tappedBack() { toolbarController.goBack() }

    func tappedForward() { toolbarController.goForward() }

    func tappedRefresh() { toolbarController.refresh() }

    func tappedStop() { toolbarController.stop() }

    func tappedShare() { toolbarController.share() }
}





