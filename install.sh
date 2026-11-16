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

unzip -qo "$TMP_ZIP" -d /Applications/
rm -f "$TMP_ZIP"

xattr -cr /Applications/Retain.app 2>/dev/null || true

# Refresh LaunchServices registration
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/Retain.app 2>/dev/null || true

# TCC reset removes this app's existing Full Disk Access grant. Keep it opt-in.
if [ "${RETAIN_RESET_TCC:-0}" = "1" ]; then
    tccutil reset SystemPolicyAllFiles com.empatika.Retain 2>/dev/null || true
else
    echo "ℹ️ Keeping existing Full Disk Access permissions. Set RETAIN_RESET_TCC=1 to reset them."
fi

echo "✅ Retain successfully installed to /Applications/Retain.app!"
echo "🚀 Launching Retain..."
open /Applications/Retain.app
