// Test script for external identifier support
const { getCalendars, createEventPredicate, getEventsWithPredicate, getCalendarItemsWithExternalIdentifier } = require('./dist');

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

// Test first 5 events for external identifiers
const MAX_EVENTS = Math.min(5, events.length);
console.log(`Testing first ${MAX_EVENTS} events for external identifiers:`);

const externalIds = new Set();

for (let i = 0; i < MAX_EVENTS; i++) {
  const event = events[i];
  console.log(`\nEvent #${i+1}: "${event.title}" (ID: ${event.id})`);
  
  // Log external identifier
  console.log(`- External Identifier: ${event.externalIdentifier || 'Not available'}`);
  
  // If external identifier exists, add it to our set
  if (event.externalIdentifier) {
    externalIds.add(event.externalIdentifier);
  }
}

// Test getCalendarItemsWithExternalIdentifier for each unique external ID
console.log('\n--- Testing getCalendarItemsWithExternalIdentifier ---');

if (externalIds.size === 0) {
  console.log('No external identifiers found in the test events');
} else {
  console.log(`Found ${externalIds.size} unique external identifiers`);
  
  externalIds.forEach(externalId => {
    console.log(`\nLooking up items with external ID: ${externalId}`);
    
    const items = getCalendarItemsWithExternalIdentifier(externalId);
    
    if (items && items.length > 0) {
      console.log(`Found ${items.length} items:`);
      
      items.forEach((result, index) => {
        console.log(`Item #${index + 1}:`);
        console.log(`- Type: ${result.type}`);
        console.log(`- Title: ${result.item.title}`);
        console.log(`- ID: ${result.item.id}`);
      });
    } else {
      console.log('No items found with this external identifier');
    }
  });
} 