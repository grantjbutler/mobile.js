//
//  MJSUIApp.m
//  mobile.js
//
//  Created by Grant Butler on 3/4/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSUIApp.h"
#import "MJSJavaScriptUIScreen.h"

@implementation MJSUIApp {
	JSObjectRef _mainScreen;
}

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if((self = [super initWithContext:ctxp argc:argc argv:argv])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadMainFile:) name:MJSMobileJSControllerDidLoadMainFileNotification object:nil];
	}
	
	return self;
}

- (void)didLoadMainFile:(NSNotification *)notification {
	[self triggerEvent:@"launch" argc:0 argv:NULL];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MJSMobileJSControllerDidLoadMainFileNotification object:nil];
}

EJ_BIND_EVENT(launch)

EJ_BIND_FUNCTION(openURL, ctx, argc, argv) {
	EJ_MIN_ARGS(argc, 1)
	
	NSURL *url = [NSURL URLWithString:JSValueToNSString(ctx, argv[0])];
	
	if(!url) {
		return JSValueMakeBoolean(ctx, NO);
	}
	
	return JSValueMakeBoolean(ctx, [[UIApplication sharedApplication] openURL:url]);
}

EJ_BIND_FUNCTION(canOpenURL, ctx, argc, argv) {
	EJ_MIN_ARGS(argc, 1)
	
	NSURL *url = [NSURL URLWithString:JSValueToNSString(ctx, argv[0])];
	
	if(!url) {
		return JSValueMakeBoolean(ctx, NO);
	}
	
	return JSValueMakeBoolean(ctx, [[UIApplication sharedApplication] openURL:url]);
}

EJ_BIND_GET(iconBadgeNumber, ctx) {
	return JSValueMakeNumber(ctx, [[UIApplication sharedApplication] applicationIconBadgeNumber]);
}

EJ_BIND_SET(iconBadgeNumber, ctx, number) {
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:JSValueToNumberFast(ctx, number)];
}

EJ_BIND_GET(mainScreen, ctx) {
	return _mainScreen;
}

EJ_BIND_SET(mainScreen, ctx, newScreen) {
	if(_mainScreen != NULL) {
		JSValueUnprotectSafe(ctx, _mainScreen);
	}
	
	if(!JSValueIsObject(ctx, newScreen)) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return;
	}
	
	JSObjectRef jsObject_ = JSValueToObject(ctx, newScreen, NULL);
	id instance = JSObjectGetPrivate(jsObject_);
	
	if(![instance isKindOfClass:[MJSJavaScriptUIScreen class]]) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return;
	}
	
	_mainScreen = jsObject_;
	JSValueProtect(ctx, _mainScreen);
	
	[[UIApplication sharedApplication] delegate].window.rootViewController = [(MJSJavaScriptUIScreen *)instance viewController];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	JSValueUnprotectSafe(controller.jsGlobalContext, _mainScreen);
	_mainScreen = NULL;
	
	[super dealloc];
}

@end
