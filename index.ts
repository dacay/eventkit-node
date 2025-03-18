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
 * Event object representing an EKEvent
 * @see https://developer.apple.com/documentation/eventkit/ekevent
 */
export interface Event {
  /** Unique identifier for the event */
  id: string;
  /** Title of the event */
  title: string;
  /** Notes or description of the event */
  notes: string | null;
  /** Start date of the event */
  startDate: Date;
  /** End date of the event */
  endDate: Date;
  /** Whether the event is an all-day event */
  isAllDay: boolean;
  /** Calendar identifier the event belongs to */
  calendarId: string;
  /** Calendar title the event belongs to */
  calendarTitle: string;
  /** Location of the event */
  location: string | null;
  /** URL associated with the event */
  url: string | null;
  /** Whether the event has alarms */
  hasAlarms: boolean;
  /** Availability during the event (free, busy, tentative, unavailable) */
  availability: 'free' | 'busy' | 'tentative' | 'unavailable' | 'unknown';
}

/**
 * Reminder object representing an EKReminder
 * @see https://developer.apple.com/documentation/eventkit/ekreminder
 */
export interface Reminder {
  /** Unique identifier for the reminder */
  id: string;
  /** Title of the reminder */
  title: string;
  /** Notes or description of the reminder */
  notes: string | null;
  /** Calendar identifier the reminder belongs to */
  calendarId: string;
  /** Calendar title the reminder belongs to */
  calendarTitle: string;
  /** Whether the reminder is completed */
  completed: boolean;
  /** Date when the reminder was completed */
  completionDate: Date | null;
  /** Due date of the reminder */
  dueDate: Date | null;
  /** Start date of the reminder */
  startDate: Date | null;
  /** Priority of the reminder (0-9, where 0 is no priority) */
  priority: number;
  /** Whether the reminder has alarms */
  hasAlarms: boolean;
}

/**
 * Predicate type for querying events and reminders
 */
export type PredicateType = 'event' | 'reminder' | 'incompleteReminder' | 'completedReminder';

/**
 * Predicate object for querying events and reminders
 */
export interface Predicate {
  /** Type of the predicate */
  type: PredicateType;
  /** Native handle for the predicate (internal use only) */
  _nativeHandle?: any;
}

// Import the native module using a path that will work when imported from dist
const path = require('path');
const nativeModule = require(path.join(__dirname, '../build/Release/eventkit'));

/**
 * Get calendars for a specific entity type
 * @param entityType - The entity type to get calendars for (event or reminder)
 * @returns An array of Calendar objects
 */
export function getCalendars(entityType: EntityType = 'event'): Calendar[] {
  return nativeModule.getCalendars(entityType);
}

/**
 * Get a calendar by its identifier
 * @param identifier - The unique identifier of the calendar to retrieve
 * @returns The calendar with the specified identifier, or null if not found
 */
export function getCalendar(identifier: string): Calendar | null {
  return nativeModule.getCalendar(identifier);
}

/**
 * Request full access to calendar events
 * @returns A promise that resolves to true if access was granted, false otherwise
 * @note On macOS 14.0+, uses requestFullAccessToEvents. On older versions, falls back to requestAccess(to: .event)
 */
export function requestFullAccessToEvents(): Promise<boolean> {
  return nativeModule.requestCalendarAccess();
}

/**
 * Request write-only access to calendar events
 * @returns A promise that resolves to true if access was granted, false otherwise
 * @note On macOS 14.0+, uses requestWriteOnlyAccessToEvents. On older versions, falls back to requestAccess(to: .event)
 * @note Write-only access allows creating and modifying events but not reading them
 */
export function requestWriteOnlyAccessToEvents(): Promise<boolean> {
  return nativeModule.requestWriteOnlyAccessToEvents();
}

/**
 * Request full access to reminders
 * @returns A promise that resolves to true if access was granted, false otherwise
 * @note On macOS 14.0+, uses requestFullAccessToReminders. On older versions, falls back to requestAccess(to: .reminder)
 */
export function requestFullAccessToReminders(): Promise<boolean> {
  return nativeModule.requestRemindersAccess();
}

/**
 * Commit all pending changes to the event store
 * @returns A promise that resolves when the commit is successful
 * @throws Error if the commit fails with details about the failure
 * @note This is only needed if you've created or modified calendars with commit=false
 */
export function commit(): Promise<void> {
  return nativeModule.commit().then(() => {
    // Return void on success
    return;
  });
}

/**
 * Reset the event store by discarding all unsaved changes
 */
export function reset(): void {
  nativeModule.reset();
}

/**
 * Refresh the sources in the event store if necessary
 * @note This can be useful if external changes have been made to the calendar database
 */
export function refreshSourcesIfNecessary(): void {
  nativeModule.refreshSourcesIfNecessary();
}

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
export function saveCalendar(calendarData: CalendarData, commit: boolean = true): Promise<string> {
  // Validate entity type
  if (!calendarData.entityType || !['event', 'reminder'].includes(calendarData.entityType)) {
    throw new Error('Invalid entity type. Must be "event" or "reminder".');
  }
  
  return nativeModule.saveCalendar(calendarData, commit);
}

/**
 * Get all sources
 * @returns An array of Source objects
 */
export function getSources(): Source[] {
  return nativeModule.getSources();
}

/**
 * Get delegate sources
 * @returns An array of Source objects
 * @note This method is only available on macOS 12.0 and later. On older versions, it returns an empty array.
 */
export function getDelegateSources(): Source[] {
  return nativeModule.getDelegateSources();
}

/**
 * Get a source with the specified identifier
 * @param sourceId - The unique identifier of the source to retrieve
 * @returns The source with the specified identifier, or null if not found
 */
export function getSource(sourceId: string): Source | null {
  return nativeModule.getSource(sourceId);
}

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
export function removeCalendar(calendarId: string, commit: boolean = true): Promise<boolean> {
  if (!calendarId) {
    throw new Error('Calendar ID is required.');
  }
  
  return nativeModule.removeCalendar(calendarId, commit);
}

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
export function getDefaultCalendarForNewEvents(): Calendar | null {
  return nativeModule.getDefaultCalendarForNewEvents();
}

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
export function getDefaultCalendarForNewReminders(): Calendar | null {
  return nativeModule.getDefaultCalendarForNewReminders();
}

/**
 * Create a predicate for querying events within a specific date range
 * @param startDate - The start date of the range
 * @param endDate - The end date of the range
 * @param calendarIds - Optional array of calendar IDs to filter by
 * @returns A predicate that can be used with getEventsWithPredicate
 * 
 * @example
 * // Get events for the next week
 * const startDate = new Date();
 * const endDate = new Date();
 * endDate.setDate(endDate.getDate() + 7);
 * const predicate = createEventPredicate(startDate, endDate);
 * const events = await getEventsWithPredicate(predicate);
 */
export function createEventPredicate(startDate: Date, endDate: Date, calendarIds?: string[]): Predicate {
  return nativeModule.createEventPredicate(startDate, endDate, calendarIds);
}

/**
 * Create a predicate for querying reminders in specific calendars
 * @param calendarIds - Optional array of calendar IDs to filter by
 * @returns A predicate that can be used with getRemindersWithPredicate
 * 
 * @example
 * // Get all reminders
 * const predicate = createReminderPredicate();
 * const reminders = await getRemindersWithPredicate(predicate);
 */
export function createReminderPredicate(calendarIds?: string[]): Predicate {
  return nativeModule.createReminderPredicate(calendarIds);
}

/**
 * Create a predicate for querying incomplete reminders with due dates in a specific range
 * @param startDate - Optional start date of the range
 * @param endDate - Optional end date of the range
 * @param calendarIds - Optional array of calendar IDs to filter by
 * @returns A predicate that can be used with getRemindersWithPredicate
 * 
 * @example
 * // Get incomplete reminders due in the next week
 * const startDate = new Date();
 * const endDate = new Date();
 * endDate.setDate(endDate.getDate() + 7);
 * const predicate = createIncompleteReminderPredicate(startDate, endDate);
 * const reminders = await getRemindersWithPredicate(predicate);
 */
export function createIncompleteReminderPredicate(startDate?: Date, endDate?: Date, calendarIds?: string[]): Predicate {
  return nativeModule.createIncompleteReminderPredicate(startDate, endDate, calendarIds);
}

/**
 * Create a predicate for querying completed reminders with completion dates in a specific range
 * @param startDate - Optional start date of the range
 * @param endDate - Optional end date of the range
 * @param calendarIds - Optional array of calendar IDs to filter by
 * @returns A predicate that can be used with getRemindersWithPredicate
 * 
 * @example
 * // Get reminders completed in the last week
 * const endDate = new Date();
 * const startDate = new Date();
 * startDate.setDate(startDate.getDate() - 7);
 * const predicate = createCompletedReminderPredicate(startDate, endDate);
 * const reminders = await getRemindersWithPredicate(predicate);
 */
export function createCompletedReminderPredicate(startDate?: Date, endDate?: Date, calendarIds?: string[]): Predicate {
  return nativeModule.createCompletedReminderPredicate(startDate, endDate, calendarIds);
}

/**
 * Get events matching a predicate
 * @param predicate - The predicate to match events against
 * @returns An array of Event objects matching the predicate
 * 
 * @example
 * // Get events for the next week
 * const startDate = new Date();
 * const endDate = new Date();
 * endDate.setDate(endDate.getDate() + 7);
 * const predicate = createEventPredicate(startDate, endDate);
 * const events = getEventsWithPredicate(predicate);
 */
export function getEventsWithPredicate(predicate: Predicate): Event[] {
  if (predicate.type !== 'event') {
    throw new Error('Predicate must be an event predicate');
  }
  
  return nativeModule.getEventsWithPredicate(predicate);
}

/**
 * Get reminders matching a predicate
 * @param predicate - The predicate to match reminders against
 * @returns A promise that resolves to an array of Reminder objects matching the predicate
 * 
 * @example
 * // Get incomplete reminders
 * const predicate = createIncompleteReminderPredicate();
 * const reminders = await getRemindersWithPredicate(predicate);
 */
export function getRemindersWithPredicate(predicate: Predicate): Promise<Reminder[]> {
  // Check if the predicate type is valid for reminders
  if (predicate.type !== 'reminder' && 
      predicate.type !== 'incompleteReminder' && 
      predicate.type !== 'completedReminder') {
    throw new Error(`Invalid predicate type: ${predicate.type}. Must be 'reminder', 'incompleteReminder', or 'completedReminder'.`);
  }
  
  return nativeModule.getRemindersWithPredicate(predicate);
}

/**
 * Get an event by its identifier
 * @param identifier - The unique identifier of the event to retrieve
 * @returns The Event object if found, or null if not found
 * 
 * @example
 * // Get an event by its identifier
 * const event = getEvent('123456789');
 * if (event) {
 *   console.log(`Found event: ${event.title}`);
 * } else {
 *   console.log('Event not found');
 * }
 */
export function getEvent(identifier: string): Event | null {
  return nativeModule.getEvent(identifier);
} 