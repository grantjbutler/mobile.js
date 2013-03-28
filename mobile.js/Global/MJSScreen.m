//
//  MJSScreen.m
//  mobile.js
//
//  Created by Grant Butler on 11/22/12.
//  Copyright (c) 2012 Grant Butler. All rights reserved.
//

#import "MJSScreen.h"

@implementation MJSScreen

EJ_BIND_GET(availWidth, ctx) {
	return JSValueMakeNumber(ctx, [UIScreen mainScreen].applicationFrame.size.width);
}

EJ_BIND_GET(availHeight, ctx) {
	return JSValueMakeNumber(ctx, [UIScreen mainScreen].applicationFrame.size.height);
}

EJ_BIND_GET(width, ctx) {
	return JSValueMakeNumber(ctx, [UIScreen mainScreen].bounds.size.width);
}

EJ_BIND_GET(height, ctx) {
	return JSValueMakeNumber(ctx, [UIScreen mainScreen].bounds.size.height);
}

@end
