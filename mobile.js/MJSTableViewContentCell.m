//
//  MJSTableViewContentCell.m
//  mobile.js
//
//  Created by Grant Butler on 5/5/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSTableViewContentCell.h"

@implementation MJSTableViewContentCell

EJ_BIND_GET(style, ctx) {
	return JSValueMakeNumber(ctx, self.style);
}

EJ_BIND_SET(style, ctx, newStyle) {
	self.style = JSValueToNumberFast(ctx, newStyle);
}

EJ_BIND_GET(reuseIdentifier, ctx) {
	return NSStringToJSValue(ctx, self.reuseIdentifier);
}

EJ_BIND_SET(reuseIdentifier, ctx, newIdentifier) {
	self.reuseIdentifier = JSValueToNSString(ctx, newIdentifier);
}

@end
