//
//  MJSJavaScriptUIScreen.m
//  mobile.js
//
//  Created by Grant Butler on 3/28/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSJavaScriptUIScreen.h"
#import "MJSJavaScriptUIView.h"

@implementation MJSJavaScriptUIScreen {
	MJSJavaScriptUIView *_view;
}

@synthesize viewController = _viewController;

- (void)makeViewController {
	_viewController = [[UIViewController alloc] init];
}

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if((self = [super initWithContext:ctxp argc:argc argv:argv])) {
		[self makeViewController];
		
		_view = [[MJSJavaScriptUIView alloc] initWithView:_viewController.view];
		[MJSJavaScriptUIView createJSObjectWithContext:ctxp controller:controller instance:_view];
		JSValueProtect(ctxp, _view.jsObject);
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
	return _view.jsObject;
}

@end
