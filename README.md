# CampusLost

A lost & found iOS app for university students — report what you've lost, report what you've found, and let the app automatically match them.

## Overview

CampusLost solves a real, everyday campus problem: when someone loses an item, there's no structured way to find out if it's been handed in — people currently post in random group chats and hope for the best. CampusLost replaces that with one shared, searchable system where lost and found reports are automatically compared and matched.

## Domain Context

**Primary stakeholder:** A student who has lost a personal item on campus and wants to know if it's been found.

The app follows that student's real workflow: report what's missing → the system checks for a match automatically → get notified the moment one is found → confirm it's genuinely theirs.

## Features

- **Report Lost / Report Found** — structured forms capturing item, category, location, and date
- **Automatic matching** — `MatchLostAndFoundItemUseCase` compares category, location, date window, and text similarity between item names/descriptions, scoring each potential match with a confidence percentage
- **Browse Found Items** — a searchable list for students who'd rather look themselves than wait on a match
- **My Reports** — track the status of everything you've submitted
- **Match Review** — confirm or reject a suggested match

## Architecture

SwiftUI Views
↓
Use Case Layer ← business rules enforced here
↓
Repository (protocol) → Core Data (real) / Mock (tests)
↓
Persistence (Core Data, shared App Group container)


**Use Cases:**
- `ReportLostItemUseCase` — rejects empty names, future dates, and descriptions under 10 characters
- `ReportFoundItemUseCase` — rejects empty names, future dates, and missing locations
- `MatchLostAndFoundItemUseCase` — finds the best-matching found report by category, location, date window, and text similarity; scores confidence 0–100

## System Extensions

**1. Widget Extension** — shows the status of a student's most recent lost report directly on the Home Screen/Lock Screen ("AirPods — No match yet" / "Match found!"), so they don't need to open the app just to check. Supports both `.systemSmall` and `.systemMedium` families. Reads from the same Core Data store via the shared App Group container, and the main app calls `WidgetCenter.shared.reloadAllTimelines()` after every report submission and match status change.

**2. Notification Content Extension** — replaces the default notification banner with a custom rich view when a potential match is found, showing the matched item and location inline instead of a generic text alert.

## Database

**Core Data**, chosen because report data needs to be fast and reliable for a single student's device — there's no requirement for this data to sync across multiple devices or be shared between different users' accounts in this version of the app. The database lives in a shared App Group container (not the app's private sandbox) specifically so the Widget Extension can read the same data the main app writes.

**Entities:** `LostReport`, `FoundReport`, `MatchRecord` (each `LostReport`/`FoundReport` relates to at most one `MatchRecord`).

**App Group identifier:** `group.Neha.CampusLost`

## Setup Instructions

1. Clone this repository and open `CampusLost.xcodeproj` in Xcode.
2. Select an iOS Simulator (iPhone 17 or later recommended) from the scheme toolbar.
3. Build and run with `Cmd+R`.
4. Allow notification permissions when prompted, to see the match notification feature.

## Running Tests

`Cmd+U` runs the full suite — all tests use `MockLostFoundRepository`, not the real Core Data stack.
