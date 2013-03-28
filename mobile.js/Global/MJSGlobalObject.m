//
//  MJSGlobalObject.m
//  mobile.js
//
//  Created by Grant Butler on 2/20/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSGlobalObject.h"
#import "EJClassLoader.h"
#import "EJConvert.h"
#import "MJSAlertView.h"

#import "MJSConsole.h"
#import "MJSNavigator.h"
#import "MJSLocalStorage.h"
#import "MJSScreen.h"

#import "MJSUIObject.h"

@implementation MJSGlobalObject {
	MJSConsole *console;
	MJSNavigator *navigator;
	MJSLocalStorage *localStorage;
	MJSScreen *screen;
	
	MJSUIObject *uiObject;
}

- (BOOL)hasProperty:(NSString *)name context:(JSContextRef)ctx {
	NSString *fullClassName = [NSString stringWithFormat:@"MJSJavaScript%@", name];
	return (NSClassFromString(fullClassName) != nil);
}

- (JSValueRef)getProperty:(NSString *)name context:(JSContextRef)ctx {
	NSString *fullClassName = [NSString stringWithFormat:@"MJSJavaScript%@", name];
	id class = NSClassFromString(fullClassName);
	
	if(!class) {
		return controller->jsUndefined;
	}
	
	return [EJClassLoader getConstructorOfClass:class controller:controller context:ctx];
}

EJ_BIND_FUNCTION(alert, ctx, argc, argv) {
	NSString *message = @"undefined";
	
	if(argc >= 1) {
		message = JSValueToNSString(ctx, argv[0]);
	}
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
	[alertView show];
	
	do {
		[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
	} while([alertView isVisible]);
	
	[alertView release];
	
	return NULL;
}

EJ_BIND_FUNCTION(confirm, ctx, argc, argv) {
	NSString *message = @"undefined";
	
	if(argc >= 1) {
		message = JSValueToNSString(ctx, argv[0]);
	}
	
	__block BOOL result = NO;
	
	MJSAlertView *alertView = [[MJSAlertView alloc] initWithTitle:nil message:message];
	
	[alertView addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withHandler:^(MJSAlertView *alertView) {
		result = NO;
	}];
	
	[alertView addCancelButtonWithTitle:NSLocalizedString(@"OK", @"OK") withHandler:^(MJSAlertView *alertView) {
		result = YES;
	}];
	
	[alertView show];
	
	do {
		[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
	} while([alertView isVisible]);
	
	[alertView release];
	
	return JSValueMakeBoolean(ctx, result);
}

EJ_BIND_FUNCTION(prompt, ctx, argc, argv) {
	NSString *message = @"undefined";
	__block JSValueRef res = NULL;
	
	if(argc >= 1) {
		message = JSValueToNSString(ctx, argv[0]);
	}
	
	MJSAlertView *alertView = [[MJSAlertView alloc] initWithTitle:nil message:message];
	alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
	
	if(argc >= 2) {
		UITextField *textField = [alertView textFieldAtIndex:0];
		textField.placeholder = JSValueToNSString(ctx, argv[1]);
	}
	
	[alertView addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withHandler:^(MJSAlertView *alertView) {
		res = NULL;
	}];
	
	[alertView addCancelButtonWithTitle:NSLocalizedString(@"OK", @"OK") withHandler:^(MJSAlertView *alertView) {
		res = NSStringToJSValue(ctx, [[alertView textFieldAtIndex:0] text]);
	}];
	
	[alertView show];
	
	do {
		[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
	} while([alertView isVisible]);
	
	[alertView release];
	
	return res;
}

EJ_BIND_FUNCTION(setTimeout, ctx, argc, argv) {
	return [controller createTimer:ctx argc:argc argv:argv repeat:NO];
}

EJ_BIND_FUNCTION(clearTimeout, ctx, argc, argv) {
	return [controller deleteTimer:ctx argc:argc argv:argv];
}

EJ_BIND_FUNCTION(setInterval, ctx, argc, argv) {
	return [controller createTimer:ctx argc:argc argv:argv repeat:YES];
}

EJ_BIND_FUNCTION(clearInterval, ctx, argc, argv) {
	return [controller deleteTimer:ctx argc:argc argv:argv];
}

//EJ_BIND_FUNCTION(require, ctx, argc, argv) {
//	EJ_MIN_ARGS(argc, 1)
//	
//	JSGlobalContextRef tmpContext = [[MobileJS mobileJS] makeContext];
//	JSObjectRef hashObject = JSObjectMake(tmpContext, NULL, NULL);
//	JSObjectRef obj = JSContextGetGlobalObject(tmpContext);
//	JSObjectSetProperty(tmpContext, obj, JSStringCreateWithCFString((CFStringRef)@"exports"), hashObject, kJSPropertyAttributeDontDelete, NULL);
//	
//	[[MobileJS mobileJS] loadScriptAtPath:JSValueToNSString(ctx, argv[0]) intoContext:tmpContext];
//	
//	JSGlobalContextRelease(tmpContext);
//	
//	return hashObject;
//}

EJ_BIND_GET(console, ctx) {
	if(!console) {
		console = [[MJSConsole alloc] initWithContext:ctx argc:0 argv:NULL];
		[MJSConsole createJSObjectWithContext:ctx controller:controller instance:console];
		JSValueProtect(ctx, console.jsObject);
	}
	
	return console.jsObject;
}

EJ_BIND_GET(navigator, ctx) {
	if(!navigator) {
		navigator = [[MJSNavigator alloc] initWithContext:ctx argc:0 argv:NULL];
		[MJSNavigator createJSObjectWithContext:ctx controller:controller instance:navigator];
		JSValueProtect(ctx, navigator.jsObject);
	}
	
	return navigator.jsObject;
}

EJ_BIND_GET(localStorage, ctx) {
	if(!localStorage) {
		localStorage = [[MJSLocalStorage alloc] initWithContext:ctx argc:0 argv:NULL];
		[MJSLocalStorage createJSObjectWithContext:ctx controller:controller instance:localStorage];
		JSValueProtect(ctx, localStorage.jsObject);
	}
	
	return localStorage.jsObject;
}

EJ_BIND_GET(screen, ctx) {
	if(!screen) {
		screen = [[MJSScreen alloc] initWithContext:ctx argc:0 argv:NULL];
		[MJSScreen createJSObjectWithContext:ctx controller:controller instance:screen];
		JSValueProtect(ctx, screen.jsObject);
	}
	
	return screen.jsObject;
}

EJ_BIND_GET(UI, ctx) {
	if(!uiObject) {
		uiObject = [[MJSUIObject alloc] initWithContext:ctx argc:0 argv:NULL];
		[MJSUIObject createJSObjectWithContext:ctx controller:controller instance:uiObject];
		JSValueProtect(ctx, uiObject.jsObject);
	}
	
	return uiObject.jsObject;
}

- (void)dealloc {
	if(console) {
		JSValueUnprotectSafe(controller.jsGlobalContext, console.jsObject);
		[console release];
		console = nil;
	}
	
	if(navigator) {
		JSValueUnprotectSafe(controller.jsGlobalContext, navigator.jsObject);
		[navigator release];
		navigator = nil;
	}
	
	if(localStorage) {
		JSValueUnprotectSafe(controller.jsGlobalContext, localStorage.jsObject);
		[localStorage release];
		localStorage = nil;
	}
	
	if(screen) {
		JSValueUnprotectSafe(controller.jsGlobalContext, screen.jsObject);
		[screen release];
		screen = nil;
	}
	
	if(uiObject) {
		JSValueUnprotectSafe(controller.jsGlobalContext, uiObject.jsObject);
		[uiObject release];
		uiObject = nil;
	}
	
	[super dealloc];
}

@end
