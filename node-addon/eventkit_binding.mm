//
//  eventkit_binding.mm
//  node-addon
//
//  Created by Deniz Acay on 8.03.2025.
//

#include <napi.h>
#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "eventkit_node-Swift.h" // Generated header from Swift

// Global EventKitBridge instance
static EventKitBridge *gBridge = nil;

// Helper function to get the shared EventKitBridge instance
EventKitBridge* GetSharedBridge() {
    if (gBridge == nil) {
        gBridge = [[EventKitBridge alloc] init];
    }
    return gBridge;
}

// Helper to convert Calendar object to JS object
Napi::Object CalendarToJSObject(const Napi::CallbackInfo& info, Calendar *calendar) {
    Napi::Env env = info.Env();
    Napi::Object jsObject = Napi::Object::New(env);
    
    jsObject.Set("id", Napi::String::New(env, [calendar.id UTF8String]));
    jsObject.Set("title", Napi::String::New(env, [calendar.title UTF8String]));
    jsObject.Set("allowsContentModifications", Napi::Boolean::New(env, calendar.allowsContentModifications));
    jsObject.Set("type", Napi::String::New(env, [calendar.type UTF8String]));
    
    // Create a color object with all representations
    Napi::Object colorObject = Napi::Object::New(env);
    colorObject.Set("hex", Napi::String::New(env, [calendar.colorHex UTF8String]));
    colorObject.Set("components", Napi::String::New(env, [calendar.colorComponents UTF8String]));
    colorObject.Set("space", Napi::String::New(env, [calendar.colorSpace UTF8String]));
    
    jsObject.Set("color", colorObject);
    jsObject.Set("source", Napi::String::New(env, [calendar.source UTF8String]));
    
    // Add allowedEntityTypes array
    Napi::Array allowedEntityTypes = Napi::Array::New(env, [calendar.allowedEntityTypes count]);
    for (NSUInteger i = 0; i < [calendar.allowedEntityTypes count]; i++) {
        NSString *entityType = calendar.allowedEntityTypes[i];
        allowedEntityTypes.Set(i, Napi::String::New(env, [entityType UTF8String]));
    }
    jsObject.Set("allowedEntityTypes", allowedEntityTypes);
    
    return jsObject;
}

// Helper to convert Source object to JS object
Napi::Object SourceToJSObject(const Napi::CallbackInfo& info, Source *source) {
    Napi::Env env = info.Env();
    Napi::Object jsObject = Napi::Object::New(env);
    
    jsObject.Set("id", Napi::String::New(env, [source.id UTF8String]));
    jsObject.Set("title", Napi::String::New(env, [source.title UTF8String]));
    jsObject.Set("sourceType", Napi::String::New(env, [source.sourceType UTF8String]));
    
    return jsObject;
}

// Helper to convert NSArray of Source objects to JS array
Napi::Array SourceArrayToJSArray(const Napi::CallbackInfo& info, NSArray<Source *> *sources) {
    Napi::Env env = info.Env();
    Napi::Array jsArray = Napi::Array::New(env, [sources count]);
    
    for (NSUInteger i = 0; i < [sources count]; i++) {
        jsArray.Set(i, SourceToJSObject(info, sources[i]));
    }
    
    return jsArray;
}

// Helper to convert NSArray of Calendar objects to JS array
Napi::Array CalendarArrayToJSArray(const Napi::CallbackInfo& info, NSArray<Calendar *> *calendars) {
    Napi::Env env = info.Env();
    Napi::Array jsArray = Napi::Array::New(env, [calendars count]);
    
    for (NSUInteger i = 0; i < [calendars count]; i++) {
        jsArray.Set(i, CalendarToJSObject(info, calendars[i]));
    }
    
    return jsArray;
}

// GetCalendars function
Napi::Value GetCalendars(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Get the entity type parameter, default to "event"
    std::string entityType = "event";
    if (info.Length() > 0 && info[0].IsString()) {
        entityType = info[0].As<Napi::String>().Utf8Value();
        
        // Convert to lowercase for case-insensitive comparison
        std::transform(entityType.begin(), entityType.end(), entityType.begin(),
                      [](unsigned char c) { return std::tolower(c); });
        
        // Validate entity type
        if (entityType != "event" && entityType != "reminder") {
            Napi::Error::New(env, "Invalid entity type. Allowed values are 'event' and 'reminder'.")
                .ThrowAsJavaScriptException();
            return env.Undefined();
        }
    }
    
    // Create an NSString from the entity type
    NSString* entityTypeString = [NSString stringWithUTF8String:entityType.c_str()];
    
    EventKitBridge *bridge = GetSharedBridge();
    NSArray<Calendar *> *calendars = [bridge getCalendarsWithEntityTypeString:entityTypeString];
    
    return CalendarArrayToJSArray(info, calendars);
}

// GetCalendar function
Napi::Value GetCalendar(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Check if identifier parameter is provided
    if (info.Length() < 1 || !info[0].IsString()) {
        Napi::Error::New(env, "Calendar identifier is required and must be a string.")
            .ThrowAsJavaScriptException();
        return env.Null();
    }
    
    // Get the identifier parameter
    std::string identifier = info[0].As<Napi::String>().Utf8Value();
    
    // Create an NSString from the identifier
    NSString* identifierString = [NSString stringWithUTF8String:identifier.c_str()];
    
    EventKitBridge *bridge = GetSharedBridge();
    Calendar *calendar = [bridge getCalendarWithIdentifier:identifierString];
    
    // Return null if calendar is not found
    if (calendar == nil) {
        return env.Null();
    }
    
    return CalendarToJSObject(info, calendar);
}

// GetSources function
Napi::Value GetSources(const Napi::CallbackInfo& info) {
    EventKitBridge *bridge = GetSharedBridge();
    NSArray<Source *> *sources = [bridge getSources];
    
    return SourceArrayToJSArray(info, sources);
}

// GetDelegateSources function
Napi::Value GetDelegateSources(const Napi::CallbackInfo& info) {
    EventKitBridge *bridge = GetSharedBridge();
    NSArray<Source *> *sources = [bridge getDelegateSources];
    
    return SourceArrayToJSArray(info, sources);
}

// GetSource function
Napi::Value GetSource(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Check if we have the required arguments
    if (info.Length() < 1 || !info[0].IsString()) {
        Napi::TypeError::New(env, "Source ID is required and must be a string").ThrowAsJavaScriptException();
        return env.Null();
    }
    
    std::string sourceId = info[0].As<Napi::String>().Utf8Value();
    NSString *sourceIdStr = [NSString stringWithUTF8String:sourceId.c_str()];
    
    EventKitBridge *bridge = GetSharedBridge();
    Source *source = [bridge getSourceWithSourceId:sourceIdStr];
    
    if (source) {
        return SourceToJSObject(info, source);
    } else {
        return env.Null();
    }
}

// Class to handle the calendar access request
class CalendarAccessWorker : public Napi::AsyncWorker {
public:
    CalendarAccessWorker(const Napi::Promise::Deferred& deferred)
        : Napi::AsyncWorker(Napi::Function::New(deferred.Env(), [](const Napi::CallbackInfo& info) { return info.Env().Undefined(); })),
          deferred_(deferred), granted_(false) {}
    
    // Execute is called on a worker thread
    void Execute() override {
        // This is intentionally left empty as we're not doing any work here
        // The actual work is done in the Swift code
    }
    
    // OnOK is called on the main thread when Execute completes
    void OnOK() override {
        Napi::HandleScope scope(Env());
        deferred_.Resolve(Napi::Boolean::New(Env(), granted_));
    }
    
    // OnError is called on the main thread if Execute throws
    void OnError(const Napi::Error& error) override {
        Napi::HandleScope scope(Env());
        deferred_.Reject(error.Value());
    }
    
    // Method to set the granted value
    void SetGranted(bool granted) {
        granted_ = granted;
    }
    
private:
    Napi::Promise::Deferred deferred_;
    bool granted_;
};

// Class to handle the reminders access request
class RemindersAccessWorker : public Napi::AsyncWorker {
public:
    RemindersAccessWorker(const Napi::Promise::Deferred& deferred)
        : Napi::AsyncWorker(Napi::Function::New(deferred.Env(), [](const Napi::CallbackInfo& info) { return info.Env().Undefined(); })),
          deferred_(deferred), granted_(false) {}
    
    // Execute is called on a worker thread
    void Execute() override {
        // This is intentionally left empty as we're not doing any work here
        // The actual work is done in the Swift code
    }
    
    // OnOK is called on the main thread when Execute completes
    void OnOK() override {
        Napi::HandleScope scope(Env());
        deferred_.Resolve(Napi::Boolean::New(Env(), granted_));
    }
    
    // OnError is called on the main thread if Execute throws
    void OnError(const Napi::Error& error) override {
        Napi::HandleScope scope(Env());
        deferred_.Reject(error.Value());
    }
    
    // Method to set the granted value
    void SetGranted(bool granted) {
        granted_ = granted;
    }
    
private:
    Napi::Promise::Deferred deferred_;
    bool granted_;
};

// Class to handle the save calendar operation
class SaveCalendarWorker : public Napi::AsyncWorker {
public:
    SaveCalendarWorker(const Napi::Promise::Deferred& deferred)
        : Napi::AsyncWorker(Napi::Function::New(deferred.Env(), [](const Napi::CallbackInfo& info) { return info.Env().Undefined(); })),
          deferred_(deferred), success_(false), calendarId_("") {}
    
    // Execute is called on a worker thread
    void Execute() override {
        // This is intentionally left empty as we're not doing any work here
        // The actual work is done in the Swift code
    }
    
    // OnOK is called on the main thread when Execute completes
    void OnOK() override {
        Napi::HandleScope scope(Env());
        
        if (success_) {
            // If successful, return the calendar ID
            deferred_.Resolve(Napi::String::New(Env(), calendarId_));
        } else {
            // If failed, reject with the error message
            deferred_.Reject(Napi::Error::New(Env(), errorMessage_).Value());
        }
    }
    
    // OnError is called on the main thread if Execute throws
    void OnError(const Napi::Error& error) override {
        Napi::HandleScope scope(Env());
        deferred_.Reject(error.Value());
    }
    
    // Method to set the result values
    void SetResult(bool success, const std::string& calendarIdOrError) {
        success_ = success;
        if (success) {
            calendarId_ = calendarIdOrError;
        } else {
            errorMessage_ = calendarIdOrError;
        }
    }
    
private:
    Napi::Promise::Deferred deferred_;
    bool success_;
    std::string calendarId_;
    std::string errorMessage_;
};

// Class to handle the remove calendar operation
class RemoveCalendarWorker : public Napi::AsyncWorker {
public:
    RemoveCalendarWorker(const Napi::Promise::Deferred& deferred)
        : Napi::AsyncWorker(Napi::Function::New(deferred.Env(), [](const Napi::CallbackInfo& info) { return info.Env().Undefined(); })),
          deferred_(deferred), success_(false), errorMessage_("") {}
    
    // Execute is called on a worker thread
    void Execute() override {
        // This is intentionally left empty as we're not doing any work here
        // The actual work is done in the Swift code
    }
    
    // OnOK is called on the main thread when Execute completes
    void OnOK() override {
        Napi::HandleScope scope(Env());
        
        if (success_) {
            // If successful, return true
            deferred_.Resolve(Napi::Boolean::New(Env(), true));
        } else {
            // If failed, reject with the error message
            deferred_.Reject(Napi::Error::New(Env(), errorMessage_).Value());
        }
    }
    
    // OnError is called on the main thread if Execute throws
    void OnError(const Napi::Error& error) override {
        Napi::HandleScope scope(Env());
        deferred_.Reject(error.Value());
    }
    
    // Method to set the result values
    void SetResult(bool success, const std::string& errorMessage) {
        success_ = success;
        if (!success) {
            errorMessage_ = errorMessage;
        }
    }
    
private:
    Napi::Promise::Deferred deferred_;
    bool success_;
    std::string errorMessage_;
};

// RequestCalendarAccess function
Napi::Value RequestCalendarAccess(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Create a promise
    Napi::Promise::Deferred deferred = Napi::Promise::Deferred::New(env);
    
    // Create the worker
    CalendarAccessWorker* worker = new CalendarAccessWorker(deferred);
    
    // Create the EventKitBridge
    EventKitBridge *bridge = GetSharedBridge();
    
    // Request calendar access
    [bridge requestCalendarAccessWithCompletion:^(BOOL granted) {
        worker->SetGranted(granted);
        worker->Queue();
    }];
    
    // Return the promise
    return deferred.Promise();
}

// RequestRemindersAccess function
Napi::Value RequestRemindersAccess(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Create a promise
    Napi::Promise::Deferred deferred = Napi::Promise::Deferred::New(env);
    
    // Create the worker
    RemindersAccessWorker* worker = new RemindersAccessWorker(deferred);
    
    // Create the EventKitBridge
    EventKitBridge *bridge = GetSharedBridge();
    
    // Request reminders access
    [bridge requestRemindersAccessWithCompletion:^(BOOL granted) {
        worker->SetGranted(granted);
        worker->Queue();
    }];
    
    // Return the promise
    return deferred.Promise();
}

// SaveCalendar function
Napi::Value SaveCalendar(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Check if calendar data parameter is provided
    if (info.Length() < 1 || !info[0].IsObject()) {
        Napi::Error::New(env, "Calendar data is required and must be an object.")
            .ThrowAsJavaScriptException();
        return env.Undefined();
    }
    
    // Get the calendar data parameter
    Napi::Object calendarData = info[0].As<Napi::Object>();
    
    // Get the commit parameter, default to true
    bool commit = true;
    if (info.Length() > 1 && info[1].IsBoolean()) {
        commit = info[1].As<Napi::Boolean>().Value();
    }
    
    // Create an NSDictionary from the calendar data
    NSMutableDictionary* calendarDict = [NSMutableDictionary dictionary];
    
    // Add all properties from the JS object to the dictionary
    if (calendarData.Has("id") && calendarData.Get("id").IsString()) {
        std::string id = calendarData.Get("id").As<Napi::String>().Utf8Value();
        calendarDict[@"id"] = [NSString stringWithUTF8String:id.c_str()];
    }
    
    if (calendarData.Has("title") && calendarData.Get("title").IsString()) {
        std::string title = calendarData.Get("title").As<Napi::String>().Utf8Value();
        calendarDict[@"title"] = [NSString stringWithUTF8String:title.c_str()];
    }
    
    if (calendarData.Has("entityType") && calendarData.Get("entityType").IsString()) {
        std::string entityType = calendarData.Get("entityType").As<Napi::String>().Utf8Value();
        calendarDict[@"entityType"] = [NSString stringWithUTF8String:entityType.c_str()];
    }
    
    if (calendarData.Has("sourceId") && calendarData.Get("sourceId").IsString()) {
        std::string sourceId = calendarData.Get("sourceId").As<Napi::String>().Utf8Value();
        calendarDict[@"sourceId"] = [NSString stringWithUTF8String:sourceId.c_str()];
    }
    
    // Handle color
    if (calendarData.Has("color") && calendarData.Get("color").IsObject()) {
        Napi::Object colorObject = calendarData.Get("color").As<Napi::Object>();
        if (colorObject.Has("hex") && colorObject.Get("hex").IsString()) {
            std::string colorHex = colorObject.Get("hex").As<Napi::String>().Utf8Value();
            calendarDict[@"colorHex"] = [NSString stringWithUTF8String:colorHex.c_str()];
        }
    }
    
    // Create a promise
    Napi::Promise::Deferred deferred = Napi::Promise::Deferred::New(env);
    
    // Create the worker
    SaveCalendarWorker* worker = new SaveCalendarWorker(deferred);
    
    // Create the EventKitBridge
    EventKitBridge *bridge = GetSharedBridge();
    
    // Save the calendar
    [bridge saveCalendarWithCalendarData:calendarDict commit:commit completion:^(BOOL success, NSString * _Nullable calendarIdOrError) {
        std::string resultString = calendarIdOrError ? [calendarIdOrError UTF8String] : "";
        worker->SetResult(success, resultString);
        worker->Queue();
    }];
    
    // Return the promise
    return deferred.Promise();
}

// RequestWriteOnlyAccessToEvents function
Napi::Value RequestWriteOnlyAccessToEvents(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Create a promise
    Napi::Promise::Deferred deferred = Napi::Promise::Deferred::New(env);
    
    // Create the worker
    CalendarAccessWorker* worker = new CalendarAccessWorker(deferred);
    
    // Create the EventKitBridge
    EventKitBridge *bridge = GetSharedBridge();
    
    // Request write-only access to events
    [bridge requestWriteOnlyAccessToEventsWithCompletion:^(BOOL granted) {
        worker->SetGranted(granted);
        worker->Queue();
    }];
    
    // Return the promise
    return deferred.Promise();
}

// Commit function
Napi::Value Commit(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Create a promise
    Napi::Promise::Deferred deferred = Napi::Promise::Deferred::New(env);
    
    // Create the EventKitBridge
    EventKitBridge *bridge = GetSharedBridge();
    
    // Commit changes
    [bridge commitWithCompletion:^(BOOL success, NSString * _Nullable errorMessage) {
        if (success) {
            deferred.Resolve(Napi::Boolean::New(env, true));
        } else {
            std::string error = errorMessage ? [errorMessage UTF8String] : "Unknown error during commit";
            deferred.Reject(Napi::Error::New(env, error).Value());
        }
    }];
    
    // Return the promise
    return deferred.Promise();
}

// Reset function
Napi::Value Reset(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Create the EventKitBridge
    EventKitBridge *bridge = GetSharedBridge();
    
    // Reset the event store
    [bridge reset];
    
    // Return undefined
    return env.Undefined();
}

// RefreshSourcesIfNecessary function
Napi::Value RefreshSourcesIfNecessary(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Create the EventKitBridge
    EventKitBridge *bridge = GetSharedBridge();
    
    // Refresh sources if necessary
    [bridge refreshSourcesIfNecessary];
    
    // Return undefined
    return env.Undefined();
}

// GetDefaultCalendarForNewEvents function
Napi::Value GetDefaultCalendarForNewEvents(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Create the EventKitBridge
    EventKitBridge *bridge = GetSharedBridge();
    
    // Get the default calendar for new events
    Calendar *calendar = [bridge getDefaultCalendarForNewEvents];
    
    // Return null if no default calendar is set
    if (calendar == nil) {
        return env.Null();
    }
    
    return CalendarToJSObject(info, calendar);
}

// GetDefaultCalendarForNewReminders function
Napi::Value GetDefaultCalendarForNewReminders(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Create the EventKitBridge
    EventKitBridge *bridge = GetSharedBridge();
    
    // Get the default calendar for new reminders
    Calendar *calendar = [bridge getDefaultCalendarForNewReminders];
    
    // Return null if no default calendar is set
    if (calendar == nil) {
        return env.Null();
    }
    
    return CalendarToJSObject(info, calendar);
}

// RemoveCalendar function
Napi::Value RemoveCalendar(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Check if calendar identifier parameter is provided
    if (info.Length() < 1 || !info[0].IsString()) {
        Napi::Error::New(env, "Calendar identifier is required and must be a string.")
            .ThrowAsJavaScriptException();
        return env.Undefined();
    }
    
    // Get the calendar identifier parameter
    std::string identifier = info[0].As<Napi::String>().Utf8Value();
    
    // Get the commit parameter, default to true
    bool commit = true;
    if (info.Length() > 1 && info[1].IsBoolean()) {
        commit = info[1].As<Napi::Boolean>().Value();
    }
    
    // Create a promise
    Napi::Promise::Deferred deferred = Napi::Promise::Deferred::New(env);
    
    // Create the worker
    RemoveCalendarWorker* worker = new RemoveCalendarWorker(deferred);
    
    // Create the EventKitBridge
    EventKitBridge *bridge = GetSharedBridge();
    
    // Remove the calendar
    NSString* identifierString = [NSString stringWithUTF8String:identifier.c_str()];
    [bridge removeCalendarWithIdentifier:identifierString commit:commit completion:^(BOOL success, NSString * _Nullable errorMessage) {
        std::string error = errorMessage ? [errorMessage UTF8String] : "";
        worker->SetResult(success, error);
        worker->Queue();
    }];
    
    // Return the promise
    return deferred.Promise();
}

// Helper to convert Event object to JS object
Napi::Object EventToJSObject(const Napi::CallbackInfo& info, Event *event) {
    Napi::Env env = info.Env();
    Napi::Object jsObject = Napi::Object::New(env);
    
    jsObject.Set("id", Napi::String::New(env, [event.id UTF8String]));
    jsObject.Set("title", Napi::String::New(env, [event.title UTF8String]));
    
    if (event.notes) {
        jsObject.Set("notes", Napi::String::New(env, [event.notes UTF8String]));
    } else {
        jsObject.Set("notes", env.Null());
    }
    
    jsObject.Set("startDate", Napi::Date::New(env, event.startDate.timeIntervalSince1970 * 1000));
    jsObject.Set("endDate", Napi::Date::New(env, event.endDate.timeIntervalSince1970 * 1000));
    jsObject.Set("isAllDay", Napi::Boolean::New(env, event.isAllDay));
    jsObject.Set("calendarId", Napi::String::New(env, [event.calendarId UTF8String]));
    jsObject.Set("calendarTitle", Napi::String::New(env, [event.calendarTitle UTF8String]));
    
    if (event.location) {
        jsObject.Set("location", Napi::String::New(env, [event.location UTF8String]));
    } else {
        jsObject.Set("location", env.Null());
    }
    
    if (event.url) {
        jsObject.Set("url", Napi::String::New(env, [event.url UTF8String]));
    } else {
        jsObject.Set("url", env.Null());
    }
    
    jsObject.Set("hasAlarms", Napi::Boolean::New(env, event.hasAlarms));
    jsObject.Set("availability", Napi::String::New(env, [event.availability UTF8String]));
    
    return jsObject;
}

// Helper to convert Reminder object to JS object
Napi::Object ReminderToJSObject(const Napi::CallbackInfo& info, Reminder *reminder) {
    Napi::Env env = info.Env();
    Napi::Object jsObject = Napi::Object::New(env);
    
    jsObject.Set("id", Napi::String::New(env, [reminder.id UTF8String]));
    jsObject.Set("title", Napi::String::New(env, [reminder.title UTF8String]));
    
    if (reminder.notes) {
        jsObject.Set("notes", Napi::String::New(env, [reminder.notes UTF8String]));
    } else {
        jsObject.Set("notes", env.Null());
    }
    
    jsObject.Set("calendarId", Napi::String::New(env, [reminder.calendarId UTF8String]));
    jsObject.Set("calendarTitle", Napi::String::New(env, [reminder.calendarTitle UTF8String]));
    jsObject.Set("completed", Napi::Boolean::New(env, reminder.completed));
    
    if (reminder.completionDate) {
        jsObject.Set("completionDate", Napi::Date::New(env, reminder.completionDate.timeIntervalSince1970 * 1000));
    } else {
        jsObject.Set("completionDate", env.Null());
    }
    
    if (reminder.dueDate) {
        jsObject.Set("dueDate", Napi::Date::New(env, reminder.dueDate.timeIntervalSince1970 * 1000));
    } else {
        jsObject.Set("dueDate", env.Null());
    }
    
    if (reminder.startDate) {
        jsObject.Set("startDate", Napi::Date::New(env, reminder.startDate.timeIntervalSince1970 * 1000));
    } else {
        jsObject.Set("startDate", env.Null());
    }
    
    jsObject.Set("priority", Napi::Number::New(env, reminder.priority));
    jsObject.Set("hasAlarms", Napi::Boolean::New(env, reminder.hasAlarms));
    
    return jsObject;
}

// Helper to convert NSArray of Event objects to JS array
Napi::Array EventArrayToJSArray(const Napi::CallbackInfo& info, NSArray<Event *> *events) {
    Napi::Env env = info.Env();
    Napi::Array jsArray = Napi::Array::New(env, [events count]);
    
    for (NSUInteger i = 0; i < [events count]; i++) {
        jsArray.Set(i, EventToJSObject(info, events[i]));
    }
    
    return jsArray;
}

// Helper to convert Predicate object to JS object
Napi::Object PredicateToJSObject(const Napi::CallbackInfo& info, Predicate *predicate) {
    Napi::Env env = info.Env();
    Napi::Object jsObject = Napi::Object::New(env);
    
    jsObject.Set("type", Napi::String::New(env, [predicate.predicateType UTF8String]));
    // We don't expose the actual NSPredicate to JS, just its type
    
    return jsObject;
}

// CreateEventPredicate function
Napi::Value CreateEventPredicate(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Check if we have the required arguments
    if (info.Length() < 2 || !info[0].IsDate() || !info[1].IsDate()) {
        Napi::TypeError::New(env, "Start date and end date are required and must be Date objects").ThrowAsJavaScriptException();
        return env.Null();
    }
    
    // Get the start date and end date
    Napi::Date startDateObj = info[0].As<Napi::Date>();
    Napi::Date endDateObj = info[1].As<Napi::Date>();
    
    // Convert to NSDate
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:startDateObj.ValueOf() / 1000];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:endDateObj.ValueOf() / 1000];
    
    // Get the calendar IDs if provided
    NSMutableArray<NSString *> *calendarIds = nil;
    if (info.Length() > 2 && info[2].IsArray()) {
        Napi::Array calendarIdsArray = info[2].As<Napi::Array>();
        calendarIds = [NSMutableArray arrayWithCapacity:calendarIdsArray.Length()];
        
        for (uint32_t i = 0; i < calendarIdsArray.Length(); i++) {
            Napi::Value value = calendarIdsArray.Get(i);
            if (value.IsString()) {
                NSString *calendarId = [NSString stringWithUTF8String:value.As<Napi::String>().Utf8Value().c_str()];
                [calendarIds addObject:calendarId];
            }
        }
    }
    
    // Create the predicate
    EventKitBridge *bridge = GetSharedBridge();
    Predicate *predicate = [bridge createEventPredicateWithStartDate:startDate endDate:endDate calendarIds:calendarIds];
    
    return PredicateToJSObject(info, predicate);
}

// CreateReminderPredicate function
Napi::Value CreateReminderPredicate(const Napi::CallbackInfo& info) {
    
    // Get the calendar IDs if provided
    NSMutableArray<NSString *> *calendarIds = nil;
    if (info.Length() > 0 && info[0].IsArray()) {
        Napi::Array calendarIdsArray = info[0].As<Napi::Array>();
        calendarIds = [NSMutableArray arrayWithCapacity:calendarIdsArray.Length()];
        
        for (uint32_t i = 0; i < calendarIdsArray.Length(); i++) {
            Napi::Value value = calendarIdsArray.Get(i);
            if (value.IsString()) {
                NSString *calendarId = [NSString stringWithUTF8String:value.As<Napi::String>().Utf8Value().c_str()];
                [calendarIds addObject:calendarId];
            }
        }
    }
    
    // Create the predicate
    EventKitBridge *bridge = GetSharedBridge();
    Predicate *predicate = [bridge createReminderPredicateWithCalendarIds:calendarIds];
    
    return PredicateToJSObject(info, predicate);
}

// CreateIncompleteReminderPredicate function
Napi::Value CreateIncompleteReminderPredicate(const Napi::CallbackInfo& info) {
    
    // Get the start date if provided
    NSDate *startDate = nil;
    if (info.Length() > 0 && info[0].IsDate()) {
        Napi::Date startDateObj = info[0].As<Napi::Date>();
        startDate = [NSDate dateWithTimeIntervalSince1970:startDateObj.ValueOf() / 1000];
    }
    
    // Get the end date if provided
    NSDate *endDate = nil;
    if (info.Length() > 1 && info[1].IsDate()) {
        Napi::Date endDateObj = info[1].As<Napi::Date>();
        endDate = [NSDate dateWithTimeIntervalSince1970:endDateObj.ValueOf() / 1000];
    }
    
    // Get the calendar IDs if provided
    NSMutableArray<NSString *> *calendarIds = nil;
    if (info.Length() > 2 && info[2].IsArray()) {
        Napi::Array calendarIdsArray = info[2].As<Napi::Array>();
        calendarIds = [NSMutableArray arrayWithCapacity:calendarIdsArray.Length()];
        
        for (uint32_t i = 0; i < calendarIdsArray.Length(); i++) {
            Napi::Value value = calendarIdsArray.Get(i);
            if (value.IsString()) {
                NSString *calendarId = [NSString stringWithUTF8String:value.As<Napi::String>().Utf8Value().c_str()];
                [calendarIds addObject:calendarId];
            }
        }
    }
    
    // Create the predicate
    EventKitBridge *bridge = GetSharedBridge();
    Predicate *predicate = [bridge createIncompleteReminderPredicateWithStartDate:startDate endDate:endDate calendarIds:calendarIds];
    
    return PredicateToJSObject(info, predicate);
}

// CreateCompletedReminderPredicate function
Napi::Value CreateCompletedReminderPredicate(const Napi::CallbackInfo& info) {
    
    // Get the start date if provided
    NSDate *startDate = nil;
    if (info.Length() > 0 && info[0].IsDate()) {
        Napi::Date startDateObj = info[0].As<Napi::Date>();
        startDate = [NSDate dateWithTimeIntervalSince1970:startDateObj.ValueOf() / 1000];
    }
    
    // Get the end date if provided
    NSDate *endDate = nil;
    if (info.Length() > 1 && info[1].IsDate()) {
        Napi::Date endDateObj = info[1].As<Napi::Date>();
        endDate = [NSDate dateWithTimeIntervalSince1970:endDateObj.ValueOf() / 1000];
    }
    
    // Get the calendar IDs if provided
    NSMutableArray<NSString *> *calendarIds = nil;
    if (info.Length() > 2 && info[2].IsArray()) {
        Napi::Array calendarIdsArray = info[2].As<Napi::Array>();
        calendarIds = [NSMutableArray arrayWithCapacity:calendarIdsArray.Length()];
        
        for (uint32_t i = 0; i < calendarIdsArray.Length(); i++) {
            Napi::Value value = calendarIdsArray.Get(i);
            if (value.IsString()) {
                NSString *calendarId = [NSString stringWithUTF8String:value.As<Napi::String>().Utf8Value().c_str()];
                [calendarIds addObject:calendarId];
            }
        }
    }
    
    // Create the predicate
    EventKitBridge *bridge = GetSharedBridge();
    Predicate *predicate = [bridge createCompletedReminderPredicateWithStartDate:startDate endDate:endDate calendarIds:calendarIds];
    
    return PredicateToJSObject(info, predicate);
}

// GetEventsWithPredicate function
Napi::Value GetEventsWithPredicate(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Check if we have the required arguments
    if (info.Length() < 1 || !info[0].IsObject()) {
        Napi::TypeError::New(env, "Predicate is required and must be an object").ThrowAsJavaScriptException();
        return env.Null();
    }
    
    // Get the predicate
    Napi::Object predicateObj = info[0].As<Napi::Object>();
    
    // Check if it's a valid predicate
    if (!predicateObj.Has("type") || !predicateObj.Get("type").IsString()) {
        Napi::TypeError::New(env, "Invalid predicate object").ThrowAsJavaScriptException();
        return env.Null();
    }
    
    // Get the predicate type
    std::string predicateType = predicateObj.Get("type").As<Napi::String>().Utf8Value();
    
    // Check if it's an event predicate
    if (predicateType != "event") {
        Napi::TypeError::New(env, "Predicate must be an event predicate").ThrowAsJavaScriptException();
        return env.Null();
    }
    
    // Get the predicate from the object's internal field
    Predicate *predicate = reinterpret_cast<Predicate *>(predicateObj.Get("_nativeHandle").As<Napi::External<Predicate>>().Data());
    
    // Get events with the predicate
    EventKitBridge *bridge = GetSharedBridge();
    NSArray<Event *> *events = [bridge getEventsWithPredicateWithPredicate:predicate];
    
    return EventArrayToJSArray(info, events);
}

// Class to handle the reminders fetch operation
class RemindersFetchWorker : public Napi::AsyncWorker {
public:
    RemindersFetchWorker(const Napi::Promise::Deferred& deferred, Predicate *predicate)
        : Napi::AsyncWorker(Napi::Function::New(deferred.Env(), [](const Napi::CallbackInfo& info) { return info.Env().Undefined(); })),
          deferred_(deferred), predicate_(predicate), reminders_(nil) {}
    
    // Execute is called on a worker thread
    void Execute() override {
        // This is intentionally left empty as we're not doing any work here
        // The actual work is done in the Swift code
    }
    
    // OnOK is called on the main thread when Execute completes
    void OnOK() override {
        Napi::HandleScope scope(Env());
        
        if (reminders_ == nil) {
            deferred_.Resolve(Env().Null());
            return;
        }
        
        // Convert reminders to JS array
        Napi::Array jsArray = Napi::Array::New(Env(), [reminders_ count]);
        
        for (NSUInteger i = 0; i < [reminders_ count]; i++) {
            Reminder *reminder = reminders_[i];
            Napi::Object jsObject = Napi::Object::New(Env());
            
            jsObject.Set("id", Napi::String::New(Env(), [reminder.id UTF8String]));
            jsObject.Set("title", Napi::String::New(Env(), [reminder.title UTF8String]));
            
            if (reminder.notes) {
                jsObject.Set("notes", Napi::String::New(Env(), [reminder.notes UTF8String]));
            } else {
                jsObject.Set("notes", Env().Null());
            }
            
            jsObject.Set("calendarId", Napi::String::New(Env(), [reminder.calendarId UTF8String]));
            jsObject.Set("calendarTitle", Napi::String::New(Env(), [reminder.calendarTitle UTF8String]));
            jsObject.Set("completed", Napi::Boolean::New(Env(), reminder.completed));
            
            if (reminder.completionDate) {
                jsObject.Set("completionDate", Napi::Date::New(Env(), reminder.completionDate.timeIntervalSince1970 * 1000));
            } else {
                jsObject.Set("completionDate", Env().Null());
            }
            
            if (reminder.dueDate) {
                jsObject.Set("dueDate", Napi::Date::New(Env(), reminder.dueDate.timeIntervalSince1970 * 1000));
            } else {
                jsObject.Set("dueDate", Env().Null());
            }
            
            if (reminder.startDate) {
                jsObject.Set("startDate", Napi::Date::New(Env(), reminder.startDate.timeIntervalSince1970 * 1000));
            } else {
                jsObject.Set("startDate", Env().Null());
            }
            
            jsObject.Set("priority", Napi::Number::New(Env(), reminder.priority));
            jsObject.Set("hasAlarms", Napi::Boolean::New(Env(), reminder.hasAlarms));
            
            jsArray.Set(i, jsObject);
        }
        
        deferred_.Resolve(jsArray);
    }
    
    // OnError is called on the main thread if Execute throws
    void OnError(const Napi::Error& error) override {
        Napi::HandleScope scope(Env());
        deferred_.Reject(error.Value());
    }
    
    // Method to set the reminders
    void SetReminders(NSArray<Reminder *> *reminders) {
        reminders_ = reminders;
    }
    
private:
    Napi::Promise::Deferred deferred_;
    Predicate *predicate_;
    NSArray<Reminder *> *reminders_;
};

// GetRemindersWithPredicate function
Napi::Value GetRemindersWithPredicate(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Check if we have the required arguments
    if (info.Length() < 1 || !info[0].IsObject()) {
        Napi::TypeError::New(env, "Predicate is required and must be an object").ThrowAsJavaScriptException();
        return env.Null();
    }
    
    // Get the predicate
    Napi::Object predicateObj = info[0].As<Napi::Object>();
    
    // Check if it's a valid predicate
    if (!predicateObj.Has("type") || !predicateObj.Get("type").IsString()) {
        Napi::TypeError::New(env, "Invalid predicate object").ThrowAsJavaScriptException();
        return env.Null();
    }
    
    // Get the predicate type
    std::string predicateType = predicateObj.Get("type").As<Napi::String>().Utf8Value();
    
    // Check if it's a reminder predicate
    if (predicateType != "reminder" && predicateType != "incompleteReminder" && predicateType != "completedReminder") {
        Napi::TypeError::New(env, "Predicate must be a reminder predicate").ThrowAsJavaScriptException();
        return env.Null();
    }
    
    // Get the predicate from the object's internal field
    Predicate *predicate = reinterpret_cast<Predicate *>(predicateObj.Get("_nativeHandle").As<Napi::External<Predicate>>().Data());
    
    // Create a promise
    Napi::Promise::Deferred deferred = Napi::Promise::Deferred::New(env);
    
    // Create the worker
    RemindersFetchWorker* worker = new RemindersFetchWorker(deferred, predicate);
    
    // Get reminders with the predicate
    EventKitBridge *bridge = GetSharedBridge();
    [bridge getRemindersWithPredicateWithPredicate:predicate completion:^(NSArray<Reminder *> * _Nullable reminders) {
        worker->SetReminders(reminders);
        worker->Queue();
    }];
    
    // Return the promise
    return deferred.Promise();
}

// Initialize the module
Napi::Object Init(Napi::Env env, Napi::Object exports) {
    exports.Set("getCalendars", Napi::Function::New(env, GetCalendars));
    exports.Set("getCalendar", Napi::Function::New(env, GetCalendar));
    exports.Set("requestCalendarAccess", Napi::Function::New(env, RequestCalendarAccess));
    exports.Set("requestRemindersAccess", Napi::Function::New(env, RequestRemindersAccess));
    exports.Set("saveCalendar", Napi::Function::New(env, SaveCalendar));
    exports.Set("removeCalendar", Napi::Function::New(env, RemoveCalendar));
    exports.Set("getSources", Napi::Function::New(env, GetSources));
    exports.Set("getDelegateSources", Napi::Function::New(env, GetDelegateSources));
    exports.Set("getSource", Napi::Function::New(env, GetSource));
    exports.Set("requestWriteOnlyAccessToEvents", Napi::Function::New(env, RequestWriteOnlyAccessToEvents));
    exports.Set("commit", Napi::Function::New(env, Commit));
    exports.Set("reset", Napi::Function::New(env, Reset));
    exports.Set("refreshSourcesIfNecessary", Napi::Function::New(env, RefreshSourcesIfNecessary));
    exports.Set("getDefaultCalendarForNewEvents", Napi::Function::New(env, GetDefaultCalendarForNewEvents));
    exports.Set("getDefaultCalendarForNewReminders", Napi::Function::New(env, GetDefaultCalendarForNewReminders));
    exports.Set("createEventPredicate", Napi::Function::New(env, CreateEventPredicate));
    exports.Set("createReminderPredicate", Napi::Function::New(env, CreateReminderPredicate));
    exports.Set("createIncompleteReminderPredicate", Napi::Function::New(env, CreateIncompleteReminderPredicate));
    exports.Set("createCompletedReminderPredicate", Napi::Function::New(env, CreateCompletedReminderPredicate));
    exports.Set("getEventsWithPredicate", Napi::Function::New(env, GetEventsWithPredicate));
    exports.Set("getRemindersWithPredicate", Napi::Function::New(env, GetRemindersWithPredicate));
    return exports;
}

NODE_API_MODULE(NODE_GYP_MODULE_NAME, Init)
