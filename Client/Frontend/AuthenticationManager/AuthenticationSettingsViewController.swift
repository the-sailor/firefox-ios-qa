/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import UIKit

class TurnPasscodeOnSetting: Setting {
    override var accessoryType: UITableViewCellAccessoryType { return .DisclosureIndicator }

    init(settings: SettingsTableViewController, delegate: SettingsDelegate? = nil) {
        let title = NSLocalizedString("Turn Passcode On", tableName: "AuthenticationManager", comment: "Title for setting to turn on passcode")
        super.init(title: NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIConstants.TableViewRowTextColor]),
                   delegate: delegate)
    }

    override func onClick(navigationController: UINavigationController?) {
        // Navigate to passcode configuration screen
    }
}

class TurnPasscodeOffSetting: Setting {
    override var accessoryType: UITableViewCellAccessoryType { return .DisclosureIndicator }

    init(settings: SettingsTableViewController, delegate: SettingsDelegate? = nil) {
        let title = NSLocalizedString("Turn Passcode Off", tableName: "AuthenticationManager", comment: "Title for setting to turn off passcode")
        super.init(title: NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIConstants.TableViewRowTextColor]),
                   delegate: delegate)
    }

    override func onClick(navigationController: UINavigationController?) {
        // Navigate to passcode configuration screen
    }
}

class ChangePasscodeSetting: Setting {
    override var accessoryType: UITableViewCellAccessoryType { return .DisclosureIndicator }

    init(settings: SettingsTableViewController, delegate: SettingsDelegate? = nil) {
        let title = NSLocalizedString("Change Passcode", tableName: "AuthenticationManager", comment: "Title for setting to change passcode")
        super.init(title: NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIConstants.TableViewRowTextColor]),
                   delegate: delegate)
    }

    override func onClick(navigationController: UINavigationController?) {
        // Navigate to passcode configuration screen
    }
}

class RequirePasscodeSetting: Setting {
    override var accessoryType: UITableViewCellAccessoryType { return .DisclosureIndicator }

    override var style: UITableViewCellStyle { return .Value1 }

    override var status: NSAttributedString {
        return NSAttributedString(string: NSLocalizedString("Immediately", tableName: "AuthenticationManager", comment: "'Immediately' interval item for selecting when to require passcode"))
    }

    init(settings: SettingsTableViewController, delegate: SettingsDelegate? = nil) {
        let title = NSLocalizedString("Require Passcode", tableName: "AuthenticationManager", comment: "Title for setting to require a passcode")
        super.init(title: NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIConstants.TableViewRowTextColor]),
                   delegate: delegate)
    }

    override func onClick(navigationController: UINavigationController?) {
        // Navigate to passcode configuration screen
    }
}

class AuthenticationSettingsViewController: SettingsTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Touch ID & Passcode", tableName: "AuthenticationManager", comment: "Title for Touch ID/Passcode settings option")
    }

    override func generateSettings() -> [SettingSection] {
        var settings = [SettingSection]()

        let passcodeSectionTitle = NSAttributedString(string: NSLocalizedString("Passcode", tableName: "AuthenticationManager", comment: "List section title for passcode settings"))
        let passcodeSection = SettingSection(title: passcodeSectionTitle, children: [
            TurnPasscodeOffSetting(settings: self),
            ChangePasscodeSetting(settings: self)
        ])

        let prefs = profile.prefs
        let requirePasscodeSection = SettingSection(title: nil, children: [
            RequirePasscodeSetting(settings: self),
            BoolSetting(prefs: prefs,
                prefKey: "touchid.logins",
                defaultValue: false,
                titleText: NSLocalizedString("Use Touch ID", tableName:  "AuthenticationManager", comment: "List section title for when to use Touch ID")
            ),
        ])

        settings += [
            passcodeSection,
            requirePasscodeSection,
        ]

        return settings
    }
}
