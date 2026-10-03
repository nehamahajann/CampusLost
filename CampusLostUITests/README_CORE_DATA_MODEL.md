# Core Data Model — CampusLost.xcdatamodeld

This can't be zipped as a plain file since it lives inside Xcode's visual
editor. If your model gets into a broken state, here's exactly what it
should contain so you can rebuild it from scratch:

## Entity: LostReport
Attributes (all Codegen: Class Definition):
- id — UUID
- itemName — String
- category — String
- itemDescription — String
- location — String
- date — Date
- status — String
- createdAt — Date

Relationship:
- matchRecord — Destination: MatchRecord — Type: To One — Inverse: lostReport

## Entity: FoundReport
Attributes: same list as LostReport (id, itemName, category, itemDescription,
location, date, status, createdAt)

Relationship:
- matchRecord — Destination: MatchRecord — Type: To One — Inverse: foundReport

## Entity: MatchRecord
Attributes:
- id — UUID
- matchDate — Date
- status — String

Relationships:
- lostReport — Destination: LostReport — Type: To One — Inverse: matchRecord
- foundReport — Destination: FoundReport — Type: To One — Inverse: matchRecord

## Project build setting required
Build Settings → search "Actor Isolation" → Default Actor Isolation → set to
"Nonisolated" (Xcode 16 defaults this to MainActor, which breaks Core Data's
generated classes otherwise).
