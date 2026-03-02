# WhereUAt - Deployment Guide

## 🚀 Quick Start Deployment

### Prerequisites
- macOS 12.0+
- Xcode 15.0+
- Apple Developer Account (for TestFlight/App Store)
- Valid Apple Developer Certificate

### One-Command Setup
```bash
git clone https://github.com/bobclaw26/whereueat.git
cd whereueat
open WhereUAt.xcodeproj
```

Then in Xcode:
1. Select WhereUAt target
2. Signing & Capabilities
3. Select your team
4. Run (Cmd+R) or Test (Cmd+U)

---

## 📦 TestFlight Deployment

### Step 1: Prepare Build
```bash
# Ensure all tests pass
xcodebuild test \
  -scheme WhereUAt \
  -destination 'generic/platform=iOS Simulator'

# Verify no SwiftLint errors
swiftlint lint WhereUAt --config .swiftlint.yml
```

### Step 2: Archive App
```bash
xcodebuild archive \
  -scheme WhereUAt \
  -archivePath ./WhereUAt.xcarchive \
  -configuration Release \
  -allowProvisioningUpdates
```

### Step 3: Export & Sign
```bash
xcodebuild -exportArchive \
  -archivePath ./WhereUAt.xcarchive \
  -exportOptionsPlist ./exportOptions.plist \
  -exportPath ./build \
  -allowProvisioningUpdates
```

### Step 4: Upload to TestFlight
**Option A: Xcode GUI**
1. Window → Organizer
2. Archives tab
3. Select WhereUAt archive
4. Distribute App → TestFlight & App Store
5. Follow prompts

**Option B: Command Line**
```bash
xcrun altool --upload-app \
  --file ./build/WhereUAt.ipa \
  --type ios \
  --apiKey <KEY_ID> \
  --apiIssuer <ISSUER_ID>
```

**Option C: Transporter App**
1. Download Transporter from App Store
2. Sign in with Apple ID
3. Add WhereUAt.ipa
4. Submit

### Step 5: Manage TestFlight
1. Go to App Store Connect (https://appstoreconnect.apple.com)
2. Select WhereUAt app
3. TestFlight → iOS
4. Add internal testers (your Apple ID)
5. Wait for processing (5-10 minutes)
6. Send invite link to testers

---

## 🔐 API Key Configuration

### Before First Build
Create `.env.local` in project root:
```bash
FOURSQUARE_API_KEY=YOUR_KEY_HERE
SQUARE_API_KEY=YOUR_KEY_HERE
GEMINI_API_KEY=YOUR_KEY_HERE
```

### Load Environment Variables
Add to `WhereUAtApp.swift` or build phase script:
```swift
import Foundation

let foursquareKey = ProcessInfo.processInfo.environment["FOURSQUARE_API_KEY"] ?? ""
let squareKey = ProcessInfo.processInfo.environment["SQUARE_API_KEY"] ?? ""
let geminiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? ""
```

### Alternative: Xcode Build Settings
1. Select WhereUAt project
2. Build Settings
3. Add User-Defined Settings:
   - `FOURSQUARE_API_KEY`
   - `SQUARE_API_KEY`
   - `GEMINI_API_KEY`
4. Set values for Release and Debug configs

### Alternative: Secrets Configuration File
```swift
// Secrets.swift (Git-ignored, locally created)
struct APIKeys {
    static let foursquare = "sk-XXXXX..."
    static let square = "sq_live_XXXXX..."
    static let gemini = "AIzaSyXXXX..."
}
```

---

## ✅ Pre-Deployment Checklist

### Code Quality (Required)
- [ ] All unit tests passing (80%+ coverage)
- [ ] All integration tests passing
- [ ] SwiftLint clean (`swiftlint lint WhereUAt`)
- [ ] No Xcode warnings
- [ ] No hardcoded API keys or secrets
- [ ] All TODOs addressed or removed

### Functionality (Required)
- [ ] Map view displays venues
- [ ] Chat messages send/receive
- [ ] Friend feed loads activities
- [ ] Profile page displays user info
- [ ] Tickets show upcoming and past
- [ ] Authentication flow works

### Configuration (Required)
- [ ] API keys configured
- [ ] Bundle ID matches certificate
- [ ] Provisioning profile updated
- [ ] Version number bumped
- [ ] Build number incremented
- [ ] App description/keywords updated

### Security (Required)
- [ ] HTTPS for all API calls
- [ ] No console logging of sensitive data
- [ ] App Transport Security configured
- [ ] Certificate pinning (optional)
- [ ] Rate limiting on API calls

### Documentation (Required)
- [ ] README updated with version
- [ ] CHANGELOG.md created
- [ ] Setup instructions tested
- [ ] API documentation current

---

## 🔄 GitHub Actions CI/CD

### Automated Pipeline Runs On
- Every push to `main` or `develop`
- Every pull request
- Manual trigger

### Pipeline Steps
1. **Build** - Compile Swift code
2. **Test** - Run unit + integration tests
3. **Lint** - SwiftLint code quality check
4. **Security** - Check for hardcoded secrets
5. **TestFlight** - Build and upload (main only)

### Configure GitHub Secrets
For automated TestFlight uploads, add to repo settings:
```
APPSTORE_ISSUER_ID = <UUID>
APPSTORE_KEY_ID = <KEY_ID>
APPSTORE_PRIVATE_KEY = <PRIVATE_KEY>
```

Get these from:
1. App Store Connect → Users & Access
2. Keys tab
3. Create or use existing key
4. Copy Issuer ID and Key ID
5. Download private key (JSON)

---

## 🐛 Troubleshooting Deployment

### Issue: "Provisioning Profile Invalid"
```bash
# Delete old provisioning profiles
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/

# Or in Xcode:
# Preferences → Accounts → Manage Certificates
# Delete and re-download
```

### Issue: "Certificate Expired"
```bash
# Create new certificate in Apple Developer Portal
# Download and install
# Update provisioning profile
# Rebuild project
```

### Issue: "Build Number Increment Needed"
```bash
# Xcode: General → Version/Build
# Increment Build number before archive
```

### Issue: "App Size Too Large"
```bash
# Check what's using space
ls -lh WhereUAt.xcarchive/Products/Applications/WhereUAt.app/

# Remove unused assets
# Compress images
# Enable bitcode (if applicable)
```

### Issue: "TestFlight Upload Stuck"
```bash
# Check upload status in Transporter app
# Or via command line:
xcrun altool --list-apps \
  --apiKey <KEY_ID> \
  --apiIssuer <ISSUER_ID>
```

---

## 📊 Deployment Monitoring

### Check Build Status
```bash
# In Xcode: Report Navigator (Cmd+9)
# Shows all build logs and details
```

### Monitor TestFlight
1. App Store Connect
2. TestFlight → iOS
3. Build version tab
4. Check processing status
5. Monitor tester feedback

### Check App Logs
```bash
# Connect iPhone
# Xcode: Window → Devices and Simulators
# Select device → View Device Logs
# Or Console.app on macOS
```

---

## 🎯 App Store Release Workflow

### For Full App Store Release
1. Create App Store Connect record
2. Fill in app information
3. Add screenshots for all devices
4. Configure pricing & availability
5. Submit for review
6. Monitor review status (24-48 hours)
7. Release when approved

### Build Archive
Same as TestFlight, but submit to "App Store" instead

### Version Numbering
- Semantic: MAJOR.MINOR.PATCH (1.0.0)
- Build number: Sequential integer
- Example: v1.0.0 (Build 1)

---

## 📈 Post-Deployment

### Monitor Crashes
1. App Store Connect → Analytics → Crashes
2. Investigate frequently crashing builds
3. Release hotfix if needed

### Gather Feedback
1. TestFlight feedback from testers
2. App Store reviews
3. In-app feedback mechanism

### Plan Next Release
1. Review collected feedback
2. Prioritize bug fixes
3. Plan new features
4. Create release notes

---

## ⚙️ Advanced Configuration

### Code Signing in CI/CD
```yaml
# .github/workflows/ci.yml
- name: Install Certificate
  uses: apple-actions/import-codesign-certs@v1
  with:
    p12-file-base64: ${{ secrets.APPLE_CERTIFICATE_P12 }}
    p12-password: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}

- name: Install Provisioning Profile
  uses: apple-actions/download-provisioning-profiles@v1
  with:
    bundle-id: 'com.yourcompany.whereueat'
```

### Automatic Version Bumping
```bash
#!/bin/bash
# bump-version.sh
CURRENT=$(agvtool mread -terse1)
NEW=$((CURRENT + 1))
agvtool mset $NEW
```

### Notarization (for macOS)
```bash
xcrun notarytool submit WhereUAt.dmg \
  --apple-id <APPLE_ID> \
  --password <PASSWORD> \
  --team-id <TEAM_ID>
```

---

## 📞 Support Resources

- **Apple Developer Support**: developer.apple.com/support
- **Xcode Help**: Help → Xcode Help
- **GitHub Actions Docs**: docs.github.com/en/actions
- **SwiftUI Documentation**: developer.apple.com/xcode/swiftui

---

## Deployment Summary

| Stage | Tool | Command | Time |
|-------|------|---------|------|
| Build | Xcode | `xcodebuild archive` | 5 min |
| Test | Xcode | `xcodebuild test` | 3 min |
| Lint | SwiftLint | `swiftlint lint` | 1 min |
| Sign | Xcode | Automatic | 2 min |
| Upload | Transporter | Manual or `altool` | 5 min |
| Process | TestFlight | Automatic | 10 min |
| Review | App Store | Manual | 24-48h |

**Total Build Time: ~15 minutes**
**Total Deployment: 1-2 days** (with App Store review)

---

**Status**: Production Ready ✅  
**Last Updated**: 2026-03-02
