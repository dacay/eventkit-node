# EventKit Node.js Usage Examples

This document provides detailed examples of how to use the EventKit Node.js addon in both JavaScript and TypeScript.

## JavaScript Examples

### Import Options

```javascript
// Option 1: EventKit-like API (default export)
const eventkit = require('eventkit-node').default;

// Option 2: Simplified API (destructuring from simple)
const { requestCalendarAccess, getCalendars, getReminderLists, requestRemindersAccess, getCalendar, createCalendar, updateCalendar } = require('eventkit-node').simple;

// Option 3: Mixed approach (both APIs)
const eventkit = require('eventkit-node').default;
const { requestCalendarAccess, getCalendars, getCalendar } = require('eventkit-node').simple;
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
      
      // Get a specific calendar by ID
      if (eventCalendars.length > 0) {
        const calendarId = eventCalendars[0].id;
        const specificCalendar = eventkit.getCalendar(calendarId);
        console.log('Specific calendar:', specificCalendar);
      }
      
      // Get reminder lists
      const reminderLists = eventkit.getCalendars('reminder');
      console.log('Reminder lists:', reminderLists);
    }
  })
  .then(granted => {
    if (granted) {
      // Get all event calendars
      const calendars = eventkit.getCalendars('event');
      console.log('Event calendars:', calendars);
      
      // Create a new calendar
      return eventkit.saveCalendar({
        title: 'My New Calendar',
        entityType: 'event',
        color: { hex: '#FF0000FF' } // Red with full opacity
      }, true); // commit immediately
    }
  })
  .then(calendarId => {
    if (calendarId) {
      console.log('Created new calendar with ID:', calendarId);
      
      // Get the newly created calendar
      const calendar = eventkit.getCalendar(calendarId);
      
      // Update the calendar
      if (calendar) {
        // Modify the calendar object
        calendar.title = 'My Updated Calendar';
        
        // Save the changes
        return eventkit.saveCalendar(calendar, true);
      }
    }
  })
  .then(updatedCalendarId => {
    if (updatedCalendarId) {
      console.log('Updated calendar with ID:', updatedCalendarId);
    }
  })
  .catch(error => {
    console.error('Error:', error);
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
      
      // Get a specific calendar by ID
      if (eventCalendars.length > 0) {
        const calendarId = eventCalendars[0].id;
        const specificCalendar = eventkit.getCalendar(calendarId);
        console.log('Specific calendar:', specificCalendar);
      }
      
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
const { requestCalendarAccess, requestRemindersAccess, getCalendars, getReminderLists, getCalendar, createCalendar, updateCalendar } = require('eventkit-node').simple;

// Request calendar access
requestCalendarAccess()
  .then(granted => {
    console.log('Calendar access granted:', granted);
    
    if (granted) {
      // Get event calendars
      const eventCalendars = getCalendars();
      console.log('Event calendars:', eventCalendars);
      
      // Get a specific calendar by ID
      if (eventCalendars.length > 0) {
        const calendarId = eventCalendars[0].id;
        const specificCalendar = getCalendar(calendarId);
        console.log('Specific calendar:', specificCalendar);
      }
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
      
      // Get a specific reminder list by ID
      if (reminderLists.length > 0) {
        const reminderListId = reminderLists[0].id;
        const specificReminderList = getCalendar(reminderListId);
        console.log('Specific reminder list:', specificReminderList);
      }
    }
  })
  .then(granted => {
    if (granted) {
      // Get all event calendars
      const calendars = getCalendars();
      console.log('Event calendars:', calendars);
      
      // Create a new calendar
      return createCalendar({
        title: 'My New Calendar',
        entityType: 'event',
        color: { hex: '#FF0000FF' } // Red with full opacity
      });
    }
  })
  .then(calendarId => {
    if (calendarId) {
      console.log('Created new calendar with ID:', calendarId);
      
      // Get the newly created calendar
      const calendar = getCalendar(calendarId);
      
      // Update the calendar
      if (calendar) {
        // Modify the calendar object
        calendar.title = 'My Updated Calendar';
        
        // Save the changes
        return updateCalendar(calendar);
      }
    }
  })
  .then(updatedCalendarId => {
    if (updatedCalendarId) {
      console.log('Updated calendar with ID:', updatedCalendarId);
    }
  })
  .catch(error => {
    console.error('Error accessing calendars or reminders:', error);
  });
```

#### Async/await approach:

```javascript
// Import the simplified API by destructuring from simple
const { requestCalendarAccess, requestRemindersAccess, getCalendars, getReminderLists, getCalendar, createCalendar, updateCalendar } = require('eventkit-node').simple;

async function accessCalendarsAndReminders() {
  try {
    // Request calendar access
    const calendarAccessGranted = await requestCalendarAccess();
    console.log('Calendar access granted:', calendarAccessGranted);
    
    if (calendarAccessGranted) {
      // Get event calendars
      const eventCalendars = getCalendars();
      console.log('Event calendars:', eventCalendars);
      
      // Get a specific calendar by ID
      if (eventCalendars.length > 0) {
        const calendarId = eventCalendars[0].id;
        const specificCalendar = getCalendar(calendarId);
        console.log('Specific calendar:', specificCalendar);
      }
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
        console.log(`  Color space: ${list.color.space}`);
        console.log(`  Source: ${list.source}`);
      });
      
      // Get a specific reminder list by ID
      if (reminderLists.length > 0) {
        const reminderListId = reminderLists[0].id;
        const specificReminderList = getCalendar(reminderListId);
        console.log('Specific reminder list:', specificReminderList);
      }
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
const { requestCalendarAccess, getCalendars, getCalendar } = require('eventkit-node').simple;

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
        
        // Get a specific calendar using simplified API
        if (eventCalendars.length > 0) {
          const calendarId = eventCalendars[0].id;
          const specificCalendar = getCalendar(calendarId);
          console.log('Specific calendar (simplified API):', specificCalendar);
        }
      }
      
      if (remindersAccessGranted) {
        // Use EventKit-like API
        const reminderLists = eventkit.getCalendars('reminder');
        reminderLists.forEach(list => {
          console.log(`Reminder List: ${list.title}`);
        });
        
        // Get a specific reminder list using EventKit-like API
        if (reminderLists.length > 0) {
          const reminderListId = reminderLists[0].id;
          const specificReminderList = eventkit.getCalendar(reminderListId);
          console.log('Specific reminder list (EventKit-like API):', specificReminderList);
        }
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
const { requestCalendarAccess, getCalendars, getReminderLists, requestRemindersAccess, getCalendar, createCalendar, updateCalendar } = simple;

// Option 3: Mixed approach (both APIs) with type imports
import eventkit from 'eventkit-node';
import { simple, Calendar, ReminderList } from 'eventkit-node';
const { requestCalendarAccess, getCalendars, getCalendar } = simple;
```

### Using the EventKit-like API

#### Promise-based approach:

```typescript
// Import the EventKit-like API with types
import eventkit, { Calendar } from 'eventkit-node';

// Request calendar access
eventkit.requestFullAccessToEvents()
  .then((granted: boolean) => {
    console.log('Calendar access granted:', granted);
    
    if (granted) {
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
      
      // Get a specific calendar by ID
      if (eventCalendars.length > 0) {
        const calendarId: string = eventCalendars[0].id;
        const specificCalendar: Calendar | null = eventkit.getCalendar(calendarId);
        console.log('Specific calendar:', specificCalendar);
      }
      
      // Get reminder lists
      const reminderLists: Calendar[] = eventkit.getCalendars('reminder');
      console.log('Reminder lists:', reminderLists);
    }
    
    return eventkit.requestFullAccessToReminders();
  })
  .then((granted: boolean) => {
    if (granted) {
      // Get all event calendars
      const calendars: Calendar[] = eventkit.getCalendars('event');
      console.log('Event calendars:', calendars);
      
      // Create a new calendar
      return eventkit.saveCalendar({
        title: 'My New Calendar',
        entityType: 'event',
        color: { hex: '#FF0000FF' } // Red with full opacity
      }, true); // commit immediately
    }
  })
  .then((calendarId?: string) => {
    if (calendarId) {
      console.log('Created new calendar with ID:', calendarId);
      
      // Get the newly created calendar
      const calendar: Calendar | null = eventkit.getCalendar(calendarId);
      
      // Update the calendar
      if (calendar) {
        // Modify the calendar object
        calendar.title = 'My Updated Calendar';
        
        // Save the changes
        return eventkit.saveCalendar(calendar, true);
      }
    }
  })
  .then((updatedCalendarId?: string) => {
    if (updatedCalendarId) {
      console.log('Updated calendar with ID:', updatedCalendarId);
    }
  })
  .catch((error: any) => {
    console.error('Error:', error);
  });
```

#### Async/await approach:

```typescript
// Import the EventKit-like API with types
import eventkit, { Calendar } from 'eventkit-node';

async function accessCalendars() {
  try {
    // Request calendar access
    const granted: boolean = await eventkit.requestFullAccessToEvents();
    console.log('Calendar access granted:', granted);
    
    if (granted) {
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
      
      // Get a specific calendar by ID
      if (eventCalendars.length > 0) {
        const calendarId: string = eventCalendars[0].id;
        const specificCalendar: Calendar | null = eventkit.getCalendar(calendarId);
        console.log('Specific calendar:', specificCalendar);
      }
      
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

#### Promise-based approach:

```typescript
// Import the simplified API by destructuring from simple
import { simple, Calendar, ReminderList } from 'eventkit-node';
const { requestCalendarAccess, requestRemindersAccess, getCalendars, getReminderLists, getCalendar, createCalendar, updateCalendar } = simple;

// Request calendar access
requestCalendarAccess()
  .then((granted: boolean) => {
    console.log('Calendar access granted:', granted);
    
    if (granted) {
      // Get event calendars
      const eventCalendars: Calendar[] = getCalendars();
      console.log('Event calendars:', eventCalendars);
      
      // Get a specific calendar by ID
      if (eventCalendars.length > 0) {
        const calendarId: string = eventCalendars[0].id;
        const specificCalendar: Calendar | null = getCalendar(calendarId);
        console.log('Specific calendar:', specificCalendar);
      }
    }
    
    // Request reminders access
    return requestRemindersAccess();
  })
  .then((granted: boolean) => {
    console.log('Reminders access granted:', granted);
    
    if (granted) {
      // Get reminder lists
      const reminderLists: ReminderList[] = getReminderLists();
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
      
      // Get a specific reminder list by ID
      if (reminderLists.length > 0) {
        const reminderListId: string = reminderLists[0].id;
        const specificReminderList: ReminderList | null = getCalendar(reminderListId);
        console.log('Specific reminder list:', specificReminderList);
      }
    }
    
    return true;
  })
  .then((granted: boolean) => {
    if (granted) {
      // Get all event calendars
      const calendars: Calendar[] = getCalendars();
      console.log('Event calendars:', calendars);
      
      // Create a new calendar
      return createCalendar({
        title: 'My New Calendar',
        entityType: 'event',
        color: { hex: '#FF0000FF' } // Red with full opacity
      });
    }
  })
  .then((calendarId?: string) => {
    if (calendarId) {
      console.log('Created new calendar with ID:', calendarId);
      
      // Get the newly created calendar
      const calendar: Calendar | null = getCalendar(calendarId);
      
      // Update the calendar
      if (calendar) {
        // Modify the calendar object
        calendar.title = 'My Updated Calendar';
        
        // Save the changes
        return updateCalendar(calendar);
      }
    }
  })
  .then((updatedCalendarId?: string) => {
    if (updatedCalendarId) {
      console.log('Updated calendar with ID:', updatedCalendarId);
    }
  })
  .catch((error: any) => {
    console.error('Error accessing calendars or reminders:', error);
  });
```

#### Async/await approach:

```typescript
// Import the simplified API by destructuring from simple
import { simple, Calendar, ReminderList } from 'eventkit-node';
const { requestCalendarAccess, requestRemindersAccess, getCalendars, getReminderLists, getCalendar, createCalendar, updateCalendar } = simple;

async function accessCalendarsAndReminders() {
  try {
    // Request calendar access
    const calendarAccessGranted: boolean = await requestCalendarAccess();
    console.log('Calendar access granted:', calendarAccessGranted);
    
    if (calendarAccessGranted) {
      // Get event calendars
      const eventCalendars: Calendar[] = getCalendars();
      console.log('Event calendars:', eventCalendars);
      
      // Get a specific calendar by ID
      if (eventCalendars.length > 0) {
        const calendarId: string = eventCalendars[0].id;
        const specificCalendar: Calendar | null = getCalendar(calendarId);
        console.log('Specific calendar:', specificCalendar);
      }
    }
    
    // Request reminders access
    const remindersAccessGranted: boolean = await requestRemindersAccess();
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
      
      // Get a specific reminder list by ID
      if (reminderLists.length > 0) {
        const reminderListId: string = reminderLists[0].id;
        const specificReminderList: ReminderList | null = getCalendar(reminderListId);
        console.log('Specific reminder list:', specificReminderList);
      }
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
import eventkit, { Calendar } from 'eventkit-node';
import { simple, ReminderList } from 'eventkit-node';
const { requestCalendarAccess, getCalendars, getCalendar } = simple;

async function accessEverything() {
  try {
    // Use simplified API for calendar access
    const calendarAccessGranted: boolean = await requestCalendarAccess();
    console.log('Calendar access granted:', calendarAccessGranted);
    
    // Use EventKit-like API for reminders access
    const remindersAccessGranted: boolean = await eventkit.requestFullAccessToReminders();
    console.log('Reminders access granted:', remindersAccessGranted);
    
    if (calendarAccessGranted || remindersAccessGranted) {
      // Process and display calendars based on granted permissions
      if (calendarAccessGranted) {
        // Use simplified API
        const eventCalendars: Calendar[] = getCalendars();
        eventCalendars.forEach(calendar => {
          console.log(`Event Calendar: ${calendar.title}`);
        });
        
        // Get a specific calendar using simplified API
        if (eventCalendars.length > 0) {
          const calendarId: string = eventCalendars[0].id;
          const specificCalendar: Calendar | null = getCalendar(calendarId);
          console.log('Specific calendar (simplified API):', specificCalendar);
        }
      }
      
      if (remindersAccessGranted) {
        // Use EventKit-like API
        const reminderLists: Calendar[] = eventkit.getCalendars('reminder');
        reminderLists.forEach(list => {
          console.log(`Reminder List: ${list.title}`);
        });
        
        // Get a specific reminder list using EventKit-like API
        if (reminderLists.length > 0) {
          const reminderListId: string = reminderLists[0].id;
          const specificReminderList: Calendar | null = eventkit.getCalendar(reminderListId);
          console.log('Specific reminder list (EventKit-like API):', specificReminderList);
        }
      }
    }
  } catch (error) {
    console.error('Error accessing calendars or reminders:', error);
  }
}

// Call the async function
accessEverything();
```

### Advanced Examples

#### Working with Calendar Colors

```typescript
// Import the simplified API with types
import { simple, Calendar, CalendarData } from 'eventkit-node';
const { requestCalendarAccess, createCalendar, getCalendar } = simple;

async function colorExamples() {
  try {
    // Request calendar access
    const granted: boolean = await requestCalendarAccess();
    
    if (granted) {
      // Create calendars with different colors
      
      // Red calendar
      const redCalendarData: CalendarData = {
        title: 'Red Calendar',
        entityType: 'event',
        color: { hex: '#FF0000FF' } // Red with full opacity
      };
      
      // Green calendar
      const greenCalendarData: CalendarData = {
        title: 'Green Calendar',
        entityType: 'event',
        color: { hex: '#00FF00FF' } // Green with full opacity
      };
      
      // Blue calendar
      const blueCalendarData: CalendarData = {
        title: 'Blue Calendar',
        entityType: 'event',
        color: { hex: '#0000FFFF' } // Blue with full opacity
      };
      
      // Semi-transparent yellow calendar
      const yellowCalendarData: CalendarData = {
        title: 'Yellow Calendar (Semi-transparent)',
        entityType: 'event',
        color: { hex: '#FFFF0080' } // Yellow with 50% opacity
      };
      
      // Create all calendars
      const redId: string = await createCalendar(redCalendarData);
      const greenId: string = await createCalendar(greenCalendarData);
      const blueId: string = await createCalendar(blueCalendarData);
      const yellowId: string = await createCalendar(yellowCalendarData);
      
      console.log('Created calendars with different colors');
      
      // Get one of the calendars to inspect its color properties
      const blueCalendar: Calendar | null = getCalendar(blueId);
      
      if (blueCalendar) {
        // Access the color properties
        console.log('Blue calendar color properties:');
        console.log(`  Hex: ${blueCalendar.color.hex}`);
        console.log(`  Components: ${blueCalendar.color.components}`);
        console.log(`  Color space: ${blueCalendar.color.space}`);
      }
    }
  } catch (error) {
    console.error('Error in color examples:', error);
  }
}

colorExamples();
```

#### Working with Different Entity Types

```typescript
// Import the EventKit-like API with types
import eventkit, { Calendar, CalendarData, EntityType } from 'eventkit-node';

async function entityTypeExamples() {
  try {
    // Request access to both calendars and reminders
    const calendarAccess: boolean = await eventkit.requestFullAccessToEvents();
    const reminderAccess: boolean = await eventkit.requestFullAccessToReminders();
    
    if (calendarAccess && reminderAccess) {
      // Create an event calendar
      const eventCalendarData: CalendarData = {
        title: 'My Event Calendar',
        entityType: 'event', // Explicitly set entity type to 'event'
        color: { hex: '#4CAF50FF' } // Green
      };
      
      // Create a reminder list
      const reminderListData: CalendarData = {
        title: 'My Reminder List',
        entityType: 'reminder', // Explicitly set entity type to 'reminder'
        color: { hex: '#2196F3FF' } // Blue
      };
      
      // Save both calendars
      const eventCalendarId: string = await eventkit.saveCalendar(eventCalendarData, true);
      const reminderListId: string = await eventkit.saveCalendar(reminderListData, true);
      
      console.log(`Created event calendar with ID: ${eventCalendarId}`);
      console.log(`Created reminder list with ID: ${reminderListId}`);
      
      // Get all event calendars
      const eventCalendars: Calendar[] = eventkit.getCalendars('event');
      console.log(`Found ${eventCalendars.length} event calendars`);
      
      // Get all reminder lists
      const reminderLists: Calendar[] = eventkit.getCalendars('reminder');
      console.log(`Found ${reminderLists.length} reminder lists`);
      
      // Demonstrate filtering calendars by entity type
      const allCalendars: Calendar[] = [
        ...eventkit.getCalendars('event'),
        ...eventkit.getCalendars('reminder')
      ];
      
      // Filter event calendars
      const filteredEvents = allCalendars.filter(calendar => 
        // In a real app, you would determine this from the calendar properties
        // This is just for demonstration purposes
        eventkit.getCalendars('event').some(c => c.id === calendar.id)
      );
      
      console.log(`Filtered ${filteredEvents.length} event calendars`);
      
      // Filter reminder lists
      const filteredReminders = allCalendars.filter(calendar => 
        // In a real app, you would determine this from the calendar properties
        // This is just for demonstration purposes
        eventkit.getCalendars('reminder').some(c => c.id === calendar.id)
      );
      
      console.log(`Filtered ${filteredReminders.length} reminder lists`);
    }
  } catch (error) {
    console.error('Error in entity type examples:', error);
  }
}

entityTypeExamples();
```

### Error Handling

```typescript
// Import the simplified API with types
import { simple, Calendar, CalendarData, CalendarType, ColorSpace } from 'eventkit-node';
const { requestCalendarAccess, createCalendar, updateCalendar, getCalendar } = simple;

async function errorHandlingExamples() {
  try {
    // Request calendar access
    const granted: boolean = await requestCalendarAccess();
    
    if (!granted) {
      console.error('Calendar access denied by user');
      return;
    }
    
    try {
      // Try to create a calendar with invalid data (missing required title)
      const invalidCalendarData = {
        entityType: 'event',
        color: { hex: '#FF0000FF' }
      } as CalendarData; // Type assertion to bypass TypeScript checks for demo
      
      await createCalendar(invalidCalendarData);
    } catch (error) {
      console.error('Error creating calendar with invalid data:', error);
      // In a real app, you would handle this error appropriately
    }
    
    // Create a valid calendar
    const validCalendarData: CalendarData = {
      title: 'Valid Calendar',
      entityType: 'event',
      color: { hex: '#FF0000FF' }
    };
    
    const calendarId = await createCalendar(validCalendarData);
    console.log(`Created calendar with ID: ${calendarId}`);
    
    try {
      // Try to update a non-existent calendar
      const nonExistentCalendar = {
        id: 'non-existent-id',
        title: 'Non-existent Calendar',
        allowsContentModifications: true,
        type: 'local' as CalendarType,
        color: {
          hex: '#FF0000FF',
          components: '1.000000,0.000000,0.000000,1.000000',
          space: 'rgb' as ColorSpace
        },
        source: 'Local'
      } as Calendar;
      
      await updateCalendar(nonExistentCalendar);
    } catch (error) {
      console.error('Error updating non-existent calendar:', error);
      // In a real app, you would handle this error appropriately
    }
    
    try {
      // Try to get a non-existent calendar
      const nonExistentCalendar = getCalendar('non-existent-id');
      
      if (nonExistentCalendar === null) {
        console.log('Calendar not found, as expected');
      }
    } catch (error) {
      console.error('Unexpected error getting non-existent calendar:', error);
    }
  } catch (error) {
    console.error('Top-level error:', error);
  }
}

errorHandlingExamples();
```

## Complete Application Example

```typescript
// Import both APIs with types
import eventkit, { Calendar, CalendarData } from 'eventkit-node';
import { simple } from 'eventkit-node';
const { requestCalendarAccess, getCalendars, createCalendar, updateCalendar, getCalendar } = simple;

/**
 * A complete application example demonstrating the EventKit Node.js addon
 */
async function calendarManagerApp() {
  try {
    console.log('Calendar Manager Application');
    console.log('---------------------------');
    
    // Step 1: Request access to calendars
    console.log('Requesting calendar access...');
    const granted: boolean = await requestCalendarAccess();
    
    if (!granted) {
      console.error('Calendar access denied. Please grant access in System Preferences.');
      return;
    }
    
    console.log('Calendar access granted!');
    
    // Step 2: List existing calendars
    const existingCalendars: Calendar[] = getCalendars();
    console.log(`\nFound ${existingCalendars.length} existing calendars:`);
    
    existingCalendars.forEach((calendar, index) => {
      console.log(`${index + 1}. ${calendar.title} (${calendar.id})`);
      console.log(`   Type: ${calendar.type}, Source: ${calendar.source}`);
      console.log(`   Color: ${calendar.color.hex}`);
      console.log(`   Allows modifications: ${calendar.allowsContentModifications}`);
    });
    
    // Step 3: Create a new calendar
    console.log('\nCreating a new calendar...');
    
    const newCalendarData: CalendarData = {
      title: 'EventKit Node.js Demo',
      entityType: 'event',
      color: { hex: '#E91E63FF' } // Pink
    };
    
    const newCalendarId: string = await createCalendar(newCalendarData);
    console.log(`Calendar created with ID: ${newCalendarId}`);
    
    // Step 4: Retrieve the newly created calendar
    const newCalendar: Calendar | null = getCalendar(newCalendarId);
    
    if (!newCalendar) {
      console.error('Failed to retrieve the newly created calendar.');
      return;
    }
    
    console.log('\nNew calendar details:');
    console.log(`Title: ${newCalendar.title}`);
    console.log(`ID: ${newCalendar.id}`);
    console.log(`Type: ${newCalendar.type}`);
    console.log(`Color: ${newCalendar.color.hex}`);
    
    // Step 5: Update the calendar
    console.log('\nUpdating the calendar...');
    
    newCalendar.title = 'EventKit Node.js Demo (Updated)';
    
    const updatedCalendarId: string = await updateCalendar(newCalendar);
    console.log(`Calendar updated with ID: ${updatedCalendarId}`);
    
    // Step 6: Verify the update
    const updatedCalendar: Calendar | null = getCalendar(updatedCalendarId);
    
    if (!updatedCalendar) {
      console.error('Failed to retrieve the updated calendar.');
      return;
    }
    
    console.log('\nUpdated calendar details:');
    console.log(`Title: ${updatedCalendar.title}`);
    console.log(`ID: ${updatedCalendar.id}`);
    
    // Step 7: List all calendars again to confirm changes
    const finalCalendars: Calendar[] = getCalendars();
    console.log(`\nFound ${finalCalendars.length} calendars after changes:`);
    
    finalCalendars.forEach((calendar, index) => {
      console.log(`${index + 1}. ${calendar.title} (${calendar.id})`);
    });
    
    console.log('\nCalendar Manager Application completed successfully!');
  } catch (error) {
    console.error('An error occurred in the Calendar Manager Application:', error);
  }
}

// Run the application
calendarManagerApp(); 