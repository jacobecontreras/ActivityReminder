#!/bin/bash
set -e

APP_NAME="ActivityReminder"
SWIFT_FILE="activityReminder.swift"
APP_BUNDLE="${APP_NAME}.app"
BUILD_TMP="build_tmp"
ICON_SOURCE="icon.png"

echo "Building ${APP_BUNDLE}..."

# Cleanup previous builds
rm -rf "${APP_BUNDLE}" "${BUILD_TMP}" "${APP_NAME}.zip"
mkdir -p "${BUILD_TMP}/Contents/MacOS"
mkdir -p "${BUILD_TMP}/Contents/Resources"

# Create Info.plist
cat <<EOF > "${BUILD_TMP}/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key><string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key><string>com.user.${APP_NAME}</string>
    <key>CFBundleName</key><string>${APP_NAME}</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>LSUIElement</key><true/>
    <key>CFBundleIconFile</key><string>AppIcon</string>
</dict>
</plist>
EOF

# Handle Icon
if [ -f "$ICON_SOURCE" ]; then
    ICONSET="AppIcon.iconset"
    mkdir -p "$ICONSET"
    for sz in 16 32 128 256 512; do
        sips -z $sz $sz "$ICON_SOURCE" --out "${ICONSET}/icon_${sz}x${sz}.png" > /dev/null 2>&1
        sips -z $((sz*2)) $((sz*2)) "$ICON_SOURCE" --out "${ICONSET}/icon_${sz}x${sz}@2x.png" > /dev/null 2>&1
    done
    iconutil -c icns "$ICONSET" -o "${BUILD_TMP}/Contents/Resources/AppIcon.icns"
    rm -rf "$ICONSET"
fi

# Compile and finalize
swiftc -o "${BUILD_TMP}/Contents/MacOS/${APP_NAME}" "${SWIFT_FILE}" -framework AppKit
mv "${BUILD_TMP}" "${APP_BUNDLE}"
zip -r "${APP_NAME}.zip" "${APP_BUNDLE}" > /dev/null

echo "Success: ${APP_BUNDLE} and ${APP_NAME}.zip created."
