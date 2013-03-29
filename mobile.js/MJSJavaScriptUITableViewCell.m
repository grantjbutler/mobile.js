//
//  MJSJavaScriptUITableViewCell.m
//  mobile.js
//
//  Created by Grant Butler on 3/29/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSJavaScriptUITableViewCell.h"

@implementation MJSJavaScriptUITableViewCell

- (void)makeBackingViewWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	EJ_MIN_ARGS_NO_RETURN(argc, 2)
	
	if(!JSValueIsNumber(ctxp, argv[0]) || !JSValueIsString(ctxp, argv[1])) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
	}
	
	UITableViewCellStyle cellStyle = JSValueToNumberFast(ctxp, argv[0]);
	NSString *reuseIdentifier = JSValueToNSString(ctxp, argv[1]);
	
	_backingView = [[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:reuseIdentifier];
}

EJ_BIND_STATIC_CONST(DEFAULT_STYLE, UITableViewCellStyleDefault)
EJ_BIND_STATIC_CONST(SUBTITLE_STYLE, UITableViewCellStyleSubtitle)
EJ_BIND_STATIC_CONST(VALUE1_STYLE, UITableViewCellStyleValue1)
EJ_BIND_STATIC_CONST(VALUE2_STYLE, UITableViewCellStyleValue2)

@end
