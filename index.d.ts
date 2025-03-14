/**
 * Entity type for calendars
 */
export type EntityType = 'event' | 'reminder';

/**
 * Calendar type
 */
export type CalendarType = 'local' | 'calDAV' | 'exchange' | 'subscription' | 'birthday' | 'unknown';

/**
 * Source type
 */
export type SourceType = 'local' | 'exchange' | 'calDAV' | 'mobileme' | 'subscribed' | 'birthdays' | 'unknown';

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
 * Source object representing an EKSource
 * @see https://developer.apple.com/documentation/eventkit/eksource
 */
export interface Source {
  /** Unique identifier for the source */
  id: string;
  /** Display name of the source */
  title: string;
  /** Type of the source (local, calDAV, etc.) */
  sourceType: SourceType;
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
  /** Entity types this calendar supports (events, reminders, or both) */
  allowedEntityTypes: EntityType[];
}

/**
 * Data for creating or updating a calendar
 */
export interface CalendarData {
  /** Unique identifier for the calendar (omit for new calendars) */
  id?: string;
  /** Display name of the calendar */
  title: string;
  /** Source identifier for the calendar (optional, system will use default if not provided) */
  sourceId?: string;
  /** Entity type for the calendar (event or reminder) */
  entityType: EntityType;
  /** Color for the calendar */
  color?: {
    /** Hex color code with alpha (#RRGGBBAA) or without alpha (#RRGGBB) */
    hex: string;
  };
}

/**
 * Get calendars for a specific entity type
 * @param entityType - The entity type to get calendars for (event or reminder)
 * @returns An array of Calendar objects
 */
export function getCalendars(entityType?: EntityType): Calendar[];

/**
 * Get a calendar by its identifier
 * @param identifier - The unique identifier of the calendar to retrieve
 * @returns The calendar with the specified identifier, or null if not found
 */
export function getCalendar(identifier: string): Calendar | null;

/**
 * Request full access to calendar events
 * @returns A promise that resolves to true if access was granted, false otherwise
 * @note On macOS 14.0+, uses requestFullAccessToEvents. On older versions, falls back to requestAccess(to: .event)
 */
export function requestFullAccessToEvents(): Promise<boolean>;

/**
 * Request write-only access to calendar events
 * @returns A promise that resolves to true if access was granted, false otherwise
 * @note On macOS 14.0+, uses requestWriteOnlyAccessToEvents. On older versions, falls back to requestAccess(to: .event)
 * @note Write-only access allows creating and modifying events but not reading them
 */
export function requestWriteOnlyAccessToEvents(): Promise<boolean>;

/**
 * Request full access to reminders
 * @returns A promise that resolves to true if access was granted, false otherwise
 * @note On macOS 14.0+, uses requestFullAccessToReminders. On older versions, falls back to requestAccess(to: .reminder)
 */
export function requestFullAccessToReminders(): Promise<boolean>;

/**
 * Commit all pending changes to the event store
 * @returns A promise that resolves when the commit is successful
 * @throws Error if the commit fails with details about the failure
 * @note This is only needed if you've created or modified calendars with commit=false
 */
export function commit(): Promise<void>;

/**
 * Reset the event store by discarding all unsaved changes
 */
export function reset(): void;

/**
 * Refresh the sources in the event store if necessary
 * @note This can be useful if external changes have been made to the calendar database
 */
export function refreshSourcesIfNecessary(): void;

/**
 * Save a calendar (create new or update existing)
 * @param calendarData - The calendar data to save
 * @param commit - Whether to commit the changes immediately (default: true)
 * @returns A promise that resolves to the calendar identifier if successful
 * @throws Error if the calendar data is invalid or the operation fails
 * 
 * @example
 * // Create a new calendar
 * const newCalendarId = await saveCalendar({
 *   title: 'My Calendar',
 *   entityType: 'event',
 *   color: { hex: '#FF0000FF' }
 * });
 * 
 * @example
 * // Update an existing calendar
 * const calendar = getCalendar('calendar-id');
 * if (calendar) {
 *   const updatedCalendarId = await saveCalendar({
 *     id: calendar.id,
 *     title: 'Updated Title',
 *     entityType: 'event',
 *     color: { hex: calendar.color.hex }
 *   });
 * }
 */
export function saveCalendar(calendarData: CalendarData, commit?: boolean): Promise<string>;

/**
 * Get all sources
 * @returns An array of Source objects
 */
export function getSources(): Source[];

/**
 * Get delegate sources
 * @returns An array of Source objects
 * @note This method is only available on macOS 12.0 and later. On older versions, it returns an empty array.
 */
export function getDelegateSources(): Source[];

/**
 * Get a source with the specified identifier
 * @param sourceId - The unique identifier of the source to retrieve
 * @returns The source with the specified identifier, or null if not found
 */
export function getSource(sourceId: string): Source | null;

/**
 * Remove a calendar with the specified identifier
 * @param calendarId - The unique identifier of the calendar to remove
 * @param commit - Whether to commit the changes immediately (default: true)
 * @returns A promise that resolves to true if the calendar was successfully removed
 * @throws Error if the calendar does not exist or the operation fails
 * 
 * @example
 * // Remove a calendar
 * try {
 *   await removeCalendar('calendar-id');
 *   console.log('Calendar removed successfully');
 * } catch (error) {
 *   console.error('Failed to remove calendar:', error);
 * }
 */
export function removeCalendar(calendarId: string, commit?: boolean): Promise<boolean>;

/**
 * Get the default calendar for new events
 * @returns The default calendar for new events, or null if not set
 * 
 * @example
 * const defaultCalendar = getDefaultCalendarForNewEvents();
 * if (defaultCalendar) {
 *   console.log(`Default calendar for events: ${defaultCalendar.title}`);
 * } else {
 *   console.log('No default calendar for events is set');
 * }
 */
export function getDefaultCalendarForNewEvents(): Calendar | null;

/**
 * Get the default calendar for new reminders
 * @returns The default calendar for new reminders, or null if not set
 * 
 * @example
 * const defaultCalendar = getDefaultCalendarForNewReminders();
 * if (defaultCalendar) {
 *   console.log(`Default calendar for reminders: ${defaultCalendar.title}`);
 * } else {
 *   console.log('No default calendar for reminders is set');
 * }
 */
export function getDefaultCalendarForNewReminders(): Calendar | null; 