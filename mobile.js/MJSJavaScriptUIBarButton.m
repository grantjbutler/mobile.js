//
//  MJSJavaScriptUIBarButton.m
//  mobile.js
//
//  Created by Grant Butler on 3/28/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSJavaScriptUIBarButton.h"

@implementation MJSJavaScriptUIBarButton {
	UIBarButtonItem *_barButtonItem;
}

@synthesize barButtonItem = _barButtonItem;

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if((self = [super initWithContext:ctxp argc:argc argv:argv])) {
		if(argc > 0) {
			UIBarButtonSystemItem systemItem = JSValueToNumberFast(ctxp, argv[0]);
			
			_barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:self action:@selector(performAction)];
		} else {
			_barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(performAction)];
		}
	}
	
	return self;
}

- (void)performAction {
	[self triggerEvent:@"tap" argc:0 argv:NULL];
}

EJ_BIND_GET(title, ctx) {
	return NSStringToJSValue(ctx, _barButtonItem.title);
}

EJ_BIND_SET(title, ctx, val) {
	_barButtonItem.title = JSValueToNSString(ctx, val);
}

EJ_BIND_GET(style, ctx) {
	return JSValueMakeNumber(ctx, _barButtonItem.style);
}

EJ_BIND_SET(style, ctx, newStyle) {
	_barButtonItem.style = JSValueToNumberFast(ctx, newStyle);
}

EJ_BIND_EVENT(tap)

EJ_BIND_STATIC_CONST(STYLE_PLAIN, UIBarButtonItemStylePlain)
EJ_BIND_STATIC_CONST(STYLE_DONE, UIBarButtonItemStyleDone)
EJ_BIND_STATIC_CONST(STYLE_BORDERED, UIBarButtonItemStyleBordered)

EJ_BIND_STATIC_CONST(DONE, UIBarButtonSystemItemDone)
EJ_BIND_STATIC_CONST(CANCEL, UIBarButtonSystemItemCancel)
EJ_BIND_STATIC_CONST(EDIT, UIBarButtonSystemItemEdit)
EJ_BIND_STATIC_CONST(SAVE, UIBarButtonSystemItemSave)
EJ_BIND_STATIC_CONST(ADD, UIBarButtonSystemItemAdd)
EJ_BIND_STATIC_CONST(FLEXIBLE_SPACE, UIBarButtonSystemItemFlexibleSpace)
EJ_BIND_STATIC_CONST(FIXED_SPACE, UIBarButtonSystemItemFixedSpace)
EJ_BIND_STATIC_CONST(COMPOSE, UIBarButtonSystemItemCompose)
EJ_BIND_STATIC_CONST(REPLY, UIBarButtonSystemItemReply)
EJ_BIND_STATIC_CONST(ACTION, UIBarButtonSystemItemAction)
EJ_BIND_STATIC_CONST(ORGANIZE, UIBarButtonSystemItemOrganize)
EJ_BIND_STATIC_CONST(BOOKMARKS, UIBarButtonSystemItemBookmarks)
EJ_BIND_STATIC_CONST(SEARCH, UIBarButtonSystemItemSearch)
EJ_BIND_STATIC_CONST(REFRESH, UIBarButtonSystemItemRefresh)
EJ_BIND_STATIC_CONST(STOP, UIBarButtonSystemItemStop)
EJ_BIND_STATIC_CONST(CAMERA, UIBarButtonSystemItemCamera)
EJ_BIND_STATIC_CONST(TRASH, UIBarButtonSystemItemTrash)
EJ_BIND_STATIC_CONST(PLAY, UIBarButtonSystemItemPlay)
EJ_BIND_STATIC_CONST(PAUSE, UIBarButtonSystemItemPause)
EJ_BIND_STATIC_CONST(REWIND, UIBarButtonSystemItemRewind)
EJ_BIND_STATIC_CONST(FAST_FORWARD, UIBarButtonSystemItemFastForward)
EJ_BIND_STATIC_CONST(UNDO, UIBarButtonSystemItemUndo)
EJ_BIND_STATIC_CONST(REDO, UIBarButtonSystemItemRedo)
EJ_BIND_STATIC_CONST(PAGE_CURL, UIBarButtonSystemItemPageCurl)

@end
