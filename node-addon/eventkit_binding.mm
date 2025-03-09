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
    
    return jsObject;
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
    
    EventKitBridge *bridge = [[EventKitBridge alloc] init];
    NSArray<Calendar *> *calendars = [bridge getCalendarsWithEntityTypeString:entityTypeString];
    
    return CalendarArrayToJSArray(info, calendars);
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

// RequestCalendarAccess function
Napi::Value RequestCalendarAccess(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    // Create a promise
    Napi::Promise::Deferred deferred = Napi::Promise::Deferred::New(env);
    
    // Create the worker
    CalendarAccessWorker* worker = new CalendarAccessWorker(deferred);
    
    // Create the EventKitBridge
    EventKitBridge *bridge = [[EventKitBridge alloc] init];
    
    // Request calendar access
    [bridge requestCalendarAccessWithCompletion:^(BOOL granted) {
        worker->SetGranted(granted);
        worker->Queue();
    }];
    
    // Return the promise
    return deferred.Promise();
}

// Initialize the module
Napi::Object Init(Napi::Env env, Napi::Object exports) {
    exports.Set("getCalendars", Napi::Function::New(env, GetCalendars));
    exports.Set("requestCalendarAccess", Napi::Function::New(env, RequestCalendarAccess));
    return exports;
}

NODE_API_MODULE(NODE_GYP_MODULE_NAME, Init)
