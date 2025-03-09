/**
 * Entity type for calendars
 */
export type EntityType = 'event' | 'reminder';

/**
 * Request access to the calendar
 * @returns A promise that resolves to true if access was granted, false otherwise
 */
export function requestCalendarAccess(): Promise<boolean>;

/**
 * Get calendars for the specified entity type
 * @param entityType - The entity type ('event' or 'reminder')
 * @returns An array of calendar titles
 */
export function getCalendars(entityType?: EntityType): string[];

/**
 * EventKit interface for the default export
 */
export interface EventKit {
  requestCalendarAccess(): Promise<boolean>;
  getCalendars(entityType?: EntityType): string[];
}

/**
 * Default export for ES modules
 */
declare const eventkit: EventKit;
export default eventkit; 