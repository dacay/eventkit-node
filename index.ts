/**
 * Entity type for calendars
 */
export type EntityType = 'event' | 'reminder';

/**
 * Calendar type
 */
export type CalendarType = 'local' | 'calDAV' | 'exchange' | 'subscription' | 'birthday' | 'unknown';

/**
 * Color space
 */
export type ColorSpace = 'rgb' | 'monochrome' | 'cmyk' | 'lab' | 'deviceN' | 'indexed' | 'pattern' | 'unknown';

/**
 * Color representation with multiple formats to prevent data loss
 */
export interface CalendarColor {
  /** Hex color code with alpha (#RRGGBBAA) */
  hex: string;
  /** Raw color components as comma-separated values */
  components: string;
  /** Color space of the original color */
  space: ColorSpace;
}

/**
 * Calendar object representing an EKCalendar
 * @see https://developer.apple.com/documentation/eventkit/ekcalendar
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
  /** Color of the calendar with multiple representations */
  color: CalendarColor;
  /** Source of the calendar (e.g., iCloud, Google) */
  source: string;
}

/**
 * Type alias for a reminder list
 * Represents a calendar that contains reminders
 * @see https://developer.apple.com/documentation/eventkit/ekcalendar
 */
export type ReminderList = Calendar;

// Import the native module using a path that will work when imported from dist
const path = require('path');
const nativeModule = require(path.join(__dirname, '../build/Release/eventkit'));

/**
 * Request full access to calendar events
 * Similar to EKEventStore.requestFullAccessToEvents in EventKit
 * @returns A promise that resolves to true if access was granted, false otherwise
 */
export function requestFullAccessToEvents(): Promise<boolean> {
  return nativeModule.requestCalendarAccess();
}

/**
 * Request full access to reminders
 * Similar to EKEventStore.requestFullAccessToReminders in EventKit
 * @returns A promise that resolves to true if access was granted, false otherwise
 */
export function requestFullAccessToReminders(): Promise<boolean> {
  return nativeModule.requestRemindersAccess();
}

// For simplified API only - not exported at the top level
const requestCalendarAccess = requestFullAccessToEvents;
const requestRemindersAccess = requestFullAccessToReminders;

/**
 * Get calendars for the specified entity type
 * Similar to EKEventStore.calendars(for:) in EventKit
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
  requestFullAccessToEvents,
  requestFullAccessToReminders,
  getCalendars
};

// Export as default for ES modules
export default eventkit;

/**
 * Simplified API module
 * Provides more intuitive function names for common operations
 */
export const simple = {
  /**
   * Get event calendars
   * @returns An array of Calendar objects representing event calendars
   */
  getCalendars(): Calendar[] {
    // Explicitly call the root getCalendars function to avoid recursion
    return eventkit.getCalendars('event');
  },

  /**
   * Get reminder lists
   * @returns An array of Calendar objects representing reminder lists
   */
  getReminderLists(): ReminderList[] {
    return eventkit.getCalendars('reminder');
  },

  /**
   * Request access to calendar events
   * @returns A promise that resolves to true if access was granted, false otherwise
   */
  requestCalendarAccess,

  /**
   * Request access to reminders
   * @returns A promise that resolves to true if access was granted, false otherwise
   */
  requestRemindersAccess
}; 