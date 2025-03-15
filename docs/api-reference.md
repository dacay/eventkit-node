# EventKit Node.js API Reference

This document provides detailed information about the EventKit Node.js addon API.

## EventKit-like API

The EventKit-like API is available through the default export:

```javascript
const eventkit = require('eventkit-node').default;
// or
import eventkit from 'eventkit-node';
```

### `requestFullAccessToEvents()`

Requests full access to calendar events and returns a promise that resolves to a boolean indicating whether access was granted.
Similar to `EKEventStore.requestFullAccessToEvents()` in EventKit.

- On macOS 14.0 and later: Uses the `requestFullAccessToEvents` method from EventKit
- On macOS 10.15 to 13.x: Falls back to the `requestAccess(to: .event)` method

### `requestFullAccessToReminders()`

Requests full access to reminders and returns a promise that resolves to a boolean indicating whether access was granted.
Similar to `EKEventStore.requestFullAccessToReminders()` in EventKit.

- On macOS 14.0 and later: Uses the `requestFullAccessToReminders` method from EventKit
- On macOS 10.15 to 13.x: Falls back to the `requestAccess(to: .reminder)` method

### `getCalendars(entityType?: EntityType)`

Gets all calendars for the specified entity type. If no entity type is provided, defaults to 'event'.
Similar to `EKEventStore.calendars(for:)` in EventKit.

- `entityType`: Optional. The entity type to get calendars for. Can be 'event' or 'reminder'. Defaults to 'event'.
- Returns: An array of Calendar objects.

### `getCalendar(identifier: string)`

Gets a calendar with the specified identifier.
Similar to `EKEventStore.calendar(withIdentifier:)` in EventKit.

- `identifier`: The unique identifier of the calendar to retrieve.
- Returns: The calendar with the specified identifier, or null if not found.

### `saveCalendar(calendarOrData: Calendar | CalendarData, commit?: boolean)`

Saves a calendar (creates a new one or updates an existing one).
Similar to `EKEventStore.saveCalendar(_:commit:)` in EventKit.

- `calendarOrData`: The calendar object or calendar data to save.
  - Use `Calendar` for updating existing calendars
  - Use `CalendarData` for creating new calendars
- `commit`: Optional. Whether to commit the changes immediately. Defaults to true.
- Returns: A promise that resolves to the calendar identifier if successful.

## Simplified API

The simplified API is available through the `simple` export:

```javascript
const { requestCalendarAccess, getCalendars, getReminderLists } = require('eventkit-node').simple;
// or
import { simple } from 'eventkit-node';
const { requestCalendarAccess, getCalendars, getReminderLists } = simple;
```

### `requestCalendarAccess()`

Requests access to calendar events and returns a promise that resolves to a boolean indicating whether access was granted.
This is a simplified version of `requestFullAccessToEvents()`.

### `requestRemindersAccess()`

Requests access to reminders and returns a promise that resolves to a boolean indicating whether access was granted.
This is a simplified version of `requestFullAccessToReminders()`.

### `getCalendars()`

Gets all event calendars.
This is a simplified version of `getCalendars('event')`.

- Returns: An array of Calendar objects representing event calendars.

### `getReminderLists()`

Gets all reminder lists.
This is a simplified version of `getCalendars('reminder')`.

- Returns: An array of Calendar objects representing reminder lists.

### `getCalendar(identifier: string)`

Gets a calendar with the specified identifier.
This is the same as the EventKit-like API's `getCalendar()` method.

- `identifier`: The unique identifier of the calendar to retrieve.
- Returns: The calendar with the specified identifier, or null if not found.

### `createCalendar(calendarData: CalendarData)`

Creates a new calendar.
This is a simplified version of `saveCalendar(calendarData, true)`.

- `calendarData`: The calendar data to create.
- Returns: A promise that resolves to the calendar identifier if successful.

### `updateCalendar(calendar: Calendar)`

Updates an existing calendar.
This is a simplified version of `saveCalendar(calendar, true)`.

- `calendar`: The calendar object to update.
- Returns: A promise that resolves to the calendar identifier if successful.

## Types

### `EntityType`

```typescript
type EntityType = 'event' | 'reminder';
```

### `CalendarType`

```typescript
type CalendarType = 'local' | 'calDAV' | 'exchange' | 'subscription' | 'birthday' | 'unknown';
```

### `ColorSpace`

```typescript
type ColorSpace = 'rgb' | 'monochrome' | 'cmyk' | 'lab' | 'deviceN' | 'indexed' | 'pattern' | 'unknown';
```

### `CalendarColor`

```typescript
interface CalendarColor {
  hex: string;        // Hex color code with alpha (#RRGGBBAA)
  components: string; // Raw color components as comma-separated values
  space: ColorSpace;  // Color space of the original color
}
```

### `Calendar`

```typescript
interface Calendar {
  id: string;                      // Unique identifier for the calendar
  title: string;                   // Display name of the calendar
  allowsContentModifications: boolean; // Whether the calendar allows content modifications
  type: CalendarType;              // Type of the calendar (local, calDAV, etc.)
  color: CalendarColor;            // Color of the calendar
  source: string;                  // Source of the calendar (e.g., iCloud, Google)
}
```

### `ReminderList`

```typescript
type ReminderList = Calendar;
```

### `CalendarData`

```typescript
interface CalendarData {
  id?: string;                // Unique identifier (omit for new calendars)
  title: string;              // Display name of the calendar
  entityType?: EntityType;    // Entity type ('event' or 'reminder')
  sourceId?: string;          // Source identifier (optional)
  color?: {
    hex: string;              // Hex color code (#RRGGBBAA or #RRGGBB)
  };
}
``` 