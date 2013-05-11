//
//  MJSJavaScriptUITableViewCell.m
//  mobile.js
//
//  Created by Grant Butler on 3/29/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSJavaScriptUITableViewCell.h"
#import "MJSTableViewCell.h"
#import "MJSJavaScriptUILabel.h"

@implementation MJSJavaScriptUITableViewCell {
	MJSJavaScriptUILabel *_textLabel;
	MJSJavaScriptUILabel *_detailTextLabel;
}

- (void)makeBackingViewWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	EJ_MIN_ARGS_NO_RETURN(argc, 2)
	
	if(!JSValueIsNumber(ctxp, argv[0]) || !JSValueIsString(ctxp, argv[1])) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
	}
	
	UITableViewCellStyle cellStyle = JSValueToNumberFast(ctxp, argv[0]);
	NSString *reuseIdentifier = JSValueToNSString(ctxp, argv[1]);
	
	_backingView = [[MJSTableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:reuseIdentifier];
	self.cell.jsObject = self;
}

- (MJSTableViewCell *)cell {
	return (MJSTableViewCell *)_backingView;
}

- (void)dealloc {
	if(_textLabel) {
		JSValueUnprotectSafe(controller.jsGlobalContext, _textLabel.jsObject);
		[_textLabel release];
		_textLabel = nil;
	}
	
	[super dealloc];
}

EJ_BIND_GET(textLabel, ctx) {
	if(!_textLabel) {
		_textLabel = [[MJSJavaScriptUILabel alloc] initWithView:self.cell.textLabel];
		[MJSJavaScriptUILabel createJSObjectWithContext:ctx controller:controller instance:_textLabel];
		JSValueProtect(ctx, _textLabel.jsObject);
	}
	
	return _textLabel.jsObject;
}

EJ_BIND_GET(detailTextLabel, ctx) {
	if(!_detailTextLabel) {
		_detailTextLabel = [[MJSJavaScriptUILabel alloc] initWithView:self.cell.detailTextLabel];
		[MJSJavaScriptUILabel createJSObjectWithContext:ctx controller:controller instance:_detailTextLabel];
		JSValueProtect(ctx, _detailTextLabel.jsObject);
	}
	
	return _detailTextLabel.jsObject;
}

EJ_BIND_STATIC_CONST(DEFAULT_STYLE, UITableViewCellStyleDefault)
EJ_BIND_STATIC_CONST(SUBTITLE_STYLE, UITableViewCellStyleSubtitle)
EJ_BIND_STATIC_CONST(VALUE1_STYLE, UITableViewCellStyleValue1)
EJ_BIND_STATIC_CONST(VALUE2_STYLE, UITableViewCellStyleValue2)

@end
