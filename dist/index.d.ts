/**
 * Entity type for calendars
 */
export type EntityType = 'event' | 'reminder';
/**
 * Request access to the calendar
 * @returns A promise that resolves to true if access was granted, false otherwise
 */
export declare function requestCalendarAccess(): Promise<boolean>;
/**
 * Get calendars for the specified entity type
 * @param entityType - The entity type ('event' or 'reminder')
 * @returns An array of calendar titles
 * @throws Error if an invalid entity type is provided
 */
export declare function getCalendars(entityType?: EntityType): string[];
declare const eventkit: {
    requestCalendarAccess: typeof requestCalendarAccess;
    getCalendars: typeof getCalendars;
};
export default eventkit;
