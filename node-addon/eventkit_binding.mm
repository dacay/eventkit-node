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
    
    // Use a try-catch block to catch any Objective-C exceptions
    @try {
        // Save the calendar
        NSDictionary *result = [bridge saveCalendarWithCalendarData:calendarDict commit:commit];
        
        if (result == nil) {
            deferred.Reject(Napi::Error::New(env, "Failed to save calendar. Default source not available.").Value());
            return deferred.Promise();
        }
        
        // Check if the operation was successful
        NSNumber *success = result[@"success"];
        if ([success boolValue]) {
            // If successful, set the calendar ID
            NSString *calendarId = result[@"id"];
            worker->SetResult(true, [calendarId UTF8String]);
        } else {
            // If failed, set the error message
            NSString *errorMessage = result[@"error"] ?: @"Unknown error saving calendar";
            worker->SetResult(false, [errorMessage UTF8String]);
        }
    } @catch (NSException *exception) {
        // Create a helpful error message
        std::string errorMessage = "Error saving calendar: ";
        errorMessage += [[exception reason] UTF8String];
        
        worker->SetResult(false, errorMessage);
    }
    
    // Queue the worker
    worker->Queue();
    
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

// GetAuthorizationStatus function
Napi::Value GetAuthorizationStatus(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Check if we have the required arguments
    if (info.Length() < 1 || !info[0].IsString()) {
        Napi::TypeError::New(env, "Entity type is required and must be a string").ThrowAsJavaScriptException();
        return env.Undefined();
    }
    
    // Get the entity type parameter
    std::string entityType = info[0].As<Napi::String>().Utf8Value();
    NSString *entityTypeStr = [NSString stringWithUTF8String:entityType.c_str()];
    
    // Create the EventKitBridge
    EventKitBridge *bridge = GetSharedBridge();
    
    // Get the authorization status
    NSString *status = [bridge getAuthorizationStatusWithEntityTypeString:entityTypeStr];
    
    // Return the status as a string
    return Napi::String::New(env, [status UTF8String]);
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
    
    // Handle nullable fields
    if (event.notes) {
        jsObject.Set("notes", Napi::String::New(env, [event.notes UTF8String]));
    } else {
        jsObject.Set("notes", env.Null());
    }
    
    // Convert dates to JavaScript Date objects
    jsObject.Set("startDate", Napi::Date::New(env, event.startDate.timeIntervalSince1970 * 1000));
    jsObject.Set("endDate", Napi::Date::New(env, event.endDate.timeIntervalSince1970 * 1000));
    jsObject.Set("isAllDay", Napi::Boolean::New(env, event.isAllDay));
    jsObject.Set("calendarId", Napi::String::New(env, [event.calendarId UTF8String]));
    jsObject.Set("calendarTitle", Napi::String::New(env, [event.calendarTitle UTF8String]));
    
    // Handle nullable fields
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
    
    // Add externalIdentifier if available
    if (event.externalIdentifier) {
        jsObject.Set("externalIdentifier", Napi::String::New(env, [event.externalIdentifier UTF8String]));
    } else {
        jsObject.Set("externalIdentifier", env.Null());
    }
    
    return jsObject;
}

// GetEvent function
Napi::Value GetEvent(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Check if identifier parameter is provided
    if (info.Length() < 1 || !info[0].IsString()) {
        Napi::Error::New(env, "Event identifier is required and must be a string.")
            .ThrowAsJavaScriptException();
        return env.Null();
    }
    
    // Get the identifier parameter
    std::string identifier = info[0].As<Napi::String>().Utf8Value();
    
    // Create an NSString from the identifier
    NSString* identifierString = [NSString stringWithUTF8String:identifier.c_str()];
    
    // Use a try-catch block to catch any Objective-C exceptions
    @try {
        EventKitBridge *bridge = GetSharedBridge();
        Event *event = [bridge getEventWithIdentifier:identifierString];
        
        // Return null if event is not found
        if (event == nil) {
            return env.Null();
        }
        
        return EventToJSObject(info, event);
    } @catch (NSException *exception) {
        // Create a more helpful error message
        std::string errorMessage = "Error retrieving event: ";
        if ([[exception name] isEqualToString:@"NSUnknownKeyException"]) {
            errorMessage = "The identifier provided belongs to a reminder, not an event. Use getReminder method for reminders.";
        } else {
            errorMessage += [[exception reason] UTF8String];
        }
        
        Napi::Error::New(env, errorMessage).ThrowAsJavaScriptException();
        return env.Null();
    }
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
    
    // Add externalIdentifier if available
    if (reminder.externalIdentifier) {
        jsObject.Set("externalIdentifier", Napi::String::New(env, [reminder.externalIdentifier UTF8String]));
    } else {
        jsObject.Set("externalIdentifier", env.Null());
    }
    
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
    // Store the native Predicate pointer in the JavaScript object
    jsObject.Set("_nativeHandle", Napi::External<Predicate>::New(env, predicate));
    
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

// RemindersFetchWorker class to handle asynchronous reminder fetching
class RemindersFetchWorker : public Napi::AsyncWorker {
private:
    Napi::Promise::Deferred deferred_;
    NSArray<Reminder *> *reminders_;
    Napi::Reference<Napi::Object> predicateRef_; // Add a reference to keep the JS object alive

public:
    RemindersFetchWorker(Napi::Promise::Deferred deferred, Napi::Object predicateObj)
        : Napi::AsyncWorker(deferred.Env()), deferred_(deferred), reminders_(nil) {
        // Create a reference to the predicate object to keep it alive during the async operation
        predicateRef_ = Napi::Persistent(predicateObj);
    }

    // Execute is called on a worker thread, but we don't need to do anything here
    // since the actual work is done in Swift on the main thread
    void Execute() override {
        // Intentionally left empty - work is done in Swift
    }

    // OnOK is called on the main thread when Execute completes
    void OnOK() override {
        Napi::Env env = Env();
        
        // Convert reminders to JS array
        Napi::Array jsArray = Napi::Array::New(env, [reminders_ count]);
        
        for (NSUInteger i = 0; i < [reminders_ count]; i++) {
            Reminder *reminder = reminders_[i];
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
            
            // Add externalIdentifier if available
            if (reminder.externalIdentifier) {
                jsObject.Set("externalIdentifier", Napi::String::New(env, [reminder.externalIdentifier UTF8String]));
            } else {
                jsObject.Set("externalIdentifier", env.Null());
            }
            
            jsArray.Set(i, jsObject);
        }
        
        // Release the reference to the predicate object before resolving
        predicateRef_.Reset();
        
        deferred_.Resolve(jsArray);
    }

    // OnError is called on the main thread if Execute throws
    void OnError(const Napi::Error& e) override {
        // Release the reference to the predicate object before rejecting
        predicateRef_.Reset();
        
        deferred_.Reject(e.Value());
    }
    
    // Set the reminders array
    void SetReminders(NSArray<Reminder *> *reminders) {
        // Retain the reminders array to prevent it from being deallocated
        reminders_ = [reminders retain];
    }
    
    // Destructor to clean up resources
    ~RemindersFetchWorker() {
        // Release the reminders array if it exists
        if (reminders_) {
            [reminders_ release];
            reminders_ = nil;
        }
    }
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
    
    // Check if the predicate has a _nativeHandle property
    if (!predicateObj.Has("_nativeHandle") || !predicateObj.Get("_nativeHandle").IsExternal()) {
        Napi::TypeError::New(env, "Invalid predicate object: missing native handle").ThrowAsJavaScriptException();
        return env.Null();
    }
    
    // Get the predicate from the object's internal field
    Predicate *predicate = reinterpret_cast<Predicate *>(predicateObj.Get("_nativeHandle").As<Napi::External<Predicate>>().Data());
    
    // Create a promise to return
    Napi::Promise::Deferred deferred = Napi::Promise::Deferred::New(env);
    
    // Create a worker to handle the async operation, passing the predicate object
    RemindersFetchWorker* worker = new RemindersFetchWorker(deferred, predicateObj);
    
    // Call the Swift method to fetch reminders
    EventKitBridge *bridge = GetSharedBridge();
    [bridge getRemindersWithPredicate:predicate completion:^(NSArray<Reminder *> * _Nullable reminders) {
        if (reminders) {
            worker->SetReminders(reminders);
            worker->Queue();
        } else {
            // If reminders is nil, resolve with an empty array
            Napi::Array emptyArray = Napi::Array::New(env);
            deferred.Resolve(emptyArray);
            delete worker; // Clean up the worker since we're not queuing it
        }
    }];
    
    return deferred.Promise();
}

// GetCalendarItem function
Napi::Value GetCalendarItem(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Check if identifier parameter is provided
    if (info.Length() < 1 || !info[0].IsString()) {
        Napi::Error::New(env, "Calendar item identifier is required and must be a string.")
            .ThrowAsJavaScriptException();
        return env.Null();
    }
    
    // Get the identifier parameter
    std::string identifier = info[0].As<Napi::String>().Utf8Value();
    
    // Create an NSString from the identifier
    NSString* identifierString = [NSString stringWithUTF8String:identifier.c_str()];
    
    // Use a try-catch block to catch any Objective-C exceptions
    @try {
        EventKitBridge *bridge = GetSharedBridge();
        NSDictionary *result = [bridge getCalendarItemWithIdentifier:identifierString];
        
        // Return null if no item is found
        if (result == nil) {
            return env.Null();
        }
        
        // Get the type and item
        NSString *type = result[@"type"];
        
        // Create a JS object with the type and the appropriate item
        Napi::Object jsObject = Napi::Object::New(env);
        
        // Add the type property
        jsObject.Set("type", Napi::String::New(env, [type UTF8String]));
        
        // Add the item property based on the type
        if ([type isEqualToString:@"event"]) {
            Event *event = result[@"item"];
            jsObject.Set("item", EventToJSObject(info, event));
        } else if ([type isEqualToString:@"reminder"]) {
            Reminder *reminder = result[@"item"];
            jsObject.Set("item", ReminderToJSObject(info, reminder));
        }
        
        return jsObject;
    } @catch (NSException *exception) {
        // Create a helpful error message
        std::string errorMessage = "Error retrieving calendar item: ";
        errorMessage += [[exception reason] UTF8String];
        
        Napi::Error::New(env, errorMessage).ThrowAsJavaScriptException();
        return env.Null();
    }
}

// GetCalendarItemsWithExternalIdentifier function
Napi::Value GetCalendarItemsWithExternalIdentifier(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Check if external identifier parameter is provided
    if (info.Length() < 1 || !info[0].IsString()) {
        Napi::Error::New(env, "External identifier is required and must be a string.")
            .ThrowAsJavaScriptException();
        return env.Null();
    }
    
    // Get the external identifier parameter
    std::string externalIdentifier = info[0].As<Napi::String>().Utf8Value();
    
    // Create an NSString from the external identifier
    NSString* externalIdentifierString = [NSString stringWithUTF8String:externalIdentifier.c_str()];
    
    // Use a try-catch block to catch any Objective-C exceptions
    @try {
        EventKitBridge *bridge = GetSharedBridge();
        NSArray *results = [bridge getCalendarItemsWithExternalIdentifier:externalIdentifierString];
        
        // Return null if no items are found
        if (results == nil) {
            return env.Null();
        }
        
        // Create a JavaScript array to hold the results
        Napi::Array jsArray = Napi::Array::New(env, [results count]);
        
        // Process each item
        for (NSUInteger i = 0; i < [results count]; i++) {
            NSDictionary *result = results[i];
            NSString *type = result[@"type"];
            
            // Create a JS object for this item
            Napi::Object jsObject = Napi::Object::New(env);
            
            // Add the type property
            jsObject.Set("type", Napi::String::New(env, [type UTF8String]));
            
            // Add the item property based on the type
            if ([type isEqualToString:@"event"]) {
                Event *event = result[@"item"];
                jsObject.Set("item", EventToJSObject(info, event));
            } else if ([type isEqualToString:@"reminder"]) {
                Reminder *reminder = result[@"item"];
                jsObject.Set("item", ReminderToJSObject(info, reminder));
            }
            
            jsArray.Set(i, jsObject);
        }
        
        return jsArray;
    } @catch (NSException *exception) {
        // Create a helpful error message
        std::string errorMessage = "Error retrieving calendar items: ";
        errorMessage += [[exception reason] UTF8String];
        
        Napi::Error::New(env, errorMessage).ThrowAsJavaScriptException();
        return env.Null();
    }
}

// RemoveEvent function
Napi::Value RemoveEvent(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Check parameters
    if (info.Length() < 1 || !info[0].IsString()) {
        Napi::Error::New(env, "Event identifier is required and must be a string.")
            .ThrowAsJavaScriptException();
        return env.Null();
    }
    
    // Get the identifier parameter
    std::string identifier = info[0].As<Napi::String>().Utf8Value();
    
    // Get the span parameter (optional, default to "thisEvent")
    std::string span = "thisEvent";
    if (info.Length() >= 2 && info[1].IsString()) {
        span = info[1].As<Napi::String>().Utf8Value();
        
        // Validate span parameter
        if (span != "thisEvent" && span != "futureEvents") {
            Napi::Error::New(env, "Span must be either 'thisEvent' or 'futureEvents'.")
                .ThrowAsJavaScriptException();
            return env.Null();
        }
    }
    
    // Get the commit parameter (optional, default to true)
    bool commit = true;
    if (info.Length() >= 3 && info[2].IsBoolean()) {
        commit = info[2].As<Napi::Boolean>().Value();
    }
    
    // Create NSString from the identifier
    NSString* identifierString = [NSString stringWithUTF8String:identifier.c_str()];
    
    // Create NSString from the span
    NSString* spanString = [NSString stringWithUTF8String:span.c_str()];
    
    // Use a try-catch block to catch any Objective-C exceptions
    @try {
        EventKitBridge *bridge = GetSharedBridge();
        bool success = [bridge removeEventWithIdentifier:identifierString span:spanString commit:commit];
        
        return Napi::Boolean::New(env, success);
    } @catch (NSException *exception) {
        // Create a helpful error message
        std::string errorMessage = "Error removing event: ";
        errorMessage += [[exception reason] UTF8String];
        
        Napi::Error::New(env, errorMessage).ThrowAsJavaScriptException();
        return env.Null();
    }
}

// RemoveReminder function
Napi::Value RemoveReminder(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Check parameters
    if (info.Length() < 1 || !info[0].IsString()) {
        Napi::Error::New(env, "Reminder identifier is required and must be a string.")
            .ThrowAsJavaScriptException();
        return env.Null();
    }
    
    // Get the identifier parameter
    std::string identifier = info[0].As<Napi::String>().Utf8Value();
    
    // Get the commit parameter (optional, default to true)
    bool commit = true;
    if (info.Length() >= 2 && info[1].IsBoolean()) {
        commit = info[1].As<Napi::Boolean>().Value();
    }
    
    // Create NSString from the identifier
    NSString* identifierString = [NSString stringWithUTF8String:identifier.c_str()];
    
    // Use a try-catch block to catch any Objective-C exceptions
    @try {
        EventKitBridge *bridge = GetSharedBridge();
        bool success = [bridge removeReminderWithIdentifier:identifierString commit:commit];
        
        return Napi::Boolean::New(env, success);
    } @catch (NSException *exception) {
        // Create a helpful error message
        std::string errorMessage = "Error removing reminder: ";
        errorMessage += [[exception reason] UTF8String];
        
        Napi::Error::New(env, errorMessage).ThrowAsJavaScriptException();
        return env.Null();
    }
}

// Class to handle the save event operation
class SaveEventWorker : public Napi::AsyncWorker {
public:
    SaveEventWorker(const Napi::Promise::Deferred& deferred)
        : Napi::AsyncWorker(Napi::Function::New(deferred.Env(), [](const Napi::CallbackInfo& info) { return info.Env().Undefined(); })),
          deferred_(deferred), success_(false), eventId_("") {}
    
    // Execute is called on a worker thread
    void Execute() override {
        // This is intentionally left empty as we're not doing any work here
        // The actual work is done in the Swift code
    }
    
    // OnOK is called on the main thread when Execute completes
    void OnOK() override {
        Napi::HandleScope scope(Env());
        
        if (success_) {
            // If successful, return the event ID
            deferred_.Resolve(Napi::String::New(Env(), eventId_));
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
    void SetResult(bool success, const std::string& eventIdOrError) {
        success_ = success;
        if (success) {
            eventId_ = eventIdOrError;
        } else {
            errorMessage_ = eventIdOrError;
        }
    }
    
private:
    Napi::Promise::Deferred deferred_;
    bool success_;
    std::string eventId_;
    std::string errorMessage_;
};

// Class to handle the save reminder operation
class SaveReminderWorker : public Napi::AsyncWorker {
public:
    SaveReminderWorker(const Napi::Promise::Deferred& deferred)
        : Napi::AsyncWorker(Napi::Function::New(deferred.Env(), [](const Napi::CallbackInfo& info) { return info.Env().Undefined(); })),
          deferred_(deferred), success_(false), reminderId_("") {}
    
    // Execute is called on a worker thread
    void Execute() override {
        // This is intentionally left empty as we're not doing any work here
        // The actual work is done in the Swift code
    }
    
    // OnOK is called on the main thread when Execute completes
    void OnOK() override {
        Napi::HandleScope scope(Env());
        
        if (success_) {
            // If successful, return the reminder ID
            deferred_.Resolve(Napi::String::New(Env(), reminderId_));
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
    void SetResult(bool success, const std::string& reminderIdOrError) {
        success_ = success;
        if (success) {
            reminderId_ = reminderIdOrError;
        } else {
            errorMessage_ = reminderIdOrError;
        }
    }
    
private:
    Napi::Promise::Deferred deferred_;
    bool success_;
    std::string reminderId_;
    std::string errorMessage_;
};

// SaveEvent function
Napi::Value SaveEvent(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Create a promise
    Napi::Promise::Deferred deferred = Napi::Promise::Deferred::New(env);
    
    // Check parameters
    if (info.Length() < 1 || !info[0].IsObject()) {
        deferred.Reject(Napi::Error::New(env, "Event data is required and must be an object.").Value());
        return deferred.Promise();
    }
    
    // Get the event data parameter
    Napi::Object eventData = info[0].As<Napi::Object>();
    
    // Get the span parameter (optional, default to "thisEvent")
    std::string span = "thisEvent";
    if (info.Length() >= 2 && info[1].IsString()) {
        span = info[1].As<Napi::String>().Utf8Value();
        
        // Validate span parameter
        if (span != "thisEvent" && span != "futureEvents") {
            deferred.Reject(Napi::Error::New(env, "Span must be either 'thisEvent' or 'futureEvents'.").Value());
            return deferred.Promise();
        }
    }
    
    // Get the commit parameter (optional, default to true)
    bool commit = true;
    if (info.Length() >= 3 && info[2].IsBoolean()) {
        commit = info[2].As<Napi::Boolean>().Value();
    }
    
    // Convert JavaScript object to NSDictionary
    NSMutableDictionary *eventDict = [NSMutableDictionary dictionary];
    
    // Process event properties
    
    // id (optional, for updating existing events)
    if (eventData.Has("id") && eventData.Get("id").IsString()) {
        std::string id = eventData.Get("id").As<Napi::String>().Utf8Value();
        eventDict[@"id"] = [NSString stringWithUTF8String:id.c_str()];
    }
    
    // title
    if (eventData.Has("title") && eventData.Get("title").IsString()) {
        std::string title = eventData.Get("title").As<Napi::String>().Utf8Value();
        eventDict[@"title"] = [NSString stringWithUTF8String:title.c_str()];
    }
    
    // notes
    if (eventData.Has("notes") && eventData.Get("notes").IsString()) {
        std::string notes = eventData.Get("notes").As<Napi::String>().Utf8Value();
        eventDict[@"notes"] = [NSString stringWithUTF8String:notes.c_str()];
    }
    
    // calendarId
    if (eventData.Has("calendarId") && eventData.Get("calendarId").IsString()) {
        std::string calendarId = eventData.Get("calendarId").As<Napi::String>().Utf8Value();
        eventDict[@"calendarId"] = [NSString stringWithUTF8String:calendarId.c_str()];
    }
    
    // startDate
    if (eventData.Has("startDate") && eventData.Get("startDate").IsDate()) {
        double timestamp = eventData.Get("startDate").As<Napi::Date>().ValueOf();
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:(timestamp / 1000.0)];
        eventDict[@"startDate"] = startDate;
    }
    
    // endDate
    if (eventData.Has("endDate") && eventData.Get("endDate").IsDate()) {
        double timestamp = eventData.Get("endDate").As<Napi::Date>().ValueOf();
        NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:(timestamp / 1000.0)];
        eventDict[@"endDate"] = endDate;
    }
    
    // isAllDay
    if (eventData.Has("isAllDay") && eventData.Get("isAllDay").IsBoolean()) {
        bool isAllDay = eventData.Get("isAllDay").As<Napi::Boolean>().Value();
        eventDict[@"isAllDay"] = @(isAllDay);
    }
    
    // location
    if (eventData.Has("location") && eventData.Get("location").IsString()) {
        std::string location = eventData.Get("location").As<Napi::String>().Utf8Value();
        eventDict[@"location"] = [NSString stringWithUTF8String:location.c_str()];
    }
    
    // url
    if (eventData.Has("url") && eventData.Get("url").IsString()) {
        std::string url = eventData.Get("url").As<Napi::String>().Utf8Value();
        eventDict[@"url"] = [NSString stringWithUTF8String:url.c_str()];
    }
    
    // availability
    if (eventData.Has("availability") && eventData.Get("availability").IsString()) {
        std::string availability = eventData.Get("availability").As<Napi::String>().Utf8Value();
        eventDict[@"availability"] = [NSString stringWithUTF8String:availability.c_str()];
    }
    
    // Create NSString from the span
    NSString* spanString = [NSString stringWithUTF8String:span.c_str()];
    
    // Create a worker to process the save operation
    SaveEventWorker *worker = new SaveEventWorker(deferred);
    
    // Use a try-catch block to catch any Objective-C exceptions
    @try {
        EventKitBridge *bridge = GetSharedBridge();
        NSDictionary *result = [bridge saveEventWithEventData:eventDict span:spanString commit:commit];
        
        if (result == nil) {
            deferred.Reject(Napi::Error::New(env, "Failed to save event. Default calendar not available.").Value());
            return deferred.Promise();
        }
        
        // Check if the operation was successful
        NSNumber *success = result[@"success"];
        if ([success boolValue]) {
            // If successful, set the event ID
            NSString *eventId = result[@"id"];
            worker->SetResult(true, [eventId UTF8String]);
        } else {
            // If failed, set the error message
            NSString *errorMessage = result[@"error"] ?: @"Unknown error saving event";
            worker->SetResult(false, [errorMessage UTF8String]);
        }
    } @catch (NSException *exception) {
        // Create a helpful error message
        std::string errorMessage = "Error saving event: ";
        errorMessage += [[exception reason] UTF8String];
        
        worker->SetResult(false, errorMessage);
    }
    
    // Queue the worker
    worker->Queue();
    
    // Return the promise
    return deferred.Promise();
}

// SaveReminder function
Napi::Value SaveReminder(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Create a promise
    Napi::Promise::Deferred deferred = Napi::Promise::Deferred::New(env);
    
    // Check parameters
    if (info.Length() < 1 || !info[0].IsObject()) {
        deferred.Reject(Napi::Error::New(env, "Reminder data is required and must be an object.").Value());
        return deferred.Promise();
    }
    
    // Get the reminder data parameter
    Napi::Object reminderData = info[0].As<Napi::Object>();
    
    // Get the commit parameter (optional, default to true)
    bool commit = true;
    if (info.Length() >= 2 && info[1].IsBoolean()) {
        commit = info[1].As<Napi::Boolean>().Value();
    }
    
    // Convert JavaScript object to NSDictionary
    NSMutableDictionary *reminderDict = [NSMutableDictionary dictionary];
    
    // Process reminder properties
    
    // id (optional, for updating existing reminders)
    if (reminderData.Has("id") && reminderData.Get("id").IsString()) {
        std::string id = reminderData.Get("id").As<Napi::String>().Utf8Value();
        reminderDict[@"id"] = [NSString stringWithUTF8String:id.c_str()];
    }
    
    // title
    if (reminderData.Has("title") && reminderData.Get("title").IsString()) {
        std::string title = reminderData.Get("title").As<Napi::String>().Utf8Value();
        reminderDict[@"title"] = [NSString stringWithUTF8String:title.c_str()];
    }
    
    // notes
    if (reminderData.Has("notes") && reminderData.Get("notes").IsString()) {
        std::string notes = reminderData.Get("notes").As<Napi::String>().Utf8Value();
        reminderDict[@"notes"] = [NSString stringWithUTF8String:notes.c_str()];
    }
    
    // calendarId
    if (reminderData.Has("calendarId") && reminderData.Get("calendarId").IsString()) {
        std::string calendarId = reminderData.Get("calendarId").As<Napi::String>().Utf8Value();
        reminderDict[@"calendarId"] = [NSString stringWithUTF8String:calendarId.c_str()];
    }
    
    // completed
    if (reminderData.Has("completed") && reminderData.Get("completed").IsBoolean()) {
        bool completed = reminderData.Get("completed").As<Napi::Boolean>().Value();
        reminderDict[@"completed"] = @(completed);
    }
    
    // priority
    if (reminderData.Has("priority") && reminderData.Get("priority").IsNumber()) {
        int priority = reminderData.Get("priority").As<Napi::Number>().Int32Value();
        reminderDict[@"priority"] = @(priority);
    }
    
    // dueDate
    if (reminderData.Has("dueDate") && reminderData.Get("dueDate").IsDate()) {
        double timestamp = reminderData.Get("dueDate").As<Napi::Date>().ValueOf();
        NSDate *dueDate = [NSDate dateWithTimeIntervalSince1970:(timestamp / 1000.0)];
        reminderDict[@"dueDate"] = dueDate;
    }
    
    // startDate
    if (reminderData.Has("startDate") && reminderData.Get("startDate").IsDate()) {
        double timestamp = reminderData.Get("startDate").As<Napi::Date>().ValueOf();
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:(timestamp / 1000.0)];
        reminderDict[@"startDate"] = startDate;
    }
    
    // Create a worker to process the save operation
    SaveReminderWorker *worker = new SaveReminderWorker(deferred);
    
    // Use a try-catch block to catch any Objective-C exceptions
    @try {
        EventKitBridge *bridge = GetSharedBridge();
        NSDictionary *result = [bridge saveReminderWithReminderData:reminderDict commit:commit];
        
        if (result == nil) {
            deferred.Reject(Napi::Error::New(env, "Failed to save reminder. Default calendar not available.").Value());
            return deferred.Promise();
        }
        
        // Check if the operation was successful
        NSNumber *success = result[@"success"];
        if ([success boolValue]) {
            // If successful, set the reminder ID
            NSString *reminderId = result[@"id"];
            worker->SetResult(true, [reminderId UTF8String]);
        } else {
            // If failed, set the error message
            NSString *errorMessage = result[@"error"] ?: @"Unknown error saving reminder";
            worker->SetResult(false, [errorMessage UTF8String]);
        }
    } @catch (NSException *exception) {
        // Create a helpful error message
        std::string errorMessage = "Error saving reminder: ";
        errorMessage += [[exception reason] UTF8String];
        
        worker->SetResult(false, errorMessage);
    }
    
    // Queue the worker
    worker->Queue();
    
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
    exports.Set("getEvent", Napi::Function::New(env, GetEvent));
    exports.Set("getCalendarItem", Napi::Function::New(env, GetCalendarItem));
    exports.Set("getCalendarItemsWithExternalIdentifier", Napi::Function::New(env, GetCalendarItemsWithExternalIdentifier));
    exports.Set("removeEvent", Napi::Function::New(env, RemoveEvent));
    exports.Set("removeReminder", Napi::Function::New(env, RemoveReminder));
    exports.Set("saveEvent", Napi::Function::New(env, SaveEvent));
    exports.Set("saveReminder", Napi::Function::New(env, SaveReminder));
    exports.Set("getAuthorizationStatus", Napi::Function::New(env, GetAuthorizationStatus));
    return exports;
}

NODE_API_MODULE(NODE_GYP_MODULE_NAME, Init)
