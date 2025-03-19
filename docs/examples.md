# EventKit Node.js Examples

This document provides practical examples for using the EventKit Node.js addon.

## Basic Usage

```javascript
const { 
  requestFullAccessToEvents, 
  getCalendars,
  getSources,
  saveCalendar,
  saveEvent,
  saveReminder,
  removeEvent,
  removeReminder, 
  commit, 
  reset, 
  refreshSourcesIfNecessary,
  createEventPredicate,
  getEventsWithPredicate
} = require('eventkit-node');

async function example() {
  // Request calendar access
  const granted = await requestFullAccessToEvents();
  
  if (granted) {
    // Get calendars that support events
    const eventCalendars = getCalendars('event');
    console.log('Event Calendars:', eventCalendars);
    
    // Get calendars that support reminders
    const reminderCalendars = getCalendars('reminder');
    console.log('Reminder Calendars:', reminderCalendars);
    
    try {
      // Create a new calendar for events
      // Note: A valid sourceId is required for new calendars
      const sources = getSources();
      const localSourceId = sources.find(s => s.sourceType === 'local')?.id;
      
      const newCalendarId = await saveCalendar({
        title: 'My New Calendar',
        entityType: 'event',
        sourceId: localSourceId, // Required for new calendars
        color: { hex: '#FF0000FF' }
      });
      console.log('Created new calendar with ID:', newCalendarId);
      
      // Update the calendar we just created
      const updatedCalendarId = await saveCalendar({
        id: newCalendarId,
        title: 'My Updated Calendar',
        entityType: 'event',
        color: { hex: '#00FF00FF' }
      });
      
      // Create a calendar without committing changes immediately
      const draftCalendarId = await saveCalendar({
        title: 'Draft Calendar',
        entityType: 'event',
        sourceId: localSourceId, // Required for new calendars
        color: { hex: '#0000FFFF' }
      }, false);
      console.log('Created draft calendar with ID:', draftCalendarId);
      
      // Create a new event in the calendar we just created
      const now = new Date();
      const oneHourLater = new Date(now.getTime() + 60 * 60 * 1000);
      
      const eventId = await saveEvent({
        title: 'Team Meeting',
        calendarId: newCalendarId, // Required for new events
        startDate: now,
        endDate: oneHourLater,
        location: 'Conference Room A',
        notes: 'Discuss project progress',
        isAllDay: false
      });
      console.log('Created new event with ID:', eventId);
      
      // Create a new reminder
      const reminderCalendarId = reminderCalendars[0]?.id;
      if (reminderCalendarId) {
        const reminderId = await saveReminder({
          title: 'Buy groceries',
          calendarId: reminderCalendarId, // Required for new reminders
          dueDate: new Date(now.getTime() + 24 * 60 * 60 * 1000), // Tomorrow
          notes: 'Milk, bread, eggs',
          priority: 5
        });
        console.log('Created new reminder with ID:', reminderId);
        
        // Remove the reminder
        const reminderRemoved = await removeReminder(reminderId);
        console.log('Reminder removed:', reminderRemoved);
      }
      
      // Remove the event we created
      const eventRemoved = await removeEvent(eventId);
      console.log('Event removed:', eventRemoved);
      
      // Commit the changes manually
      try {
        await commit();
        console.log('Changes committed successfully');
      } catch (error) {
        console.error('Failed to commit changes:', error);
        // Reset the event store to discard unsaved changes
        reset();
      }
      
      // Refresh sources if necessary (e.g., after external changes)
      refreshSourcesIfNecessary();
      
      // Query events using predicates
      const startDate = new Date();
      const endDate = new Date();
      endDate.setDate(endDate.getDate() + 7); // One week from now
      
      // Create a predicate for events in the next week
      const eventPredicate = createEventPredicate(startDate, endDate);
      
      // Get events matching the predicate
      const events = getEventsWithPredicate(eventPredicate);
      console.log('Events in the next week:', events);
      
    } catch (error) {
      console.error('Operation failed:', error);
    }
  }
}

example();
```

## Querying Events and Reminders

EventKit Node.js provides a two-step approach for querying events and reminders, following the EventKit API design:

1. Create a predicate using one of the predicate creation methods
2. Query events or reminders using the predicate

```javascript
const { 
  createEventPredicate, 
  createReminderPredicate,
  createIncompleteReminderPredicate,
  createCompletedReminderPredicate,
  getEventsWithPredicate,
  getRemindersWithPredicate
} = require('eventkit-node');

async function queryExample() {
  // Query events for the next week
  const startDate = new Date();
  const endDate = new Date();
  endDate.setDate(endDate.getDate() + 7);
  
  // Step 1: Create a predicate
  const eventPredicate = createEventPredicate(startDate, endDate);
  
  // Step 2: Query events using the predicate
  const events = getEventsWithPredicate(eventPredicate);
  console.log('Events:', events);
  
  // Query all reminders in specific calendars
  const calendarIds = ['calendar-id-1', 'calendar-id-2'];
  const reminderPredicate = createReminderPredicate(calendarIds);
  
  // Reminder queries are asynchronous
  const reminders = await getRemindersWithPredicate(reminderPredicate);
  console.log('Reminders:', reminders);
  
  // Query incomplete reminders with due dates in the next week
  const incompletePredicate = createIncompleteReminderPredicate(startDate, endDate);
  const incompleteReminders = await getRemindersWithPredicate(incompletePredicate);
  console.log('Incomplete reminders:', incompleteReminders);
  
  // Query completed reminders from the last week
  const lastWeekStart = new Date();
  lastWeekStart.setDate(lastWeekStart.getDate() - 7);
  const completedPredicate = createCompletedReminderPredicate(lastWeekStart, new Date());
  const completedReminders = await getRemindersWithPredicate(completedPredicate);
  console.log('Completed reminders:', completedReminders);
}

queryExample();
```

## Working with Calendars

```javascript
const { 
  getSources,
  getCalendars,
  saveCalendar,
  removeCalendar
} = require('eventkit-node');

async function calendarExample() {
  // Get all available sources
  const sources = getSources();
  const localSourceId = sources.find(s => s.sourceType === 'local')?.id;
  
  if (!localSourceId) {
    console.error('No local source found');
    return;
  }
  
  try {
    // Create a new calendar
    const calendarId = await saveCalendar({
      title: 'Work Events',
      entityType: 'event',
      sourceId: localSourceId,
      color: { hex: '#4285F4FF' } // Google Blue
    });
    console.log('Created calendar with ID:', calendarId);
    
    // Get all event calendars
    const eventCalendars = getCalendars('event');
    console.log('Available event calendars:', eventCalendars.map(cal => ({
      id: cal.id,
      title: cal.title,
      source: cal.source
    })));
    
    // Remove the calendar we created
    const removed = await removeCalendar(calendarId);
    console.log('Calendar removed:', removed);
  } catch (error) {
    console.error('Calendar operation failed:', error);
  }
}

calendarExample();
```

## Working with Events

```javascript
const { 
  getCalendars,
  saveEvent,
  getEvent,
  removeEvent
} = require('eventkit-node');

async function eventExample() {
  // Get the first available event calendar
  const eventCalendars = getCalendars('event');
  if (!eventCalendars.length) {
    console.error('No event calendars available');
    return;
  }
  
  const calendarId = eventCalendars[0].id;
  
  try {
    // Create a new event
    const now = new Date();
    const tomorrow = new Date(now);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    const eventId = await saveEvent({
      title: 'Important Meeting',
      calendarId: calendarId,
      startDate: new Date(tomorrow.setHours(9, 0, 0, 0)), // Tomorrow at 9 AM
      endDate: new Date(tomorrow.setHours(10, 0, 0, 0)),  // Tomorrow at 10 AM
      location: 'Conference Room B',
      notes: 'Prepare presentation for client review',
      isAllDay: false,
      availability: 'busy'
    });
    console.log('Created event with ID:', eventId);
    
    // Get the event details
    const event = getEvent(eventId);
    console.log('Event details:', event);
    
    // Update the event
    await saveEvent({
      id: eventId,
      title: 'Client Presentation',
      notes: 'Final review of quarterly report'
    });
    console.log('Event updated');
    
    // Delete the event
    const removed = await removeEvent(eventId);
    console.log('Event removed:', removed);
  } catch (error) {
    console.error('Event operation failed:', error);
  }
}

eventExample();
```

## Working with Reminders

```javascript
const { 
  getCalendars,
  saveReminder,
  getRemindersWithPredicate,
  createReminderPredicate,
  removeReminder
} = require('eventkit-node');

async function reminderExample() {
  // Get the first available reminder calendar
  const reminderCalendars = getCalendars('reminder');
  if (!reminderCalendars.length) {
    console.error('No reminder calendars available');
    return;
  }
  
  const calendarId = reminderCalendars[0].id;
  
  try {
    // Create a new reminder
    const now = new Date();
    const nextWeek = new Date(now);
    nextWeek.setDate(nextWeek.getDate() + 7);
    
    const reminderId = await saveReminder({
      title: 'Quarterly Tax Filing',
      calendarId: calendarId,
      dueDate: nextWeek,
      notes: 'Complete Form 941 and make tax deposit',
      priority: 3, // Medium-high priority
      completed: false
    });
    console.log('Created reminder with ID:', reminderId);
    
    // Get reminders from this calendar
    const predicate = createReminderPredicate([calendarId]);
    const reminders = await getRemindersWithPredicate(predicate);
    console.log('Reminders in calendar:', reminders);
    
    // Mark the reminder as completed
    await saveReminder({
      id: reminderId,
      completed: true
    });
    console.log('Reminder marked as completed');
    
    // Delete the reminder
    const removed = await removeReminder(reminderId);
    console.log('Reminder removed:', removed);
  } catch (error) {
    console.error('Reminder operation failed:', error);
  }
}

reminderExample();
``` 