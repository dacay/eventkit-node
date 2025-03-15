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

### `getCalendars(entityType?: 'event' | 'reminder')`

Gets a list of calendars for the specified entity type, similar to `EKEventStore.calendars(for:)` in EventKit.

- `entityType`: Optional. The type of entity to get calendars for. Can be either 'event' (default) or 'reminder'.

Returns an array of `Calendar` objects.

### `getCalendar(identifier: string)`

Gets a calendar with the specified identifier, similar to `EKEventStore.calendar(withIdentifier:)` in EventKit.

- `identifier`: The unique identifier of the calendar to retrieve.

Returns a `Calendar` object if found, or `null` if no calendar with the specified identifier exists.

## Simplified API

The simplified API is available by destructuring methods from the `simple` object:

```javascript
// JavaScript
const { requestCalendarAccess, getCalendars, getReminderLists, requestRemindersAccess, getCalendar } = require('eventkit-node').simple;

// TypeScript
import { simple } from 'eventkit-node';
const { requestCalendarAccess, getCalendars, getReminderLists, requestRemindersAccess, getCalendar } = simple;
```

### `getCalendars()`

Gets a list of event calendars.

Returns an array of `Calendar` objects representing event calendars.

### `getReminderLists()`

Gets a list of reminder lists.

Returns an array of `ReminderList` objects representing reminder lists.

### `getCalendar(identifier: string)`

Gets a calendar with the specified identifier.

- `identifier`: The unique identifier of the calendar to retrieve.

Returns a `Calendar` object if found, or `null` if no calendar with the specified identifier exists.

### `requestCalendarAccess()`

Requests access to calendar events using a more intuitive function name.
Internally calls `requestFullAccessToEvents()`.

Returns a promise that resolves to true if access was granted, false otherwise.

### `requestRemindersAccess()`

Requests access to reminders using a more intuitive function name.
Internally calls `requestFullAccessToReminders()`.

Returns a promise that resolves to true if access was granted, false otherwise.

## Types

These types are available as named exports:

```typescript
import { Calendar, ReminderList, EntityType, CalendarType, ColorSpace } from 'eventkit-node';
```

### `Calendar`

Represents an EKCalendar with the following properties:

- `id`: Unique identifier for the calendar
- `title`: Display name of the calendar
- `allowsContentModifications`: Whether the calendar allows content modifications
- `type`: Type of the calendar ('local', 'calDAV', 'exchange', 'subscription', 'birthday', or 'unknown')
- `color`: Color information with multiple representations:
  - `hex`: Hex color code with alpha (#RRGGBBAA)
  - `components`: Raw color components as comma-separated values
  - `space`: Color space of the original color
- `source`: Source of the calendar (e.g., iCloud, Google)

### `ReminderList`

Type alias for `Calendar` representing a calendar that contains reminders.

### `EntityType`

Union type of 'event' | 'reminder' representing the type of entity.

### `CalendarType`

Union type representing the type of calendar: 'local' | 'calDAV' | 'exchange', 'subscription', 'birthday', or 'unknown'.

### `ColorSpace`

Union type representing the color space: 'rgb' | 'monochrome' | 'cmyk' | 'lab' | 'deviceN' | 'indexed' | 'pattern' | 'unknown'. 