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
    
    @objc public func requestWriteOnlyAccessToEvents(completion: @escaping (Bool) -> Void) {
        if #available(macOS 14.0, *) {
            eventStore.requestWriteOnlyAccessToEvents { granted, error in
                completion(granted)
            }
        } else {
            // Fall back to the older API for macOS 10.15-13.x
            // Write-only access is not available in older versions, so we use regular access
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
        @objc public let allowedEntityTypes: [String]
        
        init(from ekCalendar: EKCalendar) {
            self.id = ekCalendar.calendarIdentifier
            self.title = ekCalendar.title
            self.allowsContentModifications = ekCalendar.allowsContentModifications
            self.type = ekCalendar.type == .local ? "local" : 
                        ekCalendar.type == .calDAV ? "calDAV" : 
                        ekCalendar.type == .exchange ? "exchange" : 
                        ekCalendar.type == .subscription ? "subscription" : 
                        ekCalendar.type == .birthday ? "birthday" : "unknown"
            
            // Determine allowed entity types
            var entityTypes: [String] = []
            if ekCalendar.allowedEntityTypes.contains(.event) {
                entityTypes.append("event")
            }
            if ekCalendar.allowedEntityTypes.contains(.reminder) {
                entityTypes.append("reminder")
            }
            self.allowedEntityTypes = entityTypes
            
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

    // Source object for JSON serialization
    @objc public class Source: NSObject {
        @objc public let id: String
        @objc public let title: String
        @objc public let sourceType: String
        
        init(ekSource: EKSource) {
            self.id = ekSource.sourceIdentifier
            self.title = ekSource.title
            
            // Convert EKSourceType to string
            switch ekSource.sourceType {
            case .local:
                self.sourceType = "local"
            case .exchange:
                self.sourceType = "exchange"
            case .calDAV:
                self.sourceType = "calDAV"
            case .mobileMe:
                self.sourceType = "mobileMe"
            case .subscribed:
                self.sourceType = "subscribed"
            case .birthdays:
                self.sourceType = "birthdays"
            @unknown default:
                self.sourceType = "unknown"
            }
            
            super.init()
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
    
    @objc public func saveCalendar(calendarData: NSDictionary, commit: Bool, completion: @escaping (Bool, String?) -> Void) {
        // Get the calendar ID if it exists (for updating an existing calendar)
        let calendarId = calendarData["id"] as? String
        
        // Get the entity type (default to event if not specified)
        let entityTypeString = (calendarData["entityType"] as? String)?.lowercased() ?? "event"
        let entityType: EKEntityType = entityTypeString == "reminder" ? .reminder : .event
        
        // Create a new calendar or get an existing one
        let calendar: EKCalendar
        if let calendarId = calendarId, let existingCalendar = eventStore.calendar(withIdentifier: calendarId) {
            // Update existing calendar
            calendar = existingCalendar
            
            // Check if the calendar supports the specified entity type
            if !existingCalendar.allowedEntityTypes.contains(entityType == .event ? .event : .reminder) {
                completion(false, "This calendar does not support the specified entity type")
                return
            }
        } else {
            // Create a new calendar
            calendar = EKCalendar(for: entityType, eventStore: eventStore)
            
            // For new calendars, we need to set a source
            if let sourceId = calendarData["sourceId"] as? String, 
               let source = eventStore.source(withIdentifier: sourceId) {
                calendar.source = source
            } else {
                // Use the default source if no source ID is provided
                if let defaultSource = eventStore.defaultCalendarForNewEvents?.source {
                    calendar.source = defaultSource
                } else if let firstSource = eventStore.sources.first(where: { $0.sourceType == .local }) {
                    calendar.source = firstSource
                } else if let firstSource = eventStore.sources.first {
                    calendar.source = firstSource
                } else {
                    // No sources available
                    completion(false, "No calendar sources available")
                    return
                }
            }
        }
        
        // Update calendar properties
        if let title = calendarData["title"] as? String {
            calendar.title = title
        }
        
        // Update color if provided
        if let colorHex = calendarData["colorHex"] as? String, colorHex.hasPrefix("#") {
            let hexString = colorHex.dropFirst() // Remove the # prefix
            
            // Parse the hex color
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 1.0
            
            if hexString.count == 8 {
                // #RRGGBBAA format
                let scanner = Scanner(string: String(hexString))
                var hexValue: UInt64 = 0
                
                if scanner.scanHexInt64(&hexValue) {
                    r = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    g = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    b = CGFloat((hexValue & 0x0000FF00) >> 8) / 255.0
                    a = CGFloat(hexValue & 0x000000FF) / 255.0
                }
            } else if hexString.count == 6 {
                // #RRGGBB format
                let scanner = Scanner(string: String(hexString))
                var hexValue: UInt64 = 0
                
                if scanner.scanHexInt64(&hexValue) {
                    r = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                    g = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
                    b = CGFloat(hexValue & 0x0000FF) / 255.0
                }
            }
            
            // Create a CGColor from the components
            if let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) {
                let components: [CGFloat] = [r, g, b, a]
                if let cgColor = CGColor(colorSpace: colorSpace, components: components) {
                    calendar.cgColor = cgColor
                }
            }
        }
        
        // Save the calendar
        do {
            try eventStore.saveCalendar(calendar, commit: commit)
            completion(true, calendar.calendarIdentifier)
        } catch {
            completion(false, error.localizedDescription)
        }
    }

    @objc public func getEvents(startDate: Date, endDate: Date) -> [String] {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)
        return events.map { $0.title ?? "Untitled Event" }
    }

    @objc public func getSources() -> NSArray {
        let sources = eventStore.sources
        let result = NSMutableArray()
        
        for source in sources {
            result.add(Source(ekSource: source))
        }
        
        return result
    }
    
    @objc public func getDelegateSources() -> NSArray {
        if #available(macOS 12.0, *) {
            let sources = eventStore.delegateSources
            let result = NSMutableArray()
            
            for source in sources {
                result.add(Source(ekSource: source))
            }
            
            return result
        } else {
            // For older macOS versions, return an empty array
            return NSArray()
        }
    }
    
    @objc public func getSource(sourceId: String) -> Source? {
        if let source = eventStore.source(withIdentifier: sourceId) {
            return Source(ekSource: source)
        }
        return nil
    }

    @objc public func commit(completion: @escaping (Bool, String?) -> Void) {
        do {
            try eventStore.commit()
            completion(true, nil)
        } catch {
            completion(false, error.localizedDescription)
        }
    }
    
    @objc public func reset() {
        eventStore.reset()
    }
    
    @objc public func refreshSourcesIfNecessary() {
        eventStore.refreshSourcesIfNecessary()
    }
    
    @objc public func removeCalendar(identifier: String, commit: Bool, completion: @escaping (Bool, String?) -> Void) {
        // Get the calendar by identifier
        guard let calendar = eventStore.calendar(withIdentifier: identifier) else {
            completion(false, "Calendar not found")
            return
        }
        
        // Try to remove the calendar
        do {
            try eventStore.removeCalendar(calendar, commit: commit)
            completion(true, nil)
        } catch {
            completion(false, error.localizedDescription)
        }
    }
} 