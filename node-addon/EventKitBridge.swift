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

    // Calendar object for JSON serialization
    @objc public class Calendar: NSObject {
        @objc public let id: String
        @objc public let title: String
        @objc public let allowsContentModifications: Bool
        @objc public let type: String
        @objc public let color: String
        @objc public let source: String
        
        init(from ekCalendar: EKCalendar) {
            self.id = ekCalendar.calendarIdentifier
            self.title = ekCalendar.title
            self.allowsContentModifications = ekCalendar.allowsContentModifications
            self.type = ekCalendar.type == .local ? "local" : 
                        ekCalendar.type == .calDAV ? "calDAV" : 
                        ekCalendar.type == .exchange ? "exchange" : 
                        ekCalendar.type == .subscription ? "subscription" : 
                        ekCalendar.type == .birthday ? "birthday" : "unknown"
            
            // Convert CGColor to string representation
            if let components = ekCalendar.cgColor.components, ekCalendar.cgColor.numberOfComponents >= 4 {
                let r = String(format: "%.2f", components[0])
                let g = String(format: "%.2f", components[1])
                let b = String(format: "%.2f", components[2])
                let a = String(format: "%.2f", components[3])
                self.color = "\(r),\(g),\(b),\(a)"
            } else {
                self.color = "0.00,0.00,0.00,0.00"
            }
            
            self.source = ekCalendar.source.title
        }
    }

    @objc public func getCalendars(entityTypeString: String = "event") -> [Calendar] {
        let entityType: EKEntityType = entityTypeString.lowercased() == "reminder" ? .reminder : .event
        let ekCalendars = eventStore.calendars(for: entityType)
        return ekCalendars.map { Calendar(from: $0) }
    }

    @objc public func getEvents(startDate: Date, endDate: Date) -> [String] {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)
        return events.map { $0.title ?? "Untitled Event" }
    }
} 