#!/usr/bin/env bash
set -e

REPO="tolmachevmaxim/retain"
echo "🔍 Fetching latest Retain release from https://github.com/$REPO..."

# Get latest release download URL via GitHub API
DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep "browser_download_url.*\.zip" | cut -d : -f 2,3 | tr -d ' "')

if [ -z "$DOWNLOAD_URL" ]; then
    DOWNLOAD_URL="https://github.com/$REPO/releases/download/v0.1.11-antigravity/Retain-v0.1.11-antigravity-arm64.zip"
fi

TMP_ZIP="/tmp/Retain-latest.zip"
echo "⬇️ Downloading Retain ($DOWNLOAD_URL)..."
curl -fL "$DOWNLOAD_URL" -o "$TMP_ZIP"

echo "📦 Installing Retain to /Applications/..."
pkill -f "Retain.app" 2>/dev/null || true
rm -rf /Applications/Retain.app
# Also remove any leftover backup bundles that can collide in LaunchServices/TCC
rm -rf /Applications/Retain.app.original.backup 2>/dev/null || true

unzip -qo "$TMP_ZIP" -d /Applications/
rm -f "$TMP_ZIP"

xattr -cr /Applications/Retain.app 2>/dev/null || true

# Refresh LaunchServices registration
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/Retain.app 2>/dev/null || true

# If upgrading from an official build with a different code signature,
# reset stale TCC Full Disk Access state so macOS grants access to the new binary
tccutil reset SystemPolicyAllFiles com.empatika.Retain 2>/dev/null || true

echo "✅ Retain successfully installed to /Applications/Retain.app!"
echo "🚀 Launching Retain..."
open /Applications/Retain.app
