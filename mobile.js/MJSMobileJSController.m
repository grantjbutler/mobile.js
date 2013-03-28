//
//  MJSMobileJSController.m
//  mobile.js
//
//  Created by Grant Butler on 2/18/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSMobileJSController.h"
#import "EJClassLoader.h"
#import "EJConvert.h"
#import "MJSGlobalObject.h"
#import "MJSTimerCollection.h"

NSString *const MJSMobileJSControllerDidLoadMainFileNotification = @"MJSMobileJSControllerDidLoadMainFileNotification";

@implementation MJSMobileJSController

@synthesize jsGlobalContext;

- (id)init {
	if((self = [super init])) {
		jsGlobalContext = JSGlobalContextCreateInGroup(NULL, [EJClassLoader getJSClass:[MJSGlobalObject class]]);
		jsUndefined = JSValueMakeUndefined(jsGlobalContext);
		JSValueProtect(jsGlobalContext, jsUndefined);
		
		JSObjectRef globalJSObject = JSContextGetGlobalObject(jsGlobalContext);
		JSValueProtect(jsGlobalContext, globalJSObject);
		
		MJSGlobalObject *globalObject = [[MJSGlobalObject alloc] initWithContext:jsGlobalContext argc:0 argv:NULL];
		[globalObject createWithJSObject:globalJSObject controller:self];
		
		JSObjectSetPrivate(globalJSObject, (void *)globalObject);
		
		_timers = [[MJSTimerCollection alloc] initWithController:self];
		
		[self loadMainFile];
	}

	return self;
}

- (void)dealloc {
	[_timers release];
	_timers = nil;
	
	JSValueUnprotect(jsGlobalContext, jsUndefined);
	JSGlobalContextRef ctxref = jsGlobalContext;
	jsGlobalContext = NULL;
	JSGlobalContextRelease(ctxref);
	
	[super dealloc];
}

- (void)loadMainFile {
	NSString *file = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"MJSAppFile"];
	
	if(!file) {
		NSLog(@"No App File specified in Info.plist. Did you forget to set it?");
	} else {
		[self loadScriptAtPath:file];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:MJSMobileJSControllerDidLoadMainFileNotification object:nil];
}

- (NSString *)pathForResource:(NSString *)path {
	NSString *extension = [path pathExtension];
	NSString *fileName = [path stringByReplacingOccurrencesOfString:(NSString *)[NSString stringWithFormat:@".%@", extension] withString:@""];
	
	return [[NSBundle mainBundle] pathForResource:fileName ofType:extension];
}

- (void)loadScriptAtPath:(NSString *)path {
	NSString *script = [NSString stringWithContentsOfFile:[self pathForResource:path] encoding:NSUTF8StringEncoding error:NULL];
	
	if( !script ) {
		NSLog(@"Error: Can't Find Script %@", path );
		return;
	}
	
	NSLog(@"Loading Script: %@", path );
	JSStringRef scriptJS = JSStringCreateWithCFString((CFStringRef)script);
	JSStringRef pathJS = JSStringCreateWithCFString((CFStringRef)path);
	
	JSValueRef exception = NULL;
	JSEvaluateScript(jsGlobalContext, scriptJS, NULL, pathJS, 0, &exception );
	[self logException:exception ctx:jsGlobalContext];
	
	JSStringRelease( scriptJS );
	JSStringRelease( pathJS );
}

- (JSValueRef)loadModuleWithId:(NSString *)moduleId module:(JSValueRef)module exports:(JSValueRef)exports {
	NSString *path = [moduleId stringByAppendingString:@".js"];
	NSString *script = [NSString stringWithContentsOfFile:[self pathForResource:path] encoding:NSUTF8StringEncoding error:NULL];
	
	if( !script ) {
		NSLog(@"Error: Can't Find Module %@", moduleId );
		return NULL;
	}
	
	NSLog(@"Loading Module: %@", moduleId );
	
	JSStringRef scriptJS = JSStringCreateWithCFString((CFStringRef)script);
	JSStringRef pathJS = JSStringCreateWithCFString((CFStringRef)path);
	JSStringRef parameterNames[] = {
		JSStringCreateWithUTF8CString("module"),
		JSStringCreateWithUTF8CString("exports"),
	};
	
	JSValueRef exception = NULL;
	JSObjectRef func = JSObjectMakeFunction(jsGlobalContext, NULL, 2, parameterNames, scriptJS, pathJS, 0, &exception );
	
	JSStringRelease( scriptJS );
	JSStringRelease( pathJS );
	JSStringRelease(parameterNames[0]);
	JSStringRelease(parameterNames[1]);
	
	if( exception ) {
		[self logException:exception ctx:jsGlobalContext];
		return NULL;
	}
	
	JSValueRef params[] = { module, exports };
	return [self invokeCallback:func thisObject:NULL argc:2 argv:params];
}

- (JSValueRef)invokeCallback:(JSObjectRef)callback thisObject:(JSObjectRef)thisObject argc:(size_t)argc argv:(const JSValueRef [])argv {
	JSValueRef exception = NULL;
	JSValueRef result = JSObjectCallAsFunction(jsGlobalContext, callback, thisObject, argc, argv, &exception );
	[self logException:exception ctx:jsGlobalContext];
	return result;
}

- (void)logException:(JSValueRef)exception ctx:(JSContextRef)ctxp {
	if( !exception ) return;
	
	JSStringRef jsLinePropertyName = JSStringCreateWithUTF8CString("line");
	JSStringRef jsFilePropertyName = JSStringCreateWithUTF8CString("sourceURL");
	
	JSObjectRef exObject = JSValueToObject( ctxp, exception, NULL );
	JSValueRef line = JSObjectGetProperty( ctxp, exObject, jsLinePropertyName, NULL );
	JSValueRef file = JSObjectGetProperty( ctxp, exObject, jsFilePropertyName, NULL );
	
	NSLog(
		  @"%@ at line %@ in %@",
		  JSValueToNSString( ctxp, exception ),
		  JSValueToNSString( ctxp, line ),
		  JSValueToNSString( ctxp, file )
		  );
	
	JSStringRelease( jsLinePropertyName );
	JSStringRelease( jsFilePropertyName );
}

- (JSValueRef)createTimer:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv repeat:(BOOL)repeat {
	EJ_MIN_ARGS(argc, 2)
	
	if(!JSValueIsObject(ctxp, argv[0]) || !JSValueIsNumber(jsGlobalContext, argv[1])) {
		return NULL;
	}
	
	JSObjectRef func = JSValueToObject(ctxp, argv[0], NULL);
	float interval = JSValueToNumberFast(ctxp, argv[1])/1000;
	
	int timerId = [_timers addTimerWithTimeout:interval callback:func repeats:repeat];
	return JSValueMakeNumber( ctxp, timerId );
}

- (JSValueRef)deleteTimer:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	EJ_MIN_ARGS(argc, 1)
	
	if(!JSValueIsNumber(ctxp, argv[0])) return NULL;
	
	[_timers clearTimerWithId:JSValueToNumberFast(ctxp, argv[0])];
	return NULL;
}

- (void)clearCaches {
	JSGarbageCollect(jsGlobalContext);
}

@end
