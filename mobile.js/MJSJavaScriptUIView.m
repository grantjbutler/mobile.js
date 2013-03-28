//
//  MJSJavaScriptUIView.m
//  mobile.js
//
//  Created by Grant Butler on 3/28/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSJavaScriptUIView.h"

@implementation MJSJavaScriptUIView

@synthesize backingView = _backingView;

- (void)makeBackingView {
	_backingView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (id)initWithView:(UIView *)view {
	if((self = [super init])) {
		_backingView = view;
	}
	
	return self;
}

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if((self = [super initWithContext:ctxp argc:argc argv:argv])) {
		[self makeBackingView];
		
		if(argc == 4) {
			if(JSValueIsNumber(ctxp, argv[0]) && JSValueIsNumber(ctxp, argv[1]) && JSValueIsNumber(ctxp, argv[2]) && JSValueIsNumber(ctxp, argv[3])) {
				CGRect frame = CGRectZero;
				frame.origin.x = JSValueToNumberFast(ctxp, argv[0]);
				frame.origin.y = JSValueToNumberFast(ctxp, argv[1]);
				frame.size.width = JSValueToNumberFast(ctxp, argv[2]);
				frame.size.height = JSValueToNumberFast(ctxp, argv[3]);
				
				_backingView.frame = frame;
			}
		}
	}
	
	return self;
}

- (void)dealloc {
	[_backingView release];
	_backingView = nil;
	
	[super dealloc];
}

EJ_BIND_GET(backgroundColor, ctx) {
	return UIColorToJSValue(ctx, _backingView.backgroundColor);
}

EJ_BIND_SET(backgroundColor, ctx, backgroundColor) {
	if(!backgroundColor) {
		return;
	}
	
	if(!JSValueIsString(ctx, backgroundColor)) {
		return;
	}
	
	_backingView.backgroundColor = JSValueToUIColor(ctx, backgroundColor);
}

EJ_BIND_FUNCTION_NOT_IMPLEMENTED(addSubview)
EJ_BIND_FUNCTION_NOT_IMPLEMENTED(removeFromSuperview)

@end
