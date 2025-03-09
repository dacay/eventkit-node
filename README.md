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

### JavaScript

```javascript
const eventkit = require('eventkit-node');

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
  }
});
```

### TypeScript

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
    
    // TypeScript will catch this error at compile time:
    // const invalidCalendars = eventkit.getCalendars('invalid');
  }
}
```

## API

### `requestCalendarAccess()`

Requests access to the calendar and returns a promise that resolves to a boolean indicating whether access was granted.

### `getCalendars(entityType?: 'event' | 'reminder')`

Gets a list of calendar titles for the specified entity type.

- `entityType`: Optional. The type of entity to get calendars for. Can be either 'event' (default) or 'reminder'.

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