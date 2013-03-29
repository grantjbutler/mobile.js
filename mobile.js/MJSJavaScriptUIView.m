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

- (void)setFrameWithContext:(JSContextRef)ctx argv:(const JSValueRef [])argv startingAtIndex:(NSInteger)index {
	if(JSValueIsNumber(ctx, argv[index]) && JSValueIsNumber(ctx, argv[index + 1]) && JSValueIsNumber(ctx, argv[index + 2]) && JSValueIsNumber(ctx, argv[index + 3])) {
		CGRect frame = CGRectZero;
		frame.origin.x = JSValueToNumberFast(ctx, argv[index]);
		frame.origin.y = JSValueToNumberFast(ctx, argv[index + 1]);
		frame.size.width = JSValueToNumberFast(ctx, argv[index + 2]);
		frame.size.height = JSValueToNumberFast(ctx, argv[index + 3]);
		
		_backingView.frame = frame;
	}
}

+ (Class)backingViewClass {
	return [UIView class];
}

- (void)makeBackingViewWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	Class viewClass = [[self class] backingViewClass];
	
	_backingView = [[viewClass alloc] initWithFrame:CGRectZero];
}

- (id)initWithView:(UIView *)view {
	if((self = [super init])) {
		_backingView = view;
	}
	
	return self;
}

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if((self = [super initWithContext:ctxp argc:argc argv:argv])) {
		[self makeBackingViewWithContext:ctxp argc:argc argv:argv];
	}
	
	return self;
}

- (void)dealloc {
	[_backingView release];
	_backingView = nil;
	
	[super dealloc];
}

#pragma mark - Properties

EJ_BIND_GET(backgroundColor, ctx) {
	return UIColorToJSValue(ctx, self.backingView.backgroundColor);
}

EJ_BIND_SET(backgroundColor, ctx, backgroundColor) {
	if(!backgroundColor) {
		return;
	}
	
	if(!JSValueIsString(ctx, backgroundColor)) {
		return;
	}
	
	self.backingView.backgroundColor = JSValueToUIColor(ctx, backgroundColor);
}

EJ_BIND_GET(autoresizingMask, ctx) {
	return JSValueMakeNumber(ctx, self.backingView.autoresizingMask);
}

EJ_BIND_SET(autoresizingMask, ctx, mask) {
	self.backingView.autoresizingMask = JSValueToNumber(ctx, mask, NULL);
}

#pragma mark - Frame Properties

EJ_BIND_GET(top, ctx) {
	return JSValueMakeNumber(ctx, self.backingView.frame.origin.y);
}

EJ_BIND_SET(top, ctx, newTop) {
	CGRect frame = self.backingView.frame;
	frame.origin.y = JSValueToNumberFast(ctx, newTop);
	self.backingView.frame = frame;
}

EJ_BIND_GET(left, ctx) {
	return JSValueMakeNumber(ctx, self.backingView.frame.origin.x);
}

EJ_BIND_SET(left, ctx, newLeft) {
	CGRect frame = self.backingView.frame;
	frame.origin.x = JSValueToNumberFast(ctx, newLeft);
	self.backingView.frame = frame;
}

EJ_BIND_GET(width, ctx) {
	return JSValueMakeNumber(ctx, self.backingView.frame.size.width);
}

EJ_BIND_SET(width, ctx, newWidth) {
	CGRect frame = self.backingView.frame;
	frame.size.width = JSValueToNumberFast(ctx, newWidth);
	self.backingView.frame = frame;
}

EJ_BIND_GET(height, ctx) {
	return JSValueMakeNumber(ctx, self.backingView.frame.size.height);
}

EJ_BIND_SET(height, ctx, newHeight) {
	CGRect frame = self.backingView.frame;
	frame.size.height = JSValueToNumberFast(ctx, newHeight);
	self.backingView.frame = frame;
}

#pragma mark - Functions

EJ_BIND_FUNCTION(addSubview, ctx, argc, argv) {
	EJ_MIN_ARGS(argc, 1)
	
	id jsObject_ = JSObjectGetPrivate(JSValueToObject(ctx, argv[0], NULL));
	
	
	if(![jsObject_ isKindOfClass:[MJSJavaScriptUIView class]]) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return NULL;
	}
	
	MJSJavaScriptUIView *jsView = (MJSJavaScriptUIView *)jsObject_;
	
	[self.backingView addSubview:jsView.backingView];
	
	return NULL;
}

EJ_BIND_FUNCTION(removeFromSuperview, ctx, argc, argv) {
	[self.backingView removeFromSuperview];
	
	return NULL;
}

#pragma mark - Constants

EJ_BIND_STATIC_CONST(FLEXIBLE_LEFT_MARGIN, UIViewAutoresizingFlexibleLeftMargin)
EJ_BIND_STATIC_CONST(FLEXIBLE_RIGHT_MARGIN, UIViewAutoresizingFlexibleRightMargin)
EJ_BIND_STATIC_CONST(FLEXIBLE_TOP_MARGIN, UIViewAutoresizingFlexibleTopMargin)
EJ_BIND_STATIC_CONST(FLEXIBLE_BOTTOM_MARGIN, UIViewAutoresizingFlexibleBottomMargin)
EJ_BIND_STATIC_CONST(FLEXIBLE_WIDTH, UIViewAutoresizingFlexibleWidth)
EJ_BIND_STATIC_CONST(FLEXIBLE_HEIGHT, UIViewAutoresizingFlexibleHeight)

@end
