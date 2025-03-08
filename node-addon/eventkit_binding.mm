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

// Helper to convert NSArray to JS array
Napi::Array NSArrayToJSArray(const Napi::CallbackInfo& info, NSArray<NSString *> *array) {
    Napi::Env env = info.Env();
    Napi::Array jsArray = Napi::Array::New(env, [array count]);
    
    for (NSUInteger i = 0; i < [array count]; i++) {
        jsArray.Set(i, Napi::String::New(env, [array[i] UTF8String]));
    }
    
    return jsArray;
}

// GetCalendars function
Napi::Value GetCalendars(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    EventKitBridge *bridge = [[EventKitBridge alloc] init];
    NSArray<NSString *> *calendars = [bridge getCalendars];
    
    return NSArrayToJSArray(info, calendars);
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
