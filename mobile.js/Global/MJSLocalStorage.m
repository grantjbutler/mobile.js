//
//  MJSLocalStorage.m
//  mobile.js
//
//  Created by Grant Butler on 11/21/12.
//  Copyright (c) 2012 Grant Butler. All rights reserved.
//

#import "MJSLocalStorage.h"

@implementation MJSLocalStorage

EJ_BIND_FUNCTION(getItem, ctx, argc, argv) {
	EJ_MIN_ARGS(argc, 1)
	
	NSString *key = JSValueToNSString(ctx, argv[0]);
	
	NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:key];
	
	if(!value) {
		return NULL;
	}
	
	return NSStringToJSValue(ctx, value);
}

EJ_BIND_FUNCTION(setItem, ctx, argc, argv) {
	EJ_MIN_ARGS(argc, 2)
	
	NSString *key = JSValueToNSString(ctx, argv[0]);
	NSString *stringValue = JSValueToNSString(ctx, argv[1]);
	
	[[NSUserDefaults standardUserDefaults] setObject:stringValue forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return NULL;
}

EJ_BIND_FUNCTION(deleteItem, ctx, argc, argv) {
	EJ_MIN_ARGS(argc, 1)
	
	NSString *key = JSValueToNSString(ctx, argv[0]);
	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
	
	return NULL;
}

EJ_BIND_FUNCTION(clear, ctx, argc, argv) {
	// This is the way to do this, according to http://stackoverflow.com/questions/545091/clearing-nsuserdefaults
	NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
	
	return NULL;
}

@end
