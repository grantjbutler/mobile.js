//
//  MJSUIObject.m
//  mobile.js
//
//  Created by Grant Butler on 3/4/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSUIObject.h"
#import "EJClassLoader.h"

#import "MJSUIApp.h"

@implementation MJSUIObject {
	MJSUIApp *uiApp;
}

- (BOOL)hasProperty:(NSString *)name context:(JSContextRef)ctx {
	NSString *fullClassName = [NSString stringWithFormat:@"MJSJavaScriptUI%@", name];
	return (NSClassFromString(fullClassName) != nil);
}

- (JSValueRef)getProperty:(NSString *)name context:(JSContextRef)ctx {
	NSString *fullClassName = [NSString stringWithFormat:@"MJSJavaScriptUI%@", name];
	id class = NSClassFromString(fullClassName);
	
	if(!class) {
		return controller->jsUndefined;
	}
	
	return [EJClassLoader getConstructorOfClass:class controller:controller context:ctx];
}

EJ_BIND_GET(App, ctx) {
	if(!uiApp) {
		uiApp = [[MJSUIApp alloc] initWithContext:ctx argc:0 argv:NULL];
		[MJSUIApp createJSObjectWithContext:ctx controller:controller instance:uiApp];
		JSValueProtect(ctx, uiApp.jsObject);
	}
	
	return uiApp.jsObject;
}

- (void)dealloc {
	if(uiApp) {
		JSValueUnprotectSafe(controller.jsGlobalContext, uiApp.jsObject);
		[uiApp release];
		uiApp = nil;
	}
	
	[super dealloc];
}

@end
