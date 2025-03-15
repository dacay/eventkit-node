# EventKit Node.js API Reference

This document provides detailed information about the EventKit Node.js addon API.

## Main API

The API is available through direct imports:

```javascript
const { 
  getCalendars, 
  saveCalendar, 
  requestFullAccessToEvents, 
  requestFullAccessToReminders, 
  requestWriteOnlyAccessToEvents, 
  commit, 
  reset, 
  refreshSourcesIfNecessary,
  createEventPredicate,
  createReminderPredicate,
  createIncompleteReminderPredicate,
  createCompletedReminderPredicate,
  getEventsWithPredicate,
  getRemindersWithPredicate
} = require('eventkit-node');
// or
import { 
  getCalendars, 
  saveCalendar, 
  requestFullAccessToEvents, 
  requestFullAccessToReminders, 
  requestWriteOnlyAccessToEvents, 
  commit, 
  reset, 
  refreshSourcesIfNecessary,
  createEventPredicate,
  createReminderPredicate,
  createIncompleteReminderPredicate,
  createCompletedReminderPredicate,
  getEventsWithPredicate,
  getRemindersWithPredicate
} from 'eventkit-node';
```

## Calendar Management

### `getCalendars(entityType?: 'event' | 'reminder')`

Gets calendars for a specific entity type.

- `entityType`: Optional. The entity type to get calendars for. Defaults to 'event'.
- Returns: An array of Calendar objects.

### `getCalendar(identifier: string)`

Gets a calendar with the specified identifier.

- `identifier`: The unique identifier of the calendar to retrieve.
- Returns: The calendar with the specified identifier, or null if not found.

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

### `removeCalendar(identifier: string, commit?: boolean)`

Removes a calendar with the specified identifier.

- `identifier`: The unique identifier of the calendar to remove.
- `commit`: Whether to commit the changes immediately (default: `true`). When set to `false`, changes are not saved to the database until a separate commit operation is performed.
- Returns: A promise that resolves to true if successful.
- Throws: Error if the calendar cannot be found or the operation fails.

### `getDefaultCalendarForNewEvents()`

Gets the default calendar for new events.

- Returns: The default calendar for new events, or null if not set.

### `getDefaultCalendarForNewReminders()`

Gets the default calendar for new reminders.

- Returns: The default calendar for new reminders, or null if not set.

## Access Requests

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

### `requestWriteOnlyAccessToEvents()`

Requests write-only access to calendar events and returns a promise that resolves to a boolean indicating whether access was granted.

- Returns: A promise that resolves to true if access was granted, false otherwise.
- On macOS 14.0 and later: Uses the `requestWriteOnlyAccessToEvents` method from EventKit
- On macOS 10.15 to 13.x: Falls back to the `requestAccess(to: .event)` method
- Note: Write-only access allows creating and modifying events but not reading them

## Event Store Operations

### `commit()`

Commits all pending changes to the event store.

- Returns: A promise that resolves when the commit is successful
- Throws: Error if the commit fails with details about the failure
- Note: This is only needed if you've created or modified calendars with commit=false

### `reset()`

Resets the event store by discarding all unsaved changes.

- Returns: void

### `refreshSourcesIfNecessary()`

Refreshes the sources in the event store if necessary.

- Returns: void
- Note: This can be useful if external changes have been made to the calendar database

## Source Management

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

## Event and Reminder Queries

### `createEventPredicate(startDate: Date, endDate: Date, calendarIds?: string[])`

Creates a predicate for querying events within a specific date range and optionally filtered by calendars.

- `startDate`: The start date of the range.
- `endDate`: The end date of the range.
- `calendarIds`: Optional array of calendar IDs to filter by.
- Returns: A Predicate object that can be used with `getEventsWithPredicate`.

**Example:**

```javascript
// Create a predicate for events in the next week
const startDate = new Date();
const endDate = new Date();
endDate.setDate(endDate.getDate() + 7);
const predicate = createEventPredicate(startDate, endDate);
```

### `createReminderPredicate(calendarIds?: string[])`

Creates a predicate for querying all reminders, optionally filtered by calendars.

- `calendarIds`: Optional array of calendar IDs to filter by.
- Returns: A Predicate object that can be used with `getRemindersWithPredicate`.

**Example:**

```javascript
// Create a predicate for all reminders in specific calendars
const calendarIds = ['calendar-id-1', 'calendar-id-2'];
const predicate = createReminderPredicate(calendarIds);
```

### `createIncompleteReminderPredicate(startDate?: Date, endDate?: Date, calendarIds?: string[])`

Creates a predicate for querying incomplete reminders with due dates in a specific range, optionally filtered by calendars.

- `startDate`: Optional start date of the range.
- `endDate`: Optional end date of the range.
- `calendarIds`: Optional array of calendar IDs to filter by.
- Returns: A Predicate object that can be used with `getRemindersWithPredicate`.

**Example:**

```javascript
// Create a predicate for incomplete reminders due in the next week
const startDate = new Date();
const endDate = new Date();
endDate.setDate(endDate.getDate() + 7);
const predicate = createIncompleteReminderPredicate(startDate, endDate);
```

### `createCompletedReminderPredicate(startDate?: Date, endDate?: Date, calendarIds?: string[])`

Creates a predicate for querying completed reminders with completion dates in a specific range, optionally filtered by calendars.

- `startDate`: Optional start date of the range.
- `endDate`: Optional end date of the range.
- `calendarIds`: Optional array of calendar IDs to filter by.
- Returns: A Predicate object that can be used with `getRemindersWithPredicate`.

**Example:**

```javascript
// Create a predicate for reminders completed in the last week
const endDate = new Date();
const startDate = new Date();
startDate.setDate(startDate.getDate() - 7);
const predicate = createCompletedReminderPredicate(startDate, endDate);
```

### `getEventsWithPredicate(predicate: Predicate)`

Gets events matching a predicate.

- `predicate`: The predicate to match events against, created with `createEventPredicate`.
- Returns: An array of Event objects matching the predicate.
- Throws: Error if the predicate is not an event predicate.

**Example:**

```javascript
// Get events for the next week
const startDate = new Date();
const endDate = new Date();
endDate.setDate(endDate.getDate() + 7);
const predicate = createEventPredicate(startDate, endDate);
const events = getEventsWithPredicate(predicate);
```

### `getRemindersWithPredicate(predicate: Predicate)`

Gets reminders matching a predicate. This is an asynchronous operation.

- `predicate`: The predicate to match reminders against, created with one of the reminder predicate creation methods.
- Returns: A Promise that resolves to an array of Reminder objects matching the predicate.
- Throws: Error if the predicate is not a reminder predicate.

**Example:**

```javascript
// Get incomplete reminders due in the next week
const startDate = new Date();
const endDate = new Date();
endDate.setDate(endDate.getDate() + 7);
const predicate = createIncompleteReminderPredicate(startDate, endDate);
const reminders = await getRemindersWithPredicate(predicate);
```

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

### `CalendarColor`

```typescript
interface CalendarColor {
  /** Hex color code with alpha (#RRGGBBAA) */
  hex: string;
  /** Raw color components as comma-separated values */
  components: string;
  /** Color space of the original color */
  space: ColorSpace;
}
```

### `Source`

```typescript
interface Source {
  /** Unique identifier for the source */
  id: string;
  /** Display name of the source */
  title: string;
  /** Type of the source (local, calDAV, etc.) */
  sourceType: SourceType;
}
```

### `Calendar`

```typescript
interface Calendar {
  /** Unique identifier for the calendar */
  id: string;
  /** Display name of the calendar */
  title: string;
  /** Whether the calendar allows content modifications */
  allowsContentModifications: boolean;
  /** Type of the calendar (local, calDAV, etc.) */
  type: CalendarType;
  /** Color of the calendar */
  color: CalendarColor;
  /** Source of the calendar */
  source: string;
  /** Entity types allowed in this calendar (event, reminder) */
  allowedEntityTypes: EntityType[];
}
```

### `Event`

```typescript
interface Event {
  /** Unique identifier for the event */
  id: string;
  /** Title of the event */
  title: string;
  /** Notes or description of the event */
  notes: string | null;
  /** Start date of the event */
  startDate: Date;
  /** End date of the event */
  endDate: Date;
  /** Whether the event is an all-day event */
  isAllDay: boolean;
  /** ID of the calendar this event belongs to */
  calendarId: string;
  /** Title of the calendar this event belongs to */
  calendarTitle: string;
  /** Location of the event */
  location: string | null;
  /** URL associated with the event */
  url: string | null;
  /** Whether the event has alarms */
  hasAlarms: boolean;
  /** Availability during the event (free, busy, tentative, unavailable) */
  availability: string;
}
```

### `Reminder`

```typescript
interface Reminder {
  /** Unique identifier for the reminder */
  id: string;
  /** Title of the reminder */
  title: string;
  /** Notes or description of the reminder */
  notes: string | null;
  /** ID of the calendar this reminder belongs to */
  calendarId: string;
  /** Title of the calendar this reminder belongs to */
  calendarTitle: string;
  /** Whether the reminder is completed */
  completed: boolean;
  /** Date when the reminder was completed */
  completionDate: Date | null;
  /** Due date of the reminder */
  dueDate: Date | null;
  /** Start date of the reminder */
  startDate: Date | null;
  /** Priority of the reminder (0-9, where 0 is no priority) */
  priority: number;
  /** Whether the reminder has alarms */
  hasAlarms: boolean;
}
```

### `Predicate`

```typescript
interface Predicate {
  /** Type of the predicate (event, reminder, incompleteReminder, completedReminder) */
  type: string;
}
```