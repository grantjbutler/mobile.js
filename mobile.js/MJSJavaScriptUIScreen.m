//
//  MJSJavaScriptUIScreen.m
//  mobile.js
//
//  Created by Grant Butler on 3/28/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSJavaScriptUIScreen.h"
#import "MJSJavaScriptUIView.h"
#import "MJSJavaScriptUIBarButton.h"

@implementation MJSJavaScriptUIScreen {
	MJSJavaScriptUIView *_view;
	
	JSObjectRef _rightBarButton;
}

@synthesize viewController = _viewController;

- (void)makeViewController {
	_viewController = [[UIViewController alloc] init];
}

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if((self = [super initWithContext:ctxp argc:argc argv:argv])) {
		[self makeViewController];
	}
	
	return self;
}

- (void)dealloc {
	JSValueUnprotect(controller.jsGlobalContext, _view.jsObject);
	[_view release];
	_view = nil;
	
	[_viewController release];
	_viewController = nil;
	
	[super dealloc];
}

EJ_BIND_GET(view, ctx) {
	if(!_view) {
		_view = [[MJSJavaScriptUIView alloc] initWithView:_viewController.view];
		[MJSJavaScriptUIView createJSObjectWithContext:ctx controller:controller instance:_view];
		JSValueProtect(ctx, _view.jsObject);
	}
	
	return _view.jsObject;
}

EJ_BIND_GET(title, ctx) {
	return NSStringToJSValue(ctx, self.viewController.title);
}

EJ_BIND_SET(title, ctx, title) {
	self.viewController.title = JSValueToNSString(ctx, title);
}

EJ_BIND_GET(rightButton, ctx) {
	return _rightBarButton;
}

EJ_BIND_SET(rightButton, ctx, val) {
	JSObjectRef rightButtonObject = JSValueToObject(ctx, val, NULL);
	id jsObject_ = JSObjectGetPrivate(rightButtonObject);
	
	if(![jsObject_ isKindOfClass:[MJSJavaScriptUIBarButton class]]) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return;
	}
	
	if(_rightBarButton) {
		JSValueUnprotectSafe(ctx, _rightBarButton);
	}
	
	_rightBarButton = rightButtonObject;
	JSValueProtect(ctx, rightButtonObject);
	
	self.viewController.navigationItem.rightBarButtonItem = ((MJSJavaScriptUIBarButton *)jsObject_).barButtonItem;
}

EJ_BIND_FUNCTION(presentScreen, ctx, argc, argv) {
	EJ_MIN_ARGS(argc, 1)
	
	BOOL animated = YES;
	
	id jsObject_ = JSObjectGetPrivate(JSValueToObject(ctx, argv[0], NULL));
	
	if(![jsObject_ isKindOfClass:[MJSJavaScriptUIScreen class]]) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return NULL;
	}
	
	if(argc > 1) {
		animated = JSValueToBoolean(ctx, argv[1]);
	}
	
	MJSJavaScriptUIScreen *jsScreen = (MJSJavaScriptUIScreen *)jsObject_;
	
	[_viewController presentViewController:jsScreen.viewController animated:animated completion:NULL];
	
	return NULL;
}

EJ_BIND_FUNCTION(dismissScreen, ctx, argc, argv) {
	BOOL animated = YES;
	
	if(argc > 0) {
		animated = JSValueToBoolean(ctx, argv[1]);
	}
	
	[_viewController dismissViewControllerAnimated:animated completion:NULL];
	
	return NULL;
}

@end
