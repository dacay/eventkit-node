# EventKit Node.js API Reference

This document provides detailed information about the EventKit Node.js addon API.

## Main API

The API is available through direct imports:

```javascript
const { getCalendars, saveCalendar, requestFullAccessToEvents, requestFullAccessToReminders } = require('eventkit-node');
// or
import { getCalendars, saveCalendar, requestFullAccessToEvents, requestFullAccessToReminders } from 'eventkit-node';
```

### `getCalendars(entityType?: 'event' | 'reminder')`

Gets calendars for a specific entity type.

- `entityType`: Optional. The entity type to get calendars for. Defaults to 'event'.
- Returns: An array of Calendar objects.

### `getCalendar(identifier: string)`

Gets a calendar with the specified identifier.

- `identifier`: The unique identifier of the calendar to retrieve.
- Returns: The calendar with the specified identifier, or null if not found.

### `requestFullAccessToEvents()`

Requests full access to calendar events and returns a promise that resolves to a boolean indicating whether access was granted.

- Returns: A promise that resolves to true if access was granted, false otherwise.
- On macOS 14.0 and later: Uses the `requestFullAccessToEvents` method from EventKit
- On macOS 10.15 to 13.x: Falls back to the `requestAccess(to: .event)` method

### `requestFullAccessToReminders()`

Requests full access to reminders and returns a promise that resolves to a boolean indicating whether access was granted.

- Returns: A promise that resolves to true if access was granted, false otherwise.
- On macOS 14.0 and later: Uses the `requestFullAccessToReminders` method from EventKit
- On macOS 10.15 to 13.x: Falls back to the `requestAccess(to: .reminder)` method

### `saveCalendar(calendarData: CalendarData, commit?: boolean)`

Creates a new calendar or updates an existing one.

- `calendarData`: The calendar data to save.
  - For new calendars, omit the `id` property.
  - For existing calendars, include the `id` property.
  - Always specify the `entityType` ('event' or 'reminder').
- `commit`: Whether to commit the changes immediately (default: `true`). When set to `false`, changes are not saved to the database until a separate commit operation is performed.
- Returns: A promise that resolves to the calendar identifier if successful.
- Throws: Error if the calendar data is invalid or the operation fails.

**Examples:**

```javascript
// Create a new calendar
const newCalendarId = await saveCalendar({
  title: 'My Calendar',
  entityType: 'event',
  color: { hex: '#FF0000FF' }
});

// Update an existing calendar
const calendar = getCalendar('calendar-id');
if (calendar) {
  const updatedCalendarId = await saveCalendar({
    id: calendar.id,
    title: 'Updated Title',
    entityType: 'event',
    color: { hex: calendar.color.hex }
  });
}

// Create a calendar without committing changes immediately
const newCalendarId = await saveCalendar({
  title: 'My Calendar',
  entityType: 'event',
  color: { hex: '#FF0000FF' }
}, false);
```

### `getSources()`

Gets all available calendar sources.

- Returns: An array of Source objects.

### `getDelegateSources()`

Gets all delegate sources.
Note: This method is only available on macOS 12.0 and later. On older versions, it returns an empty array.

- Returns: An array of Source objects.

### `getSource(sourceId: string)`

Gets a source with the specified identifier.

- `sourceId`: The unique identifier of the source to retrieve.
- Returns: The source with the specified identifier, or null if not found.

## Types

### `EntityType`

```typescript
type EntityType = 'event' | 'reminder';
```

### `CalendarType`

```typescript
type CalendarType = 'local' | 'calDAV' | 'exchange' | 'subscription' | 'birthday' | 'unknown';
```

### `SourceType`

```typescript
type SourceType = 'local' | 'exchange' | 'calDAV' | 'mobileme' | 'subscribed' | 'birthdays' | 'unknown';
```

### `ColorSpace`

```typescript
type ColorSpace = 'rgb' | 'monochrome' | 'cmyk' | 'lab' | 'deviceN' | 'indexed' | 'pattern' | 'unknown';
```

### `