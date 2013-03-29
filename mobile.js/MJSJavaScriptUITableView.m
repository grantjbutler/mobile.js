//
//  MJSJavaScriptUITableView.m
//  mobile.js
//
//  Created by Grant Butler on 3/29/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSJavaScriptUITableView.h"
#import "MJSJavaScriptUITableViewData.h"

@interface MJSJavaScriptUITableView ()

@end

@implementation MJSJavaScriptUITableView {
	JSObjectRef _data;
}

- (void)makeBackingViewWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	EJ_MIN_ARGS_NO_RETURN(argc, 1)
	
	UITableViewStyle style = JSValueToNumberFast(ctxp, argv[0]);
	
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
	
	_backingView = tableView;
}

- (UITableView *)tableView {
	return (UITableView *)_backingView;
}

EJ_BIND_GET(data, ctx) {
	return _data;
}

EJ_BIND_SET(data, ctx, newData) {
	if(!JSValueIsObject(ctx, newData)) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return;
	}
	
	JSObjectRef jsObject_ = JSValueToObject(ctx, newData, NULL);
	id instance = JSObjectGetPrivate(jsObject_);
	
	if(![instance isKindOfClass:[MJSJavaScriptUITableViewData class]]) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return;
	}
	
	JSValueUnprotectSafe(ctx, _data);
	
	JSValueProtect(ctx, jsObject_);
	_data = jsObject_;
	
	self.tableView.dataSource = instance;
}

EJ_BIND_STATIC_CONST(PLAIN_STYLE, UITableViewStylePlain)
EJ_BIND_STATIC_CONST(GROUPED_STYLE, UITableViewStyleGrouped)

- (void)dealloc {
	JSValueUnprotectSafe(controller.jsGlobalContext, _data);
	
	[super dealloc];
}

@end
