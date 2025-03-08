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
```

## Usage

```javascript
const eventkit = require('./build/Release/eventkit');

// Request calendar access
eventkit.requestCalendarAccess().then(granted => {
  console.log('Calendar access granted:', granted);
  
  if (granted) {
    // Get all calendars
    const calendars = eventkit.getCalendars();
    console.log('Calendars:', calendars);
  }
});
```

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