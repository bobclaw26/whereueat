# WhereUAt - Architecture Documentation

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        iOS App (SwiftUI)                        │
├──────────────────────────┬──────────────────────────────────────┤
│      UI Layer            │      Business Logic Layer            │
│  - Views                 │  - ViewModels                        │
│  - Screens               │  - State Management                  │
│                          │  - Data Transformation               │
├──────────────────────────┼──────────────────────────────────────┤
│              Services & Networking Layer                         │
│  - AuthManager           - ChatService         - SquarePayments │
│  - LocationManager       - FeedService         - NetworkService │
│  - FoursquareService     - TicketService                        │
└─────────────────────────────────────────────────────────────────┘
         ↓              ↓              ↓              ↓
┌──────────────┬──────────────┬──────────────┬──────────────┐
│  Foursquare  │  OpenStreet  │ Square       │   Firebase   │
│  Places API  │  Map / Maps  │  Payments    │   (Optional) │
│              │              │  API         │              │
└──────────────┴──────────────┴──────────────┴──────────────┘
```

## Design Patterns

### 1. MVVM (Model-View-ViewModel)
- **Models** - Data structures (User, Venue, Message, etc.)
- **Views** - SwiftUI components (MapView, ChatView, etc.)
- **ViewModels** - Business logic and state (MapViewModel, ChatViewModel, etc.)

### 2. Repository Pattern
- `NetworkService` acts as data source abstraction
- API services implement specific endpoints
- Mock services for testing

### 3. Dependency Injection
- Services injected into ViewModels
- Facilitates testing with mock implementations
- Loose coupling between components

### 4. Observer Pattern
- `@Published` properties for reactivity
- `Combine` framework for data binding
- SwiftUI automatic UI updates

## Data Flow

```
User Interaction
    ↓
View (SwiftUI)
    ↓
ViewModel (@ObservedObject)
    ↓
Service (NetworkService)
    ↓
API (Foursquare, Square, etc.)
    ↓
Response Processing
    ↓
@Published State Update
    ↓
View Redraw (Automatic)
```

## Module Organization

### App Module
- **WhereUAtApp.swift** - App entry point, tab bar setup

### Models Module
- **CoreModels.swift** - All data structures
  - User, Venue, Message, Event, Ticket, Transaction
  - Friendship, Activity, Going, Conversation
  - Codable for JSON serialization

### ViewModels Module
- **MapViewModel** - Map state and venue search
- **ChatViewModel** - Chat conversations and messages
- **FeedViewModel** - Friends activity feed
- **ProfileViewModel** - User profile and settings
- **TicketsViewModel** - Event tickets management

### Views Module
- **MapView** - Interactive map with venue markers
- **ChatView** - Chat interface and messaging
- **FriendsFeedView** - Friends activity stream
- **ProfileView** - User profile and settings
- **TicketsView** - Upcoming and past tickets
- **LoginView** - Authentication interface

### Services Module
- **NetworkService** - Base HTTP client
- **AuthService** - User authentication
- **AuthManager** - Auth state management
- **FoursquareService** - Venue search API
- **ChatService** - Message and conversation APIs
- **FeedService** - Activity feed APIs
- **TicketService** - Ticket purchasing APIs
- **SquarePaymentsService** - Payment processing

## API Integration Architecture

### Foursquare Places API
```swift
FoursquareService
  ├── searchVenues(lat, lon, category, radius)
  ├── getVenueDetails(id)
  └── searchByCategory(category)
```

### Square Payments API
```swift
SquarePaymentsService
  ├── createPayment(amount, source, description)
  ├── refundPayment(id)
  └── listTransactions()
```

### Custom Backend APIs
```swift
AuthService
ChatService
FeedService
TicketService
```

## State Management

### Local State
- Used in individual ViewModels
- `@State` for simple values
- `@Published` for complex objects

### Global State
- `AuthManager` - Current user, authentication status
- `LocationManager` - User location

### Persistent State
- `UserDefaults` - User preferences
- `Core Data` - Local database
- Keychain - Sensitive data (auth tokens)

## Network Layer

### Request Flow
1. ViewModel calls Service method
2. Service creates URLRequest
3. NetworkService executes request
4. Response validated and decoded
5. ViewModel updates @Published properties
6. SwiftUI redraws automatically

### Error Handling
```swift
enum NetworkError: LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
    case unauthorized
    case serverError(Int)
}
```

## Testing Architecture

### Unit Tests
- Model creation and validation
- Enum testing
- Data encoding/decoding
- Validation logic

### Integration Tests
- Service method testing with mocks
- Data flow testing
- Authentication flow
- Chat message flow

### Mock Services
```swift
MockAuthService
MockNetworkService
MockURLSession
TestDataGenerator
```

## Performance Considerations

### Image Loading
- Lazy loading with AsyncImage
- Caching in memory
- Downsizing for network efficiency

### Pagination
- Feed pagination (20 items per page)
- Lazy loading on scroll
- hasMoreData flag for optimization

### Database Queries
- Indexed lookups for users and venues
- Batch operations for multiple records
- Connection pooling

## Security Architecture

### API Key Management
✓ Environment variables (never in code)
✓ Xcode build settings
✓ Keychain for runtime storage

### Authentication
✓ OAuth 2.0 standard
✓ Token refresh mechanism
✓ Automatic logout on 401

### Encryption
✓ HTTPS/TLS for all network requests
✓ Core Data encryption (optional)
✓ Keychain for sensitive tokens

### Input Validation
✓ Email format validation
✓ Password strength requirements
✓ URL validation for API endpoints

## Scalability

### Current Architecture Supports
- 1000+ venues per query
- Pagination for large feeds
- Connection pooling
- Image caching
- Local database sync

### Future Enhancements
- Offline mode with sync
- Push notifications
- Background location tracking
- Advanced caching strategies
- GraphQL for complex queries

## Monitoring & Analytics

### Error Tracking
- Centralized error logging
- Crash reporting integration points
- User analytics events

### Performance Metrics
- Network request timing
- View rendering performance
- Memory usage tracking

## Deployment Architecture

```
Development → Testing → Staging → Production
   (Local)      (CI)     (Beta)   (App Store)
                  ↓
            GitHub Actions
                  ↓
         SwiftLint, Tests
                  ↓
            Build Artifact
                  ↓
            Code Signing
                  ↓
          TestFlight Build
```
