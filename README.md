# CommuteAssistant

An intelligent MBTA commute companion for iOS. CommuteAssistant tracks your daily transit routes, alerts you to disruptions before you leave home, and suggests when to head out based on real-time data and historical reliability patterns.

## What It Does

- **Live departure predictions** pulled from the MBTA v3 API, grouped by line so multi-line commutes (e.g. Red + Green) are easy to read
- **Disruption detection** that merges service alerts with trip-level cancellations and delays into a single, prioritized feed
- **"Leave by" recommendations** padded with the p90 delay for your specific route, so you plan around worst-case delays rather than just live data
- **Reliability scoring** that tracks on-time percentage, median delay, and p90 delay over a rolling 14-day window across all lines in your route
- **Alternative route suggestions** when your usual line is disrupted
- **Alerts grouped by transit type** (Subway, Light Rail, Commuter Rail, Bus, Ferry) with collapsible sections and filter chips
- **Live Activities and Dynamic Island** showing your next departure, disruption status, and "leave by" time
- **Home and Lock Screen widgets** with countdown to your next train
- **Background refresh** that checks for disruptions during your commute window and pushes time-sensitive notifications
- **Siri Shortcuts** for quick access ("When is my next train?")

## Requirements

- **Xcode 16.0+**
- **iOS 17.0+** (uses SwiftData, Observation framework, ActivityKit, interactive widgets)
- **Swift 5.10**
- **MBTA API key** (free, from [api-v3.mbta.com](https://api-v3.mbta.com))
- **Apple Developer account** (free tier works for simulator; paid required for device testing with push notifications and Live Activities)

No third-party dependencies. All network calls use `URLSession` with `async/await`.

## Getting Started

### 1. Clone the repo

```bash
git clone <your-repo-url>
cd MyMBTA
```

### 2. Add your API key

Create `CommuteKit/Secrets.swift` (gitignored) with your key:

```swift
public enum Secrets {
    public static let mbtaAPIKey: String = "your-actual-api-key"
}
```

You can get a free key at [api-v3.mbta.com](https://api-v3.mbta.com). The key raises your rate limit from 20 to 1000 requests per minute.

### 3. Open in Xcode

```bash
open CommuteAssistant.xcodeproj
```

### 4. Set your signing team

In Xcode, select the project in the navigator, then for each target go to **Signing & Capabilities** and pick your development team:

- CommuteAssistant
- CommuteKit
- CommuteWidgets
- CommuteIntents

### 5. Build and run

Select an iPhone simulator (iOS 17+) and press `Cmd+R`.

## Project Structure

```
MyMBTA/
├── CommuteKit/                 # Shared framework (no UI code)
│   ├── Models/                 # SavedRoute, Prediction, Disruption, ServiceAlert, etc.
│   ├── Networking/             # MBTAClient (REST + JSON:API), RateLimiter
│   ├── Services/               # DisruptionEngine, ReliabilityScorer, NotificationService
│   ├── Intelligence/           # CommuteWindowResolver, AlternativeRouteSuggester
│   ├── Persistence/            # SwiftData container
│   ├── Utilities/              # Cache, Clock, Logger
│   └── Secrets.swift           # API key (gitignored)
│
├── CommuteAssistant/           # Main iOS app
│   ├── App/                    # Entry point, AppDependencies (composition root), RootView
│   ├── Features/
│   │   ├── Today/              # Dashboard: departures grouped by line, disruptions, "leave by"
│   │   ├── Routes/             # Create/edit routes with API-driven stop picker
│   │   ├── Alerts/             # Alert feed grouped by transit type with filter chips
│   │   ├── Onboarding/         # Permissions flow (notifications, location)
│   │   └── Settings/           # Quiet hours, notification preferences
│   └── DesignSystem/           # Theme colors, typography, Card, SeverityBadge, StatusDot
│
├── CommuteWidgets/             # Widget extension
│   ├── NextDepartureWidget     # Home/Lock screen countdown widget
│   └── CommuteLiveActivity     # Live Activity + Dynamic Island
│
├── CommuteIntents/             # App Intents extension (ExtensionKit)
│   ├── ViewNextDepartureIntent # Siri: "Show my next departure"
│   └── RefreshCommuteIntent    # Interactive widget refresh
│
└── CommuteKitTests/            # Unit tests
    ├── RouteMatcherTests
    ├── DisruptionEngineTests
    ├── ReliabilityScorerTests
    └── CommuteWindowResolverTests
```

## Architecture

The app follows **MVVM** with constructor-injected dependencies:

```
View -> @Observable ViewModel -> Service -> MBTAClient
```

- **Views** are pure SwiftUI. No business logic.
- **ViewModels** are `@MainActor @Observable` classes that hold UI state and call services.
- **Services** contain business logic (merging disruptions, scoring reliability, resolving commute windows). They live in CommuteKit and have no UI imports.
- **MBTAClient** handles all networking. Rate-limited with a token-bucket algorithm (1000 req/min with key, 20 without).

All dependencies are created in `AppDependencies` (the composition root) and passed through the SwiftUI environment.

## How It Works

### Route Setup

Users create commute routes by selecting origin and destination stops (fetched from the API, searchable by name), choosing which transit lines the commute uses, and setting a departure window. Day selection supports presets (Weekdays, Weekends, Every Day) or any custom combination.

### Today View

The dashboard shows:
1. **Active route** with line badges
2. **Disruption banners** for anything affecting your route
3. **"Leave by" time** padded with the p90 delay from your reliability history
4. **Next departures** grouped by line, so multi-line commutes show each line's trains separately
5. **Reliability chip** showing on-time % (uses worst-case across all lines in your route)

### Alerts Feed

Service alerts are grouped into sections by transit type: Subway, Light Rail, Commuter Rail, Bus, and Ferry. Each section is collapsible and shows an alert count badge. Two levels of filtering are available: transit type chips at the top, and individual line filters below.

### Reliability Scoring

Unlike apps that only show live data, CommuteAssistant computes a rolling reliability score per route:

- **On-time percentage**: trips arriving within 3 minutes of schedule
- **p50 delay**: the typical delay you will experience
- **p90 delay**: the worst-case delay used to pad "leave by" recommendations

For multi-line routes, the app scores each line independently and uses the worst case, so if the Red Line is reliable but the Green Line is not, your "leave by" time reflects the weaker link.

### Disruption Engine

The `DisruptionEngine` merges three data sources into a unified disruption model:
1. Service alerts from the MBTA alert feed
2. Trip-level cancellations from prediction data
3. Computed delay patterns (multiple trips with 10+ minute delays)

Each disruption gets a normalized severity so the UI and notification system can prioritize consistently.

### Background Intelligence

The app uses `BGTaskScheduler` to check for disruptions before your commute window opens. If something significant is detected, it sends a time-sensitive push notification, starts or updates a Live Activity, and reloads widget timelines.

## Data Source

| Source | URL | What It Provides |
|--------|-----|-----------------|
| MBTA v3 REST API | `api-v3.mbta.com` | Predictions, alerts, schedules, stops, routes (JSON:API format) |

The API key is sent as `x-api-key` on every request.

## Testing

```bash
# In Xcode: Cmd+U
# Or from terminal:
xcodebuild test -scheme CommuteAssistant -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Tests cover:
- **RouteMatcher**: disruptions correctly matched to user routes by line and stop
- **DisruptionEngine**: merging alerts and predictions, severity mapping, deduplication
- **ReliabilityScorer**: on-time percentage calculation, percentile computation, edge cases
- **CommuteWindowResolver**: "leave by" calculation with and without reliability padding

## Future Work

- **GTFS-RT protobuf decoding**: Full protobuf parsing for real-time trip updates and vehicle positions
- **Remote push fallback**: A lightweight server polling MBTA and fanning out APNs pushes for sub-minute latency
- **Geofence-based activity ending**: Automatically dismiss the Live Activity on arrival at the destination stop
- **Historical data persistence**: Store prediction snapshots to build more accurate reliability scores over time
- **Accessibility audit**: VoiceOver optimization, Dynamic Type support across all views

## License

This project is for portfolio and educational purposes.
