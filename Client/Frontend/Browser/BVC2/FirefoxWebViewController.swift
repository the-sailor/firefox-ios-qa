/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import WebKit

class FirefoxWebViewController: UIViewController {
    let webViewCallbackController: WebViewCallbackController

    private let browserModel: BrowserModel

    private var webView: WKWebView {
        return self.view as! WKWebView
    }

    override func loadView() {
        view = browserModel.webView
    }

    init(browserModel: BrowserModel, callbackController: WebViewCallbackController = WebViewCallbackController()) {
        self.browserModel = browserModel
        self.webViewCallbackController = callbackController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        webView.uiDelegate = webViewCallbackController
//        webView.navigationDelegate = webViewCallbackController
    }
}
