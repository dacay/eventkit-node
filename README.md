# EventKit Node.js Addon

A Node.js native addon that provides access to macOS EventKit functionality, allowing you to work with calendars and reminders.

## Prerequisites

- macOS 10.15 or later
- Node.js 14 or later
- Xcode 12 or later with Command Line Tools installed

## Installation

```bash
npm install eventkit-node
```

## Quick Start

### JavaScript (CommonJS)

```javascript
// Destructure methods directly from the simple object
const { requestCalendarAccess, getCalendars } = require('eventkit-node').simple;

async function example() {
  // Request calendar access
  const granted = await requestCalendarAccess();
  
  if (granted) {
    // Get event calendars
    const calendars = getCalendars();
    console.log('Calendars:', calendars);
  }
}

example();
```

### TypeScript

```typescript
// Import the module and destructure methods from simple
import { simple, Calendar } from 'eventkit-node';
const { requestCalendarAccess, getCalendars } = simple;

async function example() {
  const granted = await requestCalendarAccess();
  
  if (granted) {
    const calendars: Calendar[] = getCalendars();
    console.log('Calendars:', calendars);
  }
}

example();
```

## Important: Privacy Descriptions Required

When using this library in your application, you **must** include the following privacy descriptions in your application's Info.plist:

```xml
<key>NSCalendarsUsageDescription</key>
<string>Your reason for accessing calendars</string>

<key>NSRemindersUsageDescription</key>
<string>Your reason for accessing reminders</string>
```

Without these descriptions, permission requests will silently fail.

## API Overview

This library offers two API styles:

1. **EventKit-like API**: Closely mirrors the native EventKit API (imported via default export)
2. **Simplified API**: More intuitive function names for common operations (accessed via destructuring from the `simple` object)

### Core Functions

| EventKit-like API | Simplified API | Description |
|-------------------|----------------|-------------|
| `requestFullAccessToEvents()` | `requestCalendarAccess()` | Request access to calendar events |
| `requestFullAccessToReminders()` | `requestRemindersAccess()` | Request access to reminders |
| `getCalendars('event')` | `getCalendars()` | Get event calendars |
| `getCalendars('reminder')` | `getReminderLists()` | Get reminder lists |

## Documentation

For more detailed information, please refer to the following documentation:

- [API Reference](docs/api-reference.md) - Detailed information about all functions and types
- [Usage Examples](docs/examples.md) - Comprehensive examples for both JavaScript and TypeScript
- [Troubleshooting Guide](docs/troubleshooting.md) - Solutions for common issues

## Building from Source

```bash
# Install dependencies
npm install

# Build the addon
npm run build

# Build TypeScript definitions (if using TypeScript)
npm run build:ts
```

## License

MIT