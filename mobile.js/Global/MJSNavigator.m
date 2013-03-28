//
//  MJSNavigator.m
//  mobile.js
//
//  Created by Grant Butler on 11/20/12.
//  Copyright (c) 2012 Grant Butler. All rights reserved.
//

#import "MJSNavigator.h"

#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

@implementation MJSNavigator

EJ_BIND_GET(appName, ctx) {
	return NSStringToJSValue(ctx, [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey]);
}

EJ_BIND_GET(appVersion, ctx) {
	return NSStringToJSValue(ctx, [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]);
}

EJ_BIND_GET(platform, ctx) {
	return NSStringToJSValue(ctx, [[UIDevice currentDevice] model]);
}

EJ_BIND_GET(userAgent, ctx) {
	UIDevice *dev = [UIDevice currentDevice];
	
	NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
	NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
	NSString *osVersion = [[dev systemVersion] stringByReplacingOccurrencesOfString:@"." withString:@"_"];
	
	return NSStringToJSValue(ctx, [NSString stringWithFormat:@"Mozilla/5.0 (%@ CPU OS %@ like Mac OS X) Version/%@ %@/%@", dev.model, osVersion, dev.systemVersion, appName, appVersion]);
}

EJ_BIND_GET(onLine, ctx) {
	struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(
																				   kCFAllocatorDefault,
																				   (const struct sockaddr*)&zeroAddress
																				   );
	if( reachability ) {
		SCNetworkReachabilityFlags flags;
		SCNetworkReachabilityGetFlags(reachability, &flags);
		
		CFRelease(reachability);
		
		if(
		   // Reachable and no connection required
		   (
			(flags & kSCNetworkReachabilityFlagsReachable) &&
			!(flags & kSCNetworkReachabilityFlagsConnectionRequired)
			) ||
		   // or connection can be established without user intervention
		   (
			(flags & kSCNetworkReachabilityFlagsConnectionOnDemand) &&
			(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) &&
			!(flags & kSCNetworkReachabilityFlagsInterventionRequired)
			)
		   ) {
			return JSValueMakeBoolean(ctx, true);
		}
	}
	
	return JSValueMakeBoolean(ctx, false);
}

@end
