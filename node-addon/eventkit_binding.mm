//
//  eventkit_binding.cpp
//  node-addon
//
//  Created by Deniz Acay on 8.03.2025.
//

#include <node_api.h>
#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "eventkit_node-Swift.h" // Generated header from Swift

// Helper to convert NSArray to JS array
napi_value NSArrayToJSArray(napi_env env, NSArray<NSString *> *array) {
    napi_value jsArray;
    napi_create_array_with_length(env, [array count], &jsArray);
    for (NSUInteger i = 0; i < [array count]; i++) {
        napi_value item;
        napi_create_string_utf8(env, [array[i] UTF8String], NAPI_AUTO_LENGTH, &item);
        napi_set_element(env, jsArray, i, item);
    }
    return jsArray;
}

// Struct to hold data for async operations
typedef struct {
    napi_env env;
    napi_deferred deferred;
    bool granted;
} CalendarAccessData;

// Async complete callback that runs on the main thread
static void CalendarAccessComplete(napi_env env, napi_status status, void* data) {
    CalendarAccessData* accessData = (CalendarAccessData*)data;
    
    napi_value result;
    napi_get_boolean(accessData->env, accessData->granted, &result);
    
    // Resolve or reject the promise based on the result
    napi_resolve_deferred(accessData->env, accessData->deferred, result);
    
    // Free the data
    free(accessData);
}

// Empty execute callback
static void CalendarAccessExecute(napi_env env, void* data) {
    // This is intentionally empty
}

// GetCalendars function
napi_value GetCalendars(napi_env env, napi_callback_info info) {
    EventKitBridge *bridge = [[EventKitBridge alloc] init];
    NSArray<NSString *> *calendars = [bridge getCalendars];
    return NSArrayToJSArray(env, calendars);
}

// RequestCalendarAccess (async example)
napi_value RequestCalendarAccess(napi_env env, napi_callback_info info) {
    // Create promise
    napi_deferred deferred;
    napi_value promise;
    napi_create_promise(env, &deferred, &promise);
    
    // Allocate data for the async operation
    CalendarAccessData* accessData = (CalendarAccessData*)malloc(sizeof(CalendarAccessData));
    accessData->env = env;
    accessData->deferred = deferred;
    
    // Create the EventKitBridge
    EventKitBridge *bridge = [[EventKitBridge alloc] init];
    
    // Request calendar access
    [bridge requestCalendarAccessWithCompletion:^(BOOL granted) {
        // Store the result in our data structure
        accessData->granted = granted;
        
        // Schedule the completion callback on the Node.js thread
        napi_value resource_name;
        napi_create_string_utf8(env, "CalendarAccess", NAPI_AUTO_LENGTH, &resource_name);
        
        napi_async_work work;
        napi_status status = napi_create_async_work(
            env,
            NULL,
            resource_name,
            CalendarAccessExecute,
            CalendarAccessComplete,
            accessData,
            &work
        );
        
        if (status == napi_ok) {
            napi_queue_async_work(env, work);
        }
    }];
    
    return promise;
}

// Init function for the module
napi_value Init(napi_env env, napi_value exports) {
    napi_value fnGetCalendars, fnRequestAccess;
    napi_create_function(env, NULL, 0, GetCalendars, NULL, &fnGetCalendars);
    napi_create_function(env, NULL, 0, RequestCalendarAccess, NULL, &fnRequestAccess);
    napi_set_named_property(env, exports, "getCalendars", fnGetCalendars);
    napi_set_named_property(env, exports, "requestCalendarAccess", fnRequestAccess);
    return exports;
}

NAPI_MODULE(NODE_GYP_MODULE_NAME, Init)
