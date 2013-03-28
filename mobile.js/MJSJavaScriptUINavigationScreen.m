//
//  MJSJavaScriptUINavigationScreen.m
//  mobile.js
//
//  Created by Grant Butler on 3/28/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSJavaScriptUINavigationScreen.h"

@implementation MJSJavaScriptUINavigationScreen

- (void)makeViewController {
	if(!_viewController) {
		_viewController = [[UINavigationController alloc] init];
	}
}

- (UINavigationController *)navigationController {
	return (UINavigationController *)self.viewController;
}

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if((self = [super initWithContext:ctxp argc:argc argv:argv])) {
		if(argc >= 1) {
			id jsObject_ = JSObjectGetPrivate(JSValueToObject(ctxp, argv[0], NULL));
			
			if(![jsObject_ isKindOfClass:[MJSJavaScriptUIScreen class]]) {
				[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
				
				[self release];
				
				return nil;
			}
			
			MJSJavaScriptUIScreen *jsScreen = (MJSJavaScriptUIScreen *)jsObject_;
			
			[(UINavigationController *)_viewController pushViewController:jsScreen.viewController animated:NO];
		}
	}
	
	return self;
}

EJ_BIND_FUNCTION(pushScreen, ctx, argc, argv) {
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
	
	[self.navigationController pushViewController:jsScreen.viewController animated:animated];
	
	return NULL;
}

EJ_BIND_FUNCTION(popScreen, ctx, argc, argv) {
	BOOL animated = YES;
	
	if(argc >= 1) {
		animated = JSValueToBoolean(ctx, argv[0]);
	}
	
	[self.navigationController popViewControllerAnimated:animated];
	
	return NULL;
}

@end
