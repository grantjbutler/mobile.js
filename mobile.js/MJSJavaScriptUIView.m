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

//EJ_BIND_FUNCTION(addSubview, ctx, argc, argv) {
static JSValueRef _func_addSubview(
							   JSContextRef ctx,
							   JSObjectRef function,
							   JSObjectRef object,
							   size_t argc,
							   const JSValueRef argv[],
							   JSValueRef* exception
							   ) {
	id instance = (id)JSObjectGetPrivate(object);
	JSValueRef ret = NULL;
	@try {
		ret = (JSValueRef)objc_msgSend(instance, @selector(_func_addSubview:argc:argv:), ctx, argc, argv);
	} @catch (NSException *e) {
		if(exception != NULL) {
			*exception = NSExceptionToJSValue(ctx, e);
		}
	}
	return ret ? ret : ((EJBindingBase *)instance)->controller->jsUndefined;
}
__EJ_GET_POINTER_TO(_func_addSubview)

/* The actual implementation for this method */
- (JSValueRef)_func_addSubview:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv {
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

//EJ_BIND_FUNCTION(addSubview, ctx, argc, argv) {
//	if(argc < 1 || !JSValueIsObject(ctx, argv[0])) {
//		[MJSExceptionForType(MJSTooFewArgumentsException) raise];
//		
//		return NULL;
//	}
//	
//	id jsObject_ = JSObjectGetPrivate(JSValueToObject(ctx, argv[0], NULL));
//	
//	if(![jsObject_ isKindOfClass:[MJSJavaScriptUIView class]]) {
//		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
//		
//		return NULL;
//	}
//	
//	MJSJavaScriptUIView *jsView = (MJSJavaScriptUIView *)jsObject_;
//	
//	[self.backingView addSubview:jsView.backingView];
//	
//	return NULL;
//}

EJ_BIND_FUNCTION(removeFromSuperview, ctx, argc, argv) {
	[self.backingView removeFromSuperview];
	
	return NULL;
}

@end
