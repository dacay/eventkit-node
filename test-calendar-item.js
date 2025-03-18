// Test script to debug getCalendarItem issues
const { getCalendars, createEventPredicate, getEventsWithPredicate, getEvent, getCalendarItem } = require('./dist');

// Get all event calendars
const calendars = getCalendars('event');
console.log(`Found ${calendars.length} event calendars`);

// Create a predicate for recent events (last 30 days to next 30 days)
const startDate = new Date();
startDate.setDate(startDate.getDate() - 30);
const endDate = new Date();
endDate.setDate(endDate.getDate() + 30);
const predicate = createEventPredicate(startDate, endDate);

// Get events using the predicate
const events = getEventsWithPredicate(predicate);
console.log(`Found ${events.length} total events`);

// Test first 5 events with both getEvent and getCalendarItem
const MAX_EVENTS = Math.min(5, events.length);
console.log(`Testing first ${MAX_EVENTS} events:`);

for (let i = 0; i < MAX_EVENTS; i++) {
  const event = events[i];
  console.log(`\nEvent #${i+1}: "${event.title}" (ID: ${event.id})`);
  
  // Try to get event with getEvent
  const eventResult = getEvent(event.id);
  console.log(`getEvent result: ${eventResult ? 'FOUND ✓' : 'NOT FOUND ✗'}`);
  
  // Try to get event with getCalendarItem
  const calendarItemResult = getCalendarItem(event.id);
  console.log(`getCalendarItem result: ${calendarItemResult ? 'FOUND ✓' : 'NOT FOUND ✗'}`);
  
  // Check if it's a recurring event
  if (eventResult) {
    console.log(`Event details:
    - Calendar: ${eventResult.calendarTitle}
    - Start: ${eventResult.startDate.toISOString()}
    - End: ${eventResult.endDate.toISOString()}
    - All Day: ${eventResult.isAllDay}
    - Location: ${eventResult.location || 'None'}`);
  }
}
