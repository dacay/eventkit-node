/**
 * Entity type for calendars
 */
export type EntityType = 'event' | 'reminder';

// Import the native module using a path that will work when imported from dist
const path = require('path');
const nativeModule = require(path.join(__dirname, '../build/Release/eventkit'));

/**
 * Request access to the calendar
 * @returns A promise that resolves to true if access was granted, false otherwise
 */
export function requestCalendarAccess(): Promise<boolean> {
  return nativeModule.requestCalendarAccess();
}

/**
 * Get calendars for the specified entity type
 * @param entityType - The entity type ('event' or 'reminder')
 * @returns An array of calendar titles
 * @throws Error if an invalid entity type is provided
 */
export function getCalendars(entityType: EntityType = 'event'): string[] {
  // TypeScript will enforce that entityType is either 'event' or 'reminder'
  // due to the type definition, but we'll normalize it anyway
  const normalizedType = entityType.toLowerCase() as EntityType;
  
  return nativeModule.getCalendars(normalizedType);
}

// Create a default export object for ES modules compatibility
const eventkit = {
  requestCalendarAccess,
  getCalendars
};

// Export as default for ES modules
export default eventkit; 