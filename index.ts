/**
 * Entity type for calendars
 */
export type EntityType = 'event' | 'reminder';

/**
 * Calendar type
 */
export type CalendarType = 'local' | 'calDAV' | 'exchange' | 'subscription' | 'birthday' | 'unknown';

/**
 * Calendar object representing an EKCalendar
 */
export interface Calendar {
  /** Unique identifier for the calendar */
  id: string;
  /** Display name of the calendar */
  title: string;
  /** Whether the calendar allows content modifications */
  allowsContentModifications: boolean;
  /** Type of the calendar (local, calDAV, etc.) */
  type: CalendarType;
  /** Color of the calendar as a comma-separated RGBA string */
  color: string;
  /** Source of the calendar (e.g., iCloud, Google) */
  source: string;
}

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
 * @returns An array of Calendar objects
 * @throws Error if an invalid entity type is provided
 */
export function getCalendars(entityType: EntityType = 'event'): Calendar[] {
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