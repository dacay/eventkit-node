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
        if #available(macOS 14.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                completion(granted)
            }
        } else {
            // Fall back to the older API for macOS 10.15-13.x
            eventStore.requestAccess(to: .event) { granted, error in
                completion(granted)
            }
        }
    }
    
    @objc public func requestRemindersAccess(completion: @escaping (Bool) -> Void) {
        if #available(macOS 14.0, *) {
            eventStore.requestFullAccessToReminders { granted, error in
                completion(granted)
            }
        } else {
            // Fall back to the older API for macOS 10.15-13.x
            eventStore.requestAccess(to: .reminder) { granted, error in
                completion(granted)
            }
        }
    }

    // Calendar object for JSON serialization
    @objc public class Calendar: NSObject {
        @objc public let id: String
        @objc public let title: String
        @objc public let allowsContentModifications: Bool
        @objc public let type: String
        @objc public let colorHex: String
        @objc public let colorComponents: String
        @objc public let colorSpace: String
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
            
            // Store color space information
            if let colorSpace = ekCalendar.cgColor.colorSpace {
                switch colorSpace.model {
                case .rgb: self.colorSpace = "rgb"
                case .monochrome: self.colorSpace = "monochrome"
                case .cmyk: self.colorSpace = "cmyk"
                case .lab: self.colorSpace = "lab"
                case .deviceN: self.colorSpace = "deviceN"
                case .indexed: self.colorSpace = "indexed"
                case .pattern: self.colorSpace = "pattern"
                case .XYZ: self.colorSpace = "xyz"
                case .unknown: self.colorSpace = "unknown"
                @unknown default: self.colorSpace = "unknown"
                }
            } else {
                self.colorSpace = "unknown"
            }
            
            // Store raw color components as a string
            if let components = ekCalendar.cgColor.components {
                let componentStrings = components.map { String(format: "%.6f", $0) }
                self.colorComponents = componentStrings.joined(separator: ",")
            } else {
                self.colorComponents = ""
            }
            
            // Convert to hex for convenience (RGB approximation)
            if let components = ekCalendar.cgColor.components, ekCalendar.cgColor.numberOfComponents >= 4 {
                let r = Int(components[0] * 255.0)
                let g = Int(components[1] * 255.0)
                let b = Int(components[2] * 255.0)
                let a = Int(components[3] * 255.0)
                self.colorHex = String(format: "#%02X%02X%02X%02X", r, g, b, a)
            } else if let components = ekCalendar.cgColor.components, ekCalendar.cgColor.numberOfComponents >= 1 {
                // Handle grayscale
                let gray = Int(components[0] * 255.0)
                let a = ekCalendar.cgColor.numberOfComponents >= 2 ? Int(components[1] * 255.0) : 255
                self.colorHex = String(format: "#%02X%02X%02X%02X", gray, gray, gray, a)
            } else {
                self.colorHex = "#00000000" // Transparent black as fallback
            }
            
            self.source = ekCalendar.source.title
        }
    }

    @objc public func getCalendars(entityTypeString: String = "event") -> [Calendar] {
        let entityType: EKEntityType = entityTypeString.lowercased() == "reminder" ? .reminder : .event
        let ekCalendars = eventStore.calendars(for: entityType)
        return ekCalendars.map { Calendar(from: $0) }
    }
    
    @objc public func getCalendar(identifier: String) -> Calendar? {
        guard let ekCalendar = eventStore.calendar(withIdentifier: identifier) else {
            return nil
        }
        return Calendar(from: ekCalendar)
    }

    @objc public func getEvents(startDate: Date, endDate: Date) -> [String] {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)
        return events.map { $0.title ?? "Untitled Event" }
    }
} 