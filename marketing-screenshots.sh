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
LANGUAGES="en-US,de,fr"

DEVICES="iPhone 6s Plus"
LANGUAGES="en-US,de,fr"

#LANGUAGES="af,ar,az,bg,bn-BD,bn-IN,br,bs,cs,cy,da,de,dsb,el,en-US,eo,es,es-CL,es-MX,fa,fr,fy-NL,ga-IE,gd,gl,hsb,id,is,it,ja,kk,km,kn,ko,lo,lt,lv,ml,ms,my,nb-NO,ne-NP,nl,nn-NO,or,pl,pt-BR,pt-PT,rm,ro,ru,ses,sk,sl,sv-SE,th,tl,tn,tr,uk,uz,zh-CN,zh-TW"

SNAPSHOT=/Users/sarentz/Projects/fastlane/snapshot/bin/snapshot
#SNAPSHOT=snapshot

echo "`date` Snapshotting $lang"
$SNAPSHOT --project Client.xcodeproj --scheme MarketingUITests \
    --derived_data_path marketing-screenshots-dd \
    --erase_simulator \
    --localize_simulator \
    --devices "$DEVICES" \
    --languages "$LANGUAGES" \
    --output_directory marketing-screenshots # > marketing-screenshots.log 2>&1

