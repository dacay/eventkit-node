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
    return exports;
}

NODE_API_MODULE(NODE_GYP_MODULE_NAME, Init)
