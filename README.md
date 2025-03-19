# EventKit Node.js Addon

A Node.js native addon that provides access to macOS [EventKit](https://developer.apple.com/documentation/eventkit) functionality, allowing you to work with calendars and reminders.

This library is a bridge between Node.js and Apple's EventKit framework, providing a JavaScript-friendly API for managing calendars, events, and reminders on macOS.

## Prerequisites

- macOS 10.15 or later
- Node.js 14 or later
- Xcode 12 or later with Command Line Tools installed

## Installation

```bash
npm install eventkit-node
```

## Quick Example

```javascript
const { requestFullAccessToEvents, getCalendars } = require('eventkit-node');

async function main() {
  // Request access to calendars
  const granted = await requestFullAccessToEvents();
  
  if (granted) {
    // Get all event calendars
    const calendars = getCalendars('event');
    console.log('Available calendars:', calendars.map(c => c.title));
  } else {
    console.log('Calendar access was denied');
  }
}

main();
```

For more detailed examples, please see the [Examples documentation](docs/examples.md).

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

The addon provides a clean, JavaScript-friendly API for working with calendars and reminders.

### Calendar Management

- `requestFullAccessToEvents()` - Request full access to the user's calendars
- `requestFullAccessToReminders()` - Request full access to the user's reminders
- `requestWriteOnlyAccessToEvents()` - Request write-only access to the user's calendars
- `getCalendars(entityType)` - Get calendars for a specific entity type (event or reminder)
- `getCalendar(identifier)` - Get a calendar by its identifier
- `saveCalendar(calendarData, commit)` - Create or update a calendar, with optional commit parameter
- `removeCalendar(identifier, commit)` - Remove a calendar by its identifier
- `getDefaultCalendarForNewEvents()` - Get the default calendar for new events
- `getDefaultCalendarForNewReminders()` - Get the default calendar for new reminders

### Event and Reminder Management

- `saveEvent(eventData, span, commit)` - Create or update an event, with optional span and commit parameters
- `saveReminder(reminderData, commit)` - Create or update a reminder, with optional commit parameter
- `removeEvent(identifier, span, commit)` - Remove an event by its identifier, with optional span and commit parameters
- `removeReminder(identifier, commit)` - Remove a reminder by its identifier, with optional commit parameter

### Event Store Operations

- `commit()` - Commit all pending changes to the event store
- `reset()` - Reset the event store by discarding all unsaved changes
- `refreshSourcesIfNecessary()` - Refresh the sources in the event store if necessary

### Source Management

- `getSources()` - Get all available calendar sources
- `getDelegateSources()` - Get all delegate sources (macOS 12.0+)
- `getSource(sourceId)` - Get a specific source by ID

### Event and Reminder Queries

- `createEventPredicate(startDate, endDate, calendarIds?)` - Create a predicate for querying events
- `createReminderPredicate(calendarIds?)` - Create a predicate for querying all reminders
- `createIncompleteReminderPredicate(startDate?, endDate?, calendarIds?)` - Create a predicate for querying incomplete reminders
- `createCompletedReminderPredicate(startDate?, endDate?, calendarIds?)` - Create a predicate for querying completed reminders
- `getEventsWithPredicate(predicate)` - Get events matching a predicate
- `getRemindersWithPredicate(predicate)` - Get reminders matching a predicate (returns a Promise)
- `getEvent(identifier)` - Get an event by its unique identifier
- `getCalendarItem(identifier)` - Get a calendar item (event or reminder) by its identifier
- `getCalendarItemsWithExternalIdentifier(externalIdentifier)` - Get calendar items with a specific external identifier

## Documentation

For more detailed information, please refer to the following documentation:

- [API Reference](docs/api-reference.md) - Detailed information about all functions and types
- [Examples](docs/examples.md) - Practical usage examples
- [Troubleshooting Guide](docs/troubleshooting.md) - Solutions for common issues

## Apple EventKit Documentation

This library is based on Apple's EventKit framework. For more information about the underlying APIs and concepts, please refer to:

- [EventKit Framework Documentation](https://developer.apple.com/documentation/eventkit)
- [Calendar and Reminders Programming Guide](https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/EventKitProgGuide/Introduction/Introduction.html)

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

[Mozilla Public License Version 2.0 (MPL-2.0)](LICENSE) 