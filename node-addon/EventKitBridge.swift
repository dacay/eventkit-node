//
//  EventKitBridge.swift
//  eventkit-addon
//
//  Created by Deniz Acay on 8.03.2025.
//

import EventKit
import Foundation

@objc public class EventKitBridge: NSObject {
    private let eventStore = EKEventStore()

    @objc public func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { granted, error in
            completion(granted)
        }
    }

    @objc public func getCalendars() -> [String] {
        let calendars = eventStore.calendars(for: .event)
        return calendars.map { $0.title }
    }

    @objc public func getEvents(startDate: Date, endDate: Date) -> [String] {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)
        return events.map { $0.title ?? "Untitled Event" }
    }
} 