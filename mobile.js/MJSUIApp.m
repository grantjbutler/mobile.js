//
//  MJSUIApp.m
//  mobile.js
//
//  Created by Grant Butler on 3/4/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSUIApp.h"

@implementation MJSUIApp

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

@end
