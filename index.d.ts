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