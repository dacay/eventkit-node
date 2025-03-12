# EventKit Node.js Usage Examples

This document provides detailed examples of how to use the EventKit Node.js addon in both JavaScript and TypeScript.

## JavaScript Examples

### Import Options

```javascript
// Option 1: EventKit-like API (default export)
const eventkit = require('eventkit-node').default;

// Option 2: Simplified API (destructuring from simple)
const { requestCalendarAccess, getCalendars, getReminderLists, requestRemindersAccess } = require('eventkit-node').simple;

// Option 3: Mixed approach (both APIs)
const eventkit = require('eventkit-node').default;
const { requestCalendarAccess, getCalendars } = require('eventkit-node').simple;
```

### Using the EventKit-like API

#### Promise-based approach:

```javascript
// Import the EventKit-like API
const eventkit = require('eventkit-node').default;

// Request calendar access
eventkit.requestFullAccessToEvents()
  .then(granted => {
    console.log('Calendar access granted:', granted);
    
    if (granted) {
      // Get event calendars
      const eventCalendars = eventkit.getCalendars('event');
      console.log('Event calendars:', eventCalendars);
      
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
      
      // Get reminder lists
      const reminderLists = eventkit.getCalendars('reminder');
      console.log('Reminder lists:', reminderLists);
    }
  })
  .catch(error => {
    console.error('Error accessing calendars:', error);
  });
```

#### Async/await approach:

```javascript
// Import the EventKit-like API
const eventkit = require('eventkit-node').default;

async function accessCalendars() {
  try {
    // Request calendar access
    const granted = await eventkit.requestFullAccessToEvents();
    console.log('Calendar access granted:', granted);
    
    if (granted) {
      // Get event calendars
      const eventCalendars = eventkit.getCalendars('event');
      console.log('Event calendars:', eventCalendars);
      
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
      
      // Get reminder lists
      const reminderLists = eventkit.getCalendars('reminder');
      console.log('Reminder lists:', reminderLists);
    }
  } catch (error) {
    console.error('Error accessing calendars:', error);
  }
}

// Call the async function
accessCalendars();
```

### Using the Simplified API

#### Promise-based approach:

```javascript
// Import the simplified API by destructuring from simple
const { requestCalendarAccess, requestRemindersAccess, getCalendars, getReminderLists } = require('eventkit-node').simple;

// Request calendar access
requestCalendarAccess()
  .then(granted => {
    console.log('Calendar access granted:', granted);
    
    if (granted) {
      // Get event calendars
      const eventCalendars = getCalendars();
      console.log('Event calendars:', eventCalendars);
    }
    
    // Request reminders access
    return requestRemindersAccess();
  })
  .then(granted => {
    console.log('Reminders access granted:', granted);
    
    if (granted) {
      // Get reminder lists
      const reminderLists = getReminderLists();
      console.log('Reminder lists:', reminderLists);
      
      // Access reminder list properties
      reminderLists.forEach(list => {
        console.log(`Reminder List: ${list.title}`);
        console.log(`  ID: ${list.id}`);
        console.log(`  Type: ${list.type}`);
        console.log(`  Color (hex): ${list.color.hex}`);
        console.log(`  Color components: ${list.color.components}`);
        console.log(`  Source: ${list.source}`);
      });
    }
  })
  .catch(error => {
    console.error('Error accessing calendars or reminders:', error);
  });
```

#### Async/await approach:

```javascript
// Import the simplified API by destructuring from simple
const { requestCalendarAccess, requestRemindersAccess, getCalendars, getReminderLists } = require('eventkit-node').simple;

async function accessCalendarsAndReminders() {
  try {
    // Request calendar access
    const calendarAccessGranted = await requestCalendarAccess();
    console.log('Calendar access granted:', calendarAccessGranted);
    
    if (calendarAccessGranted) {
      // Get event calendars
      const eventCalendars = getCalendars();
      console.log('Event calendars:', eventCalendars);
    }
    
    // Request reminders access
    const remindersAccessGranted = await requestRemindersAccess();
    console.log('Reminders access granted:', remindersAccessGranted);
    
    if (remindersAccessGranted) {
      // Get reminder lists
      const reminderLists = getReminderLists();
      console.log('Reminder lists:', reminderLists);
      
      // Access reminder list properties
      reminderLists.forEach(list => {
        console.log(`Reminder List: ${list.title}`);
        console.log(`  ID: ${list.id}`);
        console.log(`  Type: ${list.type}`);
        console.log(`  Color (hex): ${list.color.hex}`);
        console.log(`  Color components: ${list.color.components}`);
        console.log(`  Source: ${list.source}`);
      });
    }
  } catch (error) {
    console.error('Error accessing calendars or reminders:', error);
  }
}

// Call the async function
accessCalendarsAndReminders();
```

### Using Both APIs Together

```javascript
// Import both APIs
const eventkit = require('eventkit-node').default;
const { requestCalendarAccess, getCalendars } = require('eventkit-node').simple;

async function accessEverything() {
  try {
    // Use simplified API for calendar access
    const calendarAccessGranted = await requestCalendarAccess();
    console.log('Calendar access granted:', calendarAccessGranted);
    
    // Use EventKit-like API for reminders access
    const remindersAccessGranted = await eventkit.requestFullAccessToReminders();
    console.log('Reminders access granted:', remindersAccessGranted);
    
    if (calendarAccessGranted || remindersAccessGranted) {
      // Process and display calendars based on granted permissions
      if (calendarAccessGranted) {
        // Use simplified API
        const eventCalendars = getCalendars();
        eventCalendars.forEach(calendar => {
          console.log(`Event Calendar: ${calendar.title}`);
        });
      }
      
      if (remindersAccessGranted) {
        // Use EventKit-like API
        const reminderLists = eventkit.getCalendars('reminder');
        reminderLists.forEach(list => {
          console.log(`Reminder List: ${list.title}`);
        });
      }
    }
  } catch (error) {
    console.error('Error accessing calendars or reminders:', error);
  }
}

// Call the async function
accessEverything();
```

## TypeScript Examples

### Import Options

```typescript
// Option 1: EventKit-like API (default export)
import eventkit from 'eventkit-node';

// Option 2: Simplified API (destructuring from simple) with type imports
import { simple, Calendar, ReminderList } from 'eventkit-node';
const { requestCalendarAccess, getCalendars, getReminderLists, requestRemindersAccess } = simple;

// Option 3: Mixed approach (both APIs) with type imports
import eventkit from 'eventkit-node';
import { simple, Calendar, ReminderList } from 'eventkit-node';
const { requestCalendarAccess, getCalendars } = simple;
```

### Using the EventKit-like API

```typescript
import eventkit from 'eventkit-node';
import { Calendar } from 'eventkit-node';

async function accessCalendars() {
  try {
    // Request calendar access
    const calendarAccessGranted = await eventkit.requestFullAccessToEvents();
    console.log('Calendar access granted:', calendarAccessGranted);
    
    if (calendarAccessGranted) {
      // Get event calendars
      const eventCalendars: Calendar[] = eventkit.getCalendars('event');
      console.log('Event calendars:', eventCalendars);
      
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
      
      // Get reminder lists
      const reminderLists: Calendar[] = eventkit.getCalendars('reminder');
      console.log('Reminder lists:', reminderLists);
    }
  } catch (error) {
    console.error('Error accessing calendars:', error);
  }
}

// Call the async function
accessCalendars();
```

### Using the Simplified API

```typescript
// Import the simplified API by destructuring from simple
import { simple, Calendar, ReminderList } from 'eventkit-node';
const { requestCalendarAccess, requestRemindersAccess, getCalendars, getReminderLists } = simple;

async function accessCalendarsAndReminders() {
  try {
    // Request calendar access
    const calendarAccessGranted = await requestCalendarAccess();
    console.log('Calendar access granted:', calendarAccessGranted);
    
    if (calendarAccessGranted) {
      // Get event calendars
      const eventCalendars: Calendar[] = getCalendars();
      console.log('Event calendars:', eventCalendars);
    }
    
    // Request reminders access
    const remindersAccessGranted = await requestRemindersAccess();
    console.log('Reminders access granted:', remindersAccessGranted);
    
    if (remindersAccessGranted) {
      // Get reminder lists
      const reminderLists: ReminderList[] = getReminderLists();
      console.log('Reminder lists:', reminderLists);
      
      // Access reminder list properties
      reminderLists.forEach(list => {
        console.log(`Reminder List: ${list.title}`);
        console.log(`  ID: ${list.id}`);
        console.log(`  Type: ${list.type}`);
        console.log(`  Color (hex): ${list.color.hex}`);
        console.log(`  Color space: ${list.color.space}`);
        console.log(`  Source: ${list.source}`);
      });
    }
  } catch (error) {
    console.error('Error accessing calendars or reminders:', error);
  }
}

// Call the async function
accessCalendarsAndReminders();
```

### Using Both APIs Together

```typescript
// Import both APIs
import eventkit from 'eventkit-node';
import { simple, Calendar, ReminderList } from 'eventkit-node';
const { requestCalendarAccess, getCalendars } = simple;

async function accessEverything() {
  try {
    // Use simplified API for calendar access
    const calendarAccessGranted = await requestCalendarAccess();
    console.log('Calendar access granted:', calendarAccessGranted);
    
    // Use EventKit-like API for reminders access
    const remindersAccessGranted = await eventkit.requestFullAccessToReminders();
    console.log('Reminders access granted:', remindersAccessGranted);
    
    if (calendarAccessGranted || remindersAccessGranted) {
      // Process and display calendars based on granted permissions
      if (calendarAccessGranted) {
        // Use simplified API
        const eventCalendars: Calendar[] = getCalendars();
        eventCalendars.forEach(calendar => {
          console.log(`Event Calendar: ${calendar.title}`);
        });
      }
      
      if (remindersAccessGranted) {
        // Use EventKit-like API
        const reminderLists: ReminderList[] = eventkit.getCalendars('reminder');
        reminderLists.forEach(list => {
          console.log(`Reminder List: ${list.title}`);
        });
      }
    }
  } catch (error) {
    console.error('Error accessing calendars or reminders:', error);
  }
}

// Call the async function
accessEverything();
``` 