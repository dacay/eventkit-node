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

/**
 * Request access to the calendar
 * @returns A promise that resolves to true if access was granted, false otherwise
 */
export function requestCalendarAccess(): Promise<boolean>;

/**
 * Get calendars for the specified entity type
 * @param entityType - The entity type ('event' or 'reminder')
 * @returns An array of Calendar objects
 */
export function getCalendars(entityType?: EntityType): Calendar[];

/**
 * EventKit interface for the default export
 */
export interface EventKit {
  requestCalendarAccess(): Promise<boolean>;
  getCalendars(entityType?: EntityType): Calendar[];
}

/**
 * Default export for ES modules
 */
declare const eventkit: EventKit;
export default eventkit; 