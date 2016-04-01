#!/bin/sh

if [ ! -d firefox-ios-l10n ]; then
    echo "Did not find a firefox-ios-l10n checkout. Are you running this on a localized build?"
    exit 1
fi

if [ -d marketing-screenshots ]; then
  echo "The marketing-screenshots directory already exists. You decide."
  exit 1
fi

mkdir marketing-screenshots

DEVICES="iPhone 4s,iPhone 5s,iPhone 6s,iPhone 6s Plus,iPad Air,iPad Pro"

DEVICES="iPhone 4s,iPhone 5s,iPhone 6s,iPhone 6s Plus"
LANGUAGES="en-US,de,fr"

SNAPSHOT=/Users/sarentz/Projects/fastlane/snapshot/bin/snapshot
SNAPSHOT=snapshot

echo "`date` Snapshotting $lang"
$SNAPSHOT --project Client.xcodeproj --scheme MarketingSnapshotTests \
    --derived_data_path marketing-screenshots-dd \
    --erase_simulator \
    --devices "$DEVICES" \
    --languages "$LANGUAGES" \
    --output_directory marketing-screenshots # > marketing-screenshots.log 2>&1

