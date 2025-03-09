# EventKit Node.js Addon

A Node.js native addon that provides access to macOS EventKit functionality.

## Prerequisites

- macOS 10.15 or later
- Node.js 14 or later
- Xcode 12 or later with Command Line Tools installed
- Swift 5.5 or later

## Building

```bash
# Install dependencies
npm install

# Build the addon
npm run build

# Build TypeScript definitions (if using TypeScript)
npm run build:ts
```

## Usage

### JavaScript (CommonJS)

You can import the module in two ways:

#### Object-style import:

```javascript
const eventkit = require('eventkit-node').default;

// Request calendar access
eventkit.requestCalendarAccess().then(granted => {
  console.log('Calendar access granted:', granted);
  
  if (granted) {
    // Get all event calendars (default)
    const eventCalendars = eventkit.getCalendars();
    console.log('Event calendars:', eventCalendars);
    
    // Get reminder calendars
    const reminderCalendars = eventkit.getCalendars('reminder');
    console.log('Reminder calendars:', reminderCalendars);
    
    // Access calendar properties
    eventCalendars.forEach(calendar => {
      console.log(`Calendar: ${calendar.title}`);
      console.log(`  ID: ${calendar.id}`);
      console.log(`  Type: ${calendar.type}`);
      console.log(`  Color (hex): ${calendar.color.hex}`);
      console.log(`  Color space: ${calendar.color.space}`);
      console.log(`  Source: ${calendar.source}`);
      console.log(`  Allows modifications: ${calendar.allowsContentModifications}`);
    });
  }
});
```

#### Named imports:

```javascript
const { requestCalendarAccess, getCalendars } = require('eventkit-node');

// Request calendar access
requestCalendarAccess().then(granted => {
  console.log('Calendar access granted:', granted);
  
  if (granted) {
    // Get all event calendars (default)
    const eventCalendars = getCalendars();
    console.log('Event calendars:', eventCalendars);
    
    // Get reminder calendars
    const reminderCalendars = getCalendars('reminder');
    console.log('Reminder calendars:', reminderCalendars);
    
    // Access calendar properties
    eventCalendars.forEach(calendar => {
      console.log(`Calendar: ${calendar.title}`);
      console.log(`  ID: ${calendar.id}`);
      console.log(`  Type: ${calendar.type}`);
      console.log(`  Color (hex): ${calendar.color.hex}`);
      console.log(`  Color components: ${calendar.color.components}`);
      console.log(`  Source: ${calendar.source}`);
    });
  }
});
```

### TypeScript

You can also import the module in two ways:

#### Default import:

```typescript
import eventkit from 'eventkit-node';

async function main() {
  // Request calendar access
  const granted = await eventkit.requestCalendarAccess();
  console.log('Calendar access granted:', granted);
  
  if (granted) {
    // Get all event calendars (default)
    const eventCalendars = eventkit.getCalendars();
    console.log('Event calendars:', eventCalendars);
    
    // Get reminder calendars
    const reminderCalendars = eventkit.getCalendars('reminder');
    console.log('Reminder calendars:', reminderCalendars);
    
    // TypeScript knows the calendar structure
    eventCalendars.forEach(calendar => {
      console.log(`Calendar: ${calendar.title}`);
      console.log(`  ID: ${calendar.id}`);
      console.log(`  Type: ${calendar.type}`);
      console.log(`  Color (hex): ${calendar.color.hex}`);
      console.log(`  Color space: ${calendar.color.space}`);
      console.log(`  Source: ${calendar.source}`);
    });
    
    // TypeScript will catch this error at compile time:
    // const invalidCalendars = eventkit.getCalendars('invalid');
  }
}
```

#### Named imports:

```typescript
import { requestCalendarAccess, getCalendars, EntityType, Calendar, CalendarColor } from 'eventkit-node';

async function main() {
  // Request calendar access
  const granted = await requestCalendarAccess();
  console.log('Calendar access granted:', granted);
  
  if (granted) {
    // Get all event calendars (default)
    const eventCalendars = getCalendars();
    console.log('Event calendars:', eventCalendars);
    
    // Get reminder calendars
    const reminderCalendars = getCalendars('reminder');
    console.log('Reminder calendars:', reminderCalendars);
    
    // You can also use the EntityType in your own functions
    function processCalendars(type: EntityType): Calendar[] {
      return getCalendars(type);
    }
    
    // Process and display calendars
    processCalendars('event').forEach(calendar => {
      console.log(`Calendar: ${calendar.title}`);
      console.log(`  ID: ${calendar.id}`);
      console.log(`  Type: ${calendar.type}`);
      console.log(`  Color (hex): ${calendar.color.hex}`);
      console.log(`  Color components: ${calendar.color.components}`);
      console.log(`  Source: ${calendar.source}`);
    });
    
    // TypeScript will catch this error at compile time:
    // const invalidCalendars = getCalendars('invalid');
  }
}
```

## API

### `requestCalendarAccess()`

Requests access to the calendar and returns a promise that resolves to a boolean indicating whether access was granted.

### `getCalendars(entityType?: 'event' | 'reminder')`

Gets a list of calendar objects for the specified entity type.

- `entityType`: Optional. The type of entity to get calendars for. Can be either 'event' (default) or 'reminder'.

Returns an array of `Calendar` objects with the following properties:

- `id`: Unique identifier for the calendar
- `title`: Display name of the calendar
- `allowsContentModifications`: Whether the calendar allows content modifications
- `type`: Type of the calendar ('local', 'calDAV', 'exchange', 'subscription', 'birthday', or 'unknown')
- `color`: Color information with multiple representations:
  - `hex`: Hex color code with alpha (#RRGGBBAA)
  - `components`: Raw color components as comma-separated values
  - `space`: Color space of the original color
- `source`: Source of the calendar (e.g., iCloud, Google)

### Types

#### `EntityType`

TypeScript type that represents the valid entity types: 'event' | 'reminder'.

#### `CalendarType`

TypeScript type that represents the valid calendar types: 'local' | 'calDAV' | 'exchange' | 'subscription' | 'birthday' | 'unknown'.

#### `ColorSpace`

TypeScript type that represents the valid color spaces: 'rgb' | 'monochrome' | 'cmyk' | 'lab' | 'deviceN' | 'indexed' | 'pattern' | 'unknown'.

#### `CalendarColor`

TypeScript interface that represents a color with multiple representations to prevent data loss.

#### `Calendar`

TypeScript interface that represents a calendar object.

## Troubleshooting

If you encounter build errors:

1. Make sure Xcode Command Line Tools are installed:
   ```bash
   xcode-select --install
   ```

2. Clean the build and try again:
   ```bash
   npm run clean
   npm run build
   ```

3. Check that you have the required frameworks installed on your system.

## License

MIT 