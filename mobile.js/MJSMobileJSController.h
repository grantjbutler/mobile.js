//
//  MJSMobileJSController.h
//  mobile.js
//
//  Created by Grant Butler on 2/18/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

extern NSString *const MJSMobileJSControllerDidLoadMainFileNotification;

@class EJClassLoader, MJSTimerCollection;

@interface MJSMobileJSController : NSObject {
	JSGlobalContextRef jsGlobalContext;
	MJSTimerCollection *_timers;
	
	// Public for fast access in bound functions
	@public JSValueRef jsUndefined;
}

@property (nonatomic, readonly) JSGlobalContextRef jsGlobalContext;

- (void)loadScriptAtPath:(NSString *)path;

- (void)clearCaches;

- (JSValueRef)invokeCallback:(JSObjectRef)callback thisObject:(JSObjectRef)thisObject argc:(size_t)argc argv:(const JSValueRef [])argv;
- (NSString *)pathForResource:(NSString *)resourcePath;
- (JSValueRef)deleteTimer:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)loadModuleWithId:(NSString *)moduleId module:(JSValueRef)module exports:(JSValueRef)exports;
- (JSValueRef)createTimer:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv repeat:(BOOL)repeat;

@end
