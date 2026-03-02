# WhereUAt - Location-Based Nightlife Social App

A modern iOS application built with SwiftUI that helps users discover nightlife venues, connect with friends, and share experiences in real-time.

## 📱 Features

### Core Features
- **Interactive Map** - Real-time venue discovery using MapKit with Foursquare integration
- **Social Network** - Find, follow, and manage friends with friend requests
- **Live Chat** - 24-hour auto-deleting messages for privacy
- **Friends Feed** - Activity stream showing what friends are doing
- **Event Management** - Browse, RSVP, and manage events
- **Ticketing System** - Purchase event tickets with QR code support

### Secondary Features
- **Venue Ranking** - ML-based recommendations powered by Google Gemini
- **Advanced Search** - Discover venues by category, rating, capacity
- **Payment Integration** - Secure ticket purchases via Square Payments
- **Real-time Notifications** - Stay updated on friend activities and events
- **User Profiles** - Customize profile with bio, preferences, and activity history

## 🏗️ Architecture

### Technology Stack
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI (iOS 15+)
- **Database**: Core Data + Firebase Firestore
- **Networking**: URLSession + Combine
- **Package Manager**: Swift Package Manager (SPM)
- **Testing**: XCTest with 80%+ coverage

### Project Structure
```
WhereUAt/
├── App/                          # App entry point
│   └── WhereUAtApp.swift
├── Models/                       # Core data models
│   └── CoreModels.swift         # User, Venue, Message, Event, Ticket, etc.
├── ViewModels/                   # Business logic & state management
│   ├── MapViewModel.swift
│   ├── ChatViewModel.swift
│   ├── FeedViewModel.swift
│   ├── ProfileViewModel.swift
│   └── TicketsViewModel.swift
├── Views/                        # SwiftUI view components
│   ├── MapView.swift
│   ├── ChatView.swift
│   ├── FriendsFeedView.swift
│   ├── ProfileView.swift
│   ├── TicketsView.swift
│   └── LoginView.swift
├── Services/                     # Network & API integration
│   ├── NetworkService.swift      # HTTP client
│   ├── AuthManager.swift         # Auth state management
│   ├── APIServices.swift         # Foursquare, Square, Chat APIs
│   └── TicketService.swift
└── Resources/                    # Assets, strings, configuration

Tests/
├── WhereUAtTests/               # Unit & integration tests
│   ├── UnitTests.swift
│   ├── IntegrationTests.swift
│   └── Mocks.swift              # Mock services for testing
└── WhereUAtIntegrationTests/    # Full integration tests
```

## 🔧 Setup & Installation

### Prerequisites
- macOS 12.0+
- Xcode 15.0+
- Swift 5.9+
- CocoaPods or SPM (already configured)

### Step 1: Clone Repository
```bash
git clone https://github.com/bobclaw26/whereueat.git
cd whereueat
```

### Step 2: Install Dependencies
```bash
# Using Swift Package Manager (automatic in Xcode)
# Or manually
swift package resolve
```

### Step 3: Configure API Keys
Create `.env.local` file in project root:
```
FOURSQUARE_API_KEY=your_foursquare_api_key
SQUARE_API_KEY=your_square_api_key
GEMINI_API_KEY=your_gemini_api_key
```

Or add to Xcode Build Settings:
1. Select WhereUAt project
2. Build Settings
3. Add User-Defined Settings for each API key

### Step 4: Build & Run
```bash
# Open in Xcode
open WhereUAt.xcodeproj

# Or build from command line
xcodebuild build \
  -scheme WhereUAt \
  -destination 'generic/platform=iOS'
```

## 🧪 Testing

### Run All Tests
```bash
xcodebuild test \
  -scheme WhereUAt \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug \
  -enableCodeCoverage YES
```

### Run Specific Test Suite
```bash
# Unit tests
xcodebuild test \
  -scheme WhereUAt \
  -only-testing WhereUAtTests

# Integration tests
xcodebuild test \
  -scheme WhereUAt \
  -only-testing WhereUAtIntegrationTests
```

### Check Code Coverage
```bash
# Generate coverage report
xcodebuild test \
  -scheme WhereUAt \
  -enableCodeCoverage YES \
  -resultBundlePath ./coverage.xcresult
```

### Code Quality
```bash
# Run SwiftLint
swiftlint lint WhereUAt --config .swiftlint.yml

# Fix SwiftLint issues
swiftlint autocorrect WhereUAt
```

## 🔐 Security & API Configuration

### API Key Management
✅ **SECURE:** All API keys stored in environment variables or Xcode build settings
✅ **HTTPS ONLY:** All network requests use encrypted HTTPS
✅ **AUTHENTICATION:** OAuth 2.0 for user authentication
✅ **ENCRYPTION:** Sensitive data encrypted at rest (Core Data + Keychain)

### Integrated APIs
1. **Foursquare Places API** - Venue discovery and details
2. **OpenStreetMap** - Map tiles and geocoding (open source)
3. **Square Payments** - Secure payment processing
4. **Google Gemini** - ML-based venue recommendations
5. **Firebase** - Real-time database and authentication (optional)

### Testing Security
```bash
# Check for hardcoded secrets
grep -r "password.*=" WhereUAt/
grep -r "apiKey.*=\"" WhereUAt/
grep -r "secret.*=" WhereUAt/
```

## 📦 Deployment

### TestFlight Deployment

#### Prerequisites
- Apple Developer Account
- App ID registered in App Store Connect
- Valid provisioning profile and certificate

#### Build for TestFlight
```bash
# Create archive
xcodebuild archive \
  -scheme WhereUAt \
  -archivePath ./WhereUAt.xcarchive \
  -configuration Release

# Export for app store
xcodebuild -exportArchive \
  -archivePath ./WhereUAt.xcarchive \
  -exportOptionsPlist ./exportOptions.plist \
  -exportPath ./build
```

#### Upload to TestFlight
```bash
# Using Xcode
# 1. Product → Archive
# 2. Window → Organizer
# 3. Select archive → Distribute App
# 4. Choose "TestFlight & App Store"

# Or use xcrun
xcrun altool --upload-app \
  --file ./WhereUAt.ipa \
  --type ios \
  --apiKey ISSUER_ID \
  --apiIssuer ISSUER_UUID
```

### Code Signing Configuration

#### Automatic Signing (Recommended)
1. Select WhereUAt project
2. Signing & Capabilities
3. Enable "Automatically manage signing"
4. Select team

#### Manual Signing
1. Create provisioning profile in Apple Developer
2. Download and install certificate
3. Configure in Xcode:
   - Project → Build Settings
   - Set `CODE_SIGN_IDENTITY`
   - Set `PROVISIONING_PROFILE_SPECIFIER`

### CI/CD Pipeline

GitHub Actions workflow automatically:
- Runs tests on every push/PR
- Performs code quality checks (SwiftLint)
- Runs security audits
- Builds TestFlight binary on main branch
- Uploads to TestFlight (requires secrets)

#### Configure Secrets
Add to GitHub repository secrets:
- `APPSTORE_ISSUER_ID` - App Store Connect issuer ID
- `APPSTORE_KEY_ID` - App Store Connect key ID
- `APPSTORE_PRIVATE_KEY` - App Store Connect private key

## 📊 Quality Gates

### Minimum Requirements
- ✅ **Test Coverage**: 80%+ code coverage
- ✅ **All Tests Pass**: Unit + integration tests
- ✅ **Security**: No hardcoded secrets, HTTPS only
- ✅ **Code Quality**: SwiftLint clean (zero critical violations)
- ✅ **Build**: Zero warnings, successful compilation

### Coverage Report
```bash
# Generate and view coverage
xcodebuild test \
  -scheme WhereUAt \
  -enableCodeCoverage YES \
  -resultBundlePath ./coverage.xcresult

# View in Xcode
open ./coverage.xcresult
```

## 🗄️ Database Schema

### 10 Core Tables

| Table | Purpose | Key Fields |
|-------|---------|-----------|
| `users` | User profiles & authentication | id, email, username, rating |
| `venues` | Nightlife venues | id, name, location, rating |
| `friendships` | Friend connections | userId, friendId, status |
| `activity` | User activities (check-ins, etc) | id, userId, venueId, type |
| `going` | Event attendance | userId, eventId, status |
| `events` | Event information | id, venueId, title, date |
| `tickets` | Event tickets | id, eventId, userId, qrCode |
| `transactions` | Payment records | id, userId, amount, status |
| `messages` | Chat messages | id, senderId, recipientId, expiresAt |
| `recommendations` | ML-based rankings | venueId, score, timestamp |

## 🚀 Building & Deploying

### Build Steps
1. **Clean Build Folder** - Remove old artifacts
2. **Resolve Dependencies** - Download SPM packages
3. **Compile** - Swift compiler generates binary
4. **Link** - Link frameworks and libraries
5. **Code Sign** - Apply certificate
6. **Test** - Run test suite (80%+ coverage)
7. **Archive** - Create .xcarchive for distribution

### Deployment Checklist
- [ ] All tests passing (80%+ coverage)
- [ ] SwiftLint clean
- [ ] No security issues
- [ ] Build succeeds without warnings
- [ ] API keys configured (not hardcoded)
- [ ] Provisioning profile updated
- [ ] Version number bumped
- [ ] Release notes prepared
- [ ] TestFlight builds available

## 📝 Development Guidelines

### Code Style
- Follow Swift API Design Guidelines
- Use MVVM architecture pattern
- Combine for reactive programming
- SwiftUI for UI components
- Async/await for async operations

### Commit Messages
```
feat: Add venue search filtering
fix: Correct message expiration time
docs: Update README with setup instructions
test: Add integration tests for authentication
refactor: Improve network layer structure
```

### Pull Request Process
1. Create feature branch: `git checkout -b feature/feature-name`
2. Make changes and commit
3. Push to GitHub
4. Create Pull Request
5. Ensure CI/CD passes
6. Get code review
7. Merge to develop/main

## 🐛 Troubleshooting

### Build Issues
**Problem**: "Xcode cannot find Swift compiler"
```bash
sudo xcode-select --reset
```

**Problem**: "Cannot resolve dependency"
```bash
swift package update
rm -rf .build/
```

### Runtime Issues
**Problem**: "API key not found"
- Verify `.env.local` exists
- Check Xcode Build Settings
- Verify environment variable export

**Problem**: "Networking error"
- Ensure HTTPS URLs
- Check network connectivity
- Verify API credentials

## 📞 Support & Contributing

### Contributing
1. Fork the repository
2. Create feature branch
3. Submit pull request with tests
4. Code review required

### Issues
Report bugs via GitHub Issues with:
- Steps to reproduce
- Expected vs actual behavior
- Device/iOS version
- Xcode version

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 👨‍💻 Team

Built with agentic software team orchestration:
- **Architect** - iOS architecture & API design
- **Builder** - Swift implementation & UI
- **Tester** - Test suite & quality assurance
- **Validator** - Security & code standards
- **Deployer** - CI/CD & TestFlight

---

**Status**: Ready for TestFlight  
**Last Updated**: 2026-03-02  
**Repository**: https://github.com/bobclaw26/whereueat
