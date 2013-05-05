//
//  MJSJavaScriptUILabel.m
//  mobile.js
//
//  Created by Grant Butler on 5/5/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSJavaScriptUILabel.h"

@implementation MJSJavaScriptUILabel

+ (Class)backingViewClass {
	return [UILabel class];
}

- (UILabel *)label {
	return (UILabel *)_backingView;
}

EJ_BIND_GET(text, ctx) {
	return NSStringToJSValue(ctx, self.label.text);
}

EJ_BIND_SET(text, ctx, newText) {
	self.label.text = JSValueToNSString(ctx, newText);
}

@end
