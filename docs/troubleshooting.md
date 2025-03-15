# EventKit Node.js Troubleshooting Guide

This document provides solutions for common issues you might encounter when using the EventKit Node.js addon.

## Build Issues

If you encounter build errors:

### Missing Command Line Tools

```
error: tool 'xcodebuild' requires Xcode
```

**Solution**: Install Xcode Command Line Tools:

```bash
xcode-select --install
```

### Clean Build Required

If you've updated Xcode or Node.js, you might need to clean the build:

```bash
npm run clean
npm run build
```

### Framework Issues

If you see errors related to missing frameworks:

```
ld: framework not found EventKit
```

**Solution**: Make sure you have the required frameworks installed on your system. EventKit is part of macOS, so ensure you're on macOS 10.15 or later.

## Permission Issues

### Permission Dialog Not Appearing

If permission requests (`requestFullAccessToEvents`, `requestFullAccessToReminders`, or their simplified equivalents `requestCalendarAccess`, `requestRemindersAccess`) return `false` without showing a permission dialog:

#### Missing Privacy Descriptions

**Solution**: Ensure your application's Info.plist includes the required privacy descriptions:

```xml
<key>NSCalendarsUsageDescription</key>
<string>Your reason for accessing calendars</string>

<key>NSRemindersUsageDescription</key>
<string>Your reason for accessing reminders</string>
```

For Electron apps, add these to the Info.plist in your app bundle.

#### Previously Denied Permissions

**Solution**: The user may have previously denied permission. They'll need to enable it manually in System Preferences → Security & Privacy → Privacy → Calendars/Reminders.

#### Reset Privacy Settings (Development Only)

For testing, you can reset privacy settings:

```bash
tccutil reset Calendar [YOUR_BUNDLE_ID]
tccutil reset Reminders [YOUR_BUNDLE_ID]
```

#### Invalid Bundle ID

**Solution**: Make sure your application has a valid bundle identifier.

## TypeScript Issues

### Type Errors

If you encounter TypeScript errors:

```
Property 'getCalendars' does not exist on type...
```

**Solution**: Make sure you're importing the functions and types correctly:

```typescript
// Import the module and destructure methods from simple
import { simple, Calendar, ReminderList } from 'eventkit-node';
const { requestCalendarAccess, getCalendars, getCalendar } = simple;

// Use with type annotations
const eventCalendars: Calendar[] = getCalendars();
const specificCalendar: Calendar | null = getCalendar('calendar-id');
```

### Missing Type Definitions

If TypeScript can't find the type definitions:

**Solution**: Rebuild the TypeScript definitions:

```bash
npm run build:ts
```

## Runtime Issues

### Undefined or Null Values

If you're getting undefined or null values when accessing calendar properties:

**Solution**: Make sure you've been granted permission before trying to access calendars or reminders. Always check the return value of permission requests:

```javascript
// Destructure methods from simple
const { requestCalendarAccess, getCalendars, getCalendar } = require('eventkit-node').simple;

const granted = await requestCalendarAccess();
if (granted) {
  // Now it's safe to access calendars
  const calendars = getCalendars();
  
  // Get a specific calendar
  if (calendars.length > 0) {
    const calendar = getCalendar(calendars[0].id);
    console.log(calendar);
  }
}
```

### Empty Calendar Lists

If you're getting empty arrays when calling `getCalendars()` or `getReminderLists()`:

**Solution**: 
1. Make sure you've been granted permission
2. Check if the user actually has any calendars or reminder lists set up on their system
3. Try using the EventKit-like API with explicit entity type:
   ```javascript
   const eventkit = require('eventkit-node').default;
   const eventCalendars = eventkit.getCalendars('event');
   const reminderLists = eventkit.getCalendars('reminder');
   ```

## Electron-Specific Issues

### Permissions in Electron

Electron apps require special handling for permissions:

**Solution**:
1. Make sure your app is properly signed
2. Include the privacy descriptions in your app's Info.plist
3. Consider using Electron's `systemPreferences.askForMediaAccess` before requesting calendar access

### Bundling Issues

If you're having trouble bundling the native addon with Electron:

**Solution**: Make sure you're rebuilding the native modules for Electron:

```bash
npm install --save-dev electron-rebuild
./node_modules/.bin/electron-rebuild
```

Or use a tool like `electron-builder` which handles native addons automatically. 