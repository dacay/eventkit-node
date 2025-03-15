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

/**
 * Request full access to calendar events
 * Similar to EKEventStore.requestFullAccessToEvents in EventKit
 * @returns A promise that resolves to true if access was granted, false otherwise
 */
export function requestFullAccessToEvents(): Promise<boolean>;

/**
 * Request full access to reminders
 * Similar to EKEventStore.requestFullAccessToReminders in EventKit
 * @returns A promise that resolves to true if access was granted, false otherwise
 */
export function requestFullAccessToReminders(): Promise<boolean>;

/**
 * Get calendars for the specified entity type
 * Similar to EKEventStore.calendars(for:) in EventKit
 * @param entityType - The entity type ('event' or 'reminder')
 * @returns An array of Calendar objects
 */
export function getCalendars(entityType?: EntityType): Calendar[];

/**
 * Get a calendar with the specified identifier
 * Similar to EKEventStore.calendar(withIdentifier:) in EventKit
 * @param identifier - The unique identifier of the calendar to retrieve
 * @returns The calendar with the specified identifier, or null if not found
 */
export function getCalendar(identifier: string): Calendar | null;

/**
 * Simplified API interface
 */
export interface SimpleAPI {
  /**
   * Get event calendars
   * @returns An array of Calendar objects representing event calendars
   */
  getCalendars(): Calendar[];
  
  /**
   * Get reminder lists
   * @returns An array of Calendar objects representing reminder lists
   */
  getReminderLists(): ReminderList[];
  
  /**
   * Get a calendar by its identifier
   * @param identifier - The unique identifier of the calendar to retrieve
   * @returns The calendar with the specified identifier, or null if not found
   */
  getCalendar(identifier: string): Calendar | null;
  
  /**
   * Request access to calendar events
   * @returns A promise that resolves to true if access was granted, false otherwise
   */
  requestCalendarAccess(): Promise<boolean>;
  
  /**
   * Request access to reminders
   * @returns A promise that resolves to true if access was granted, false otherwise
   */
  requestRemindersAccess(): Promise<boolean>;
}

/**
 * Simplified API module
 * Provides more intuitive function names for common operations
 */
export const simple: SimpleAPI;

/**
 * EventKit interface for the default export
 */
export interface EventKit {
  requestFullAccessToEvents(): Promise<boolean>;
  requestFullAccessToReminders(): Promise<boolean>;
  getCalendars(entityType?: EntityType): Calendar[];
  getCalendar(identifier: string): Calendar | null;
}

/**
 * Default export for ES modules
 */
declare const eventkit: EventKit;
export default eventkit; 