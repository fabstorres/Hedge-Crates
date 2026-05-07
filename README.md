# Hedge Crates

An iOS app that helps options traders validate and analyze their trades using AI-powered screenshot analysis.

## Overview

Hedge Crates allows traders to upload screenshots of their trades and receive instant, structured analysis including risk assessment, position direction, time horizon, and key observations — all powered by OpenAI's vision models.

## Features

- **AI Trade Analysis** — Upload up to 5 screenshots and get structured feedback on you`r options trades
- **Risk Assessment** — Categorized as Low, Medium, or High risk with visual indicators
- **Position Evaluation** — Bullish, Bearish, or Neutral stance detection
- **Trade Quality Score** — Good, Neutral, or Bad trade assessment
- **Key Observations** — Automated extraction of trade type, PnL, risk/reward ratio, win conditions, and potential mistakes
- **Persistent History** — All analyses are saved and accessible via the History tab
- **Anonymous Guest Access** — No signup required; secure anonymous sessions via Convex guest auth
- **Dark-First UI** — Purpose-built dark interface tailored for trading workflows

## Tech Stack

### iOS Client

- **SwiftUI** — Declarative UI with custom dark theme
- **ConvexMobile** — Real-time backend sync and actions
- **PhotosUI** — Native photo picker for screenshot selection
- **Keychain Services** — Secure guest token persistence

### Backend (Convex)

- **Convex** — Serverless backend platform
- **OpenAI GPT** — Vision model for image analysis (`gpt-5.5`)
- **Vercel AI SDK** — Structured output generation with Zod schemas
- **HMAC-SHA256** — Guest token signing and verification

## Project Structure

```
Hedge Crates/
├── Hedge Crates/
│   ├── Hedge_CratesApp.swift       # App entry, Convex client setup
│   ├── ContentView.swift           # Root view with TabView (Analyzer + History)
│   ├── Route.swift                 # Navigation routing enum
│   ├── Models/
│   │   └── Crate.swift             # Trade analysis data model
│   ├── Services/
│   │   ├── CrateService.swift      # Image upload & analysis API
│   │   ├── GuestAuthManager.swift  # Anonymous auth orchestration
│   │   └── KeychainHelper.swift    # Secure token storage
│   ├── ViewModels/
│   │   └── HistoryViewModel.swift  # History list data fetching
│   └── Views/
│       ├── UploadView.swift        # Screenshot upload screen
│       ├── PhotoPicker.swift       # PhotosUI wrapper
│       ├── AnalysisResultView.swift # Analysis display with risk cards
│       ├── AnalysisErrorView.swift # Error state UI
│       └── HistoryView.swift       # Past analyses list
├── convex/
│   ├── schema.ts                   # Database schema (guests, crates)
│   ├── crates.ts                   # Trade analysis action & AI integration
│   ├── guests.ts                   # Guest auth (HMAC token signing)
│   └── http.ts                     # HTTP router for image uploads
├── Hedge Crates.xcodeproj/         # Xcode project
└── package.json                    # Convex dependencies
```

## Architecture

### Guest Authentication Flow

1. App launches → checks Keychain for existing guest token
2. If none exists → calls `guests:createGuest` Convex action
3. Convex creates a guest record and returns a signed HMAC token
4. Token is stored in iOS Keychain for future sessions
5. All subsequent requests include the token via `Authorization: Bearer` header

### Trade Analysis Flow

1. User selects up to 5 screenshots via `PHPickerViewController`
2. Images are JPEG-encoded and sent as multipart/form-data to `/api/analyzeImages`
3. Convex HTTP action verifies the guest token
4. Images are forwarded to OpenAI GPT with a specialized options trading system prompt
5. AI returns structured output (position, risk, sprint, stance, observations)
6. Result is saved to the `crates` table and returned to the client

### Data Model

**Crate (Trade Analysis)**
| Field | Type | Description |
|-------------|----------|--------------------------------------|
| `_id` | string | Unique identifier |
| `position` | string | bullish / bearish / neutral |
| `risk` | string | low / medium / high |
| `sprint` | string | short / long term horizon |
| `stance` | string | good / neutral / bad trade quality |
| `observations` | string[] | Key insights extracted from images |
| `guestId` | string | Reference to anonymous guest |

## Setup & Installation

### Prerequisites

- Xcode 15+
- iOS 17+ target device or simulator
- Convex project deployed
- OpenAI API key

### iOS Setup

1. Open `Hedge Crates.xcodeproj` in Xcode
2. Add the `ConvexMobile` Swift package dependency
3. Update `Hedge_CratesApp.swift` with your Convex deployment URL:
   ```swift
   let convex = ConvexClient(deploymentUrl: "https://<your-project>.convex.cloud")
   let crateService = CrateService(deploymentUrl: "https://<your-project>.convex.site")
   ```
4. Build and run on an iOS device or simulator

### Convex Backend Setup

1. Install dependencies:
   ```bash
   npm install
   ```
2. Set up environment variables in your Convex dashboard:
   ```
   OPENAI_API_KEY=sk-...
   GUEST_TOKEN_SECRET=<a-random-secret-for-hmac-signing>
   ```
3. Deploy Convex functions:
   ```bash
   npx convex dev
   ```

## Dependencies

### Node.js / Convex

- `convex` — Backend framework
- `ai` — Vercel AI SDK
- `@ai-sdk/openai` — OpenAI provider
- `zod` — Schema validation

### Swift

- `ConvexMobile` — Convex iOS client

## Environment Variables

| Variable             | Required | Description                             |
| -------------------- | -------- | --------------------------------------- |
| `OPENAI_API_KEY`     | Yes      | OpenAI API key for GPT vision analysis  |
| `GUEST_TOKEN_SECRET` | Yes      | Secret key for HMAC guest token signing |

## Design Notes

- **Color Palette**: Pure black backgrounds (`#000000`) with subtle white overlays for card surfaces
- **Typography**: System fonts with bold weights for hierarchy
- **Risk Visualization**: Color-coded indicators (Green = Low/Good, Orange = Medium, Red = High/Bad)
- **Navigation**: Tab-based with `NavigationStack` for detail flows

## License

ISC
