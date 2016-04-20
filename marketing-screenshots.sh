#!/bin/sh

LANGUAGES="en-US de-DE fr-FR"
DEVICES="iPhone 4s,iPhone 5s,iPhone 6s,iPhone 6s Plus,iPad Air,iPad Pro"
DEVICES="iPhone 4s,iPhone 5s,iPhone 6s,iPhone 6s Plus"
SNAPSHOT=/Users/sarentz/Projects/fastlane/snapshot/bin/snapshot

LANGUAGES="fr-FR"
DEVICES="iPhone 4s"

if [ ! -d firefox-ios-l10n ]; then
    echo "Did not find a firefox-ios-l10n checkout. Are you running this on a localized build?"
    exit 1
fi

if [ -d marketing-screenshots ]; then
  echo "The marketing-screenshots directory already exists. You decide."
  exit 1
fi

mkdir marketing-screenshots

for lang in $LANGUAGES; do
  echo "`date` Snapshotting $lang"
  mkdir marketing-screenshots/$lang
  $SNAPSHOT --project Client.xcodeproj --scheme MarketingUITests \
    --derived_data_path marketing-screenshots-dd \
    --erase_simulator \
    --localize_simulator \
    --devices "$DEVICES" \
    --languages $lang \
    --output_directory marketing-screenshots/$lang # > marketing-screenshots.log 2>&1
done

