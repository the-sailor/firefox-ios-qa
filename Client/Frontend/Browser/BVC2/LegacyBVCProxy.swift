/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit

class BrowserViewControllerV2Proxy: NSObject, BrowserViewController {

    @available(iOS 9.0, *)
    private lazy var bvc2: BrowserViewControllerV2 = {
        let webView = WKWebView()
        return BrowserViewControllerV2(browserModel: BrowserModel(webView: webView))
    }()

    var viewController: UIViewController {
        if #available(iOS 9.0, *) {
            return bvc2
        } else {
            return UIViewController()
        }
    }

    // View Controller properties to satisfy existing uses
    var restorationIdentifier: String? = nil

    var restorationClass: AnyObject.Type? = nil

    var traitCollection: UITraitCollection {
        return viewController.traitCollection
    }

    var view: UIView! {
        return viewController.view
    }

    var homePanelController: HomePanelViewController? {
        return nil
    }

    var tabManager: TabManager


    // BrowserTrayAnimator uses these for frame references
    var webViewContainerBackdrop: UIView! { return UIView() }
    var urlBar: URLBarView! { return URLBarView(frame: CGRect.zero) }
    var header: BlurWrapper! { return BlurWrapper(view: UIView()) }
    var headerBackdrop: UIView! { return UIView() }
    var footer: UIView! { return UIView() }
    var footerBackdrop: UIView! { return UIView() }
    var readerModeBar: ReaderModeBarView? { return nil }
    var webViewContainer: UIView! { return UIView() }
    var toolbar: TabToolbar? { return nil }


    init(tabManager: TabManager) {
        self.tabManager = tabManager
        super.init()
    }

    // Most of these seem pretty leaky and should not be exposed
    func toggleSnackBarVisibility(show show: Bool) {}

    func openBlankNewTabAndFocus(isPrivate isPrivate: Bool) {}

    func presentIntroViewController(force: Bool) -> Bool {
        return false
    }

    func switchToTabForURLOrOpen(url: NSURL, isPrivate: Bool) {}

    func shouldShowFooterForTraitCollection(previousTraitCollection: UITraitCollection) -> Bool {
        return true
    }

    func tabTrayDidDismiss(tabTray: TabTrayController) {}

    func loadQueuedTabs() {}

    func openURLInNewTab(url: NSURL?, isPrivate: Bool) {}

    func addBookmark(tabState: TabState) {}
    
    @available(iOS 9, *)
    func switchToPrivacyMode(isPrivate isPrivate: Bool) {}
}
