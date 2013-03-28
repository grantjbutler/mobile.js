//
//  MJSConsole.m
//  mobile.js
//
//  Created by Grant Butler on 11/20/12.
//  Copyright (c) 2012 Grant Butler. All rights reserved.
//

#import "MJSConsole.h"
#import "EJConvert.h"

#import <JavaScriptCore/JSContextRefPrivate.h>

@implementation MJSConsole

EJ_BIND_FUNCTION(log, ctx, argc, argv) {
	if(argc < 1) {
		return NULL;
	}
	
	NSMutableArray *logs = [@[] mutableCopy];
	
	for(int i = 0; i < argc; i++) {
		[logs addObject:JSValueToNSString(ctx, argv[i])];
	}
	
	NSLog(@"%@", [logs componentsJoinedByString:@" "]);
	
	[logs release];
	
	return NULL;
}

EJ_BIND_FUNCTION(trace, ctx, argc, argv) {
	JSStringRef trace = JSContextCreateBacktrace(ctx, 10);
	
	NSString *stringTrace = ((NSString *)JSStringCopyCFString(kCFAllocatorDefault, trace));
	NSLog(@"%@", stringTrace);
	
	JSStringRelease(trace);
	[stringTrace release];
	
	return NULL;
}

@end
