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

```javascript
const { 
  requestFullAccessToEvents, 
  getCalendars, 
  saveCalendar, 
  commit, 
  reset, 
  refreshSourcesIfNecessary,
  createEventPredicate,
  getEventsWithPredicate
} = require('eventkit-node');

async function example() {
  // Request calendar access
  const granted = await requestFullAccessToEvents();
  
  if (granted) {
    // Get calendars that support events
    const eventCalendars = getCalendars('event');
    console.log('Event Calendars:', eventCalendars);
    
    // Get calendars that support reminders
    const reminderCalendars = getCalendars('reminder');
    console.log('Reminder Calendars:', reminderCalendars);
    
    // Create a new calendar for events
    try {
      const newCalendarId = await saveCalendar({
        title: 'My New Calendar',
        entityType: 'event',
        color: { hex: '#FF0000FF' }
      });
      console.log('Created new calendar with ID:', newCalendarId);
      
      // Update the calendar we just created
      const updatedCalendarId = await saveCalendar({
        id: newCalendarId,
        title: 'My Updated Calendar',
        entityType: 'event',
        color: { hex: '#00FF00FF' }
      });
      
      // Create a calendar without committing changes immediately
      const draftCalendarId = await saveCalendar({
        title: 'Draft Calendar',
        entityType: 'event',
        color: { hex: '#0000FFFF' }
      }, false);
      console.log('Created draft calendar with ID:', draftCalendarId);
      
      // Commit the changes manually
      try {
        await commit();
        console.log('Changes committed successfully');
      } catch (error) {
        console.error('Failed to commit changes:', error);
        // Reset the event store to discard unsaved changes
        reset();
      }
      
      // Refresh sources if necessary (e.g., after external changes)
      refreshSourcesIfNecessary();
      
      // Query events using predicates
      const startDate = new Date();
      const endDate = new Date();
      endDate.setDate(endDate.getDate() + 7); // One week from now
      
      // Create a predicate for events in the next week
      const eventPredicate = createEventPredicate(startDate, endDate);
      
      // Get events matching the predicate
      const events = getEventsWithPredicate(eventPredicate);
      console.log('Events in the next week:', events);
      
    } catch (error) {
      console.error('Failed to save calendar:', error);
    }
  }
}

example();
```

## Querying Events and Reminders

EventKit Node.js provides a two-step approach for querying events and reminders, following the EventKit API design:

1. Create a predicate using one of the predicate creation methods
2. Query events or reminders using the predicate

```javascript
const { 
  createEventPredicate, 
  createReminderPredicate,
  createIncompleteReminderPredicate,
  createCompletedReminderPredicate,
  getEventsWithPredicate,
  getRemindersWithPredicate
} = require('eventkit-node');

async function queryExample() {
  // Query events for the next week
  const startDate = new Date();
  const endDate = new Date();
  endDate.setDate(endDate.getDate() + 7);
  
  // Step 1: Create a predicate
  const eventPredicate = createEventPredicate(startDate, endDate);
  
  // Step 2: Query events using the predicate
  const events = getEventsWithPredicate(eventPredicate);
  console.log('Events:', events);
  
  // Query all reminders in specific calendars
  const calendarIds = ['calendar-id-1', 'calendar-id-2'];
  const reminderPredicate = createReminderPredicate(calendarIds);
  
  // Reminder queries are asynchronous
  const reminders = await getRemindersWithPredicate(reminderPredicate);
  console.log('Reminders:', reminders);
  
  // Query incomplete reminders with due dates in the next week
  const incompletePredicate = createIncompleteReminderPredicate(startDate, endDate);
  const incompleteReminders = await getRemindersWithPredicate(incompletePredicate);
  console.log('Incomplete reminders:', incompleteReminders);
  
  // Query completed reminders from the last week
  const lastWeekStart = new Date();
  lastWeekStart.setDate(lastWeekStart.getDate() - 7);
  const completedPredicate = createCompletedReminderPredicate(lastWeekStart, new Date());
  const completedReminders = await getRemindersWithPredicate(completedPredicate);
  console.log('Completed reminders:', completedReminders);
}

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

## Documentation

For more detailed information, please refer to the following documentation:

- [API Reference](docs/api-reference.md) - Detailed information about all functions and types
- [Troubleshooting Guide](docs/troubleshooting.md) - Solutions for common issues

The API Reference includes detailed type definitions and usage information for all functions. Examples of using the library can be found in the Quick Start section above and within the API Reference.

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