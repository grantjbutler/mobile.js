//
//  MJSAlertView.m
//  mobile.js
//
//  Created by Grant Butler on 11/20/12.
//  Copyright (c) 2012 Grant Butler. All rights reserved.
//

#import "MJSAlertView.h"

@implementation MJSAlertView {
	NSMutableDictionary *_handlers;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
	if((self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil])) {
		_handlers = [@{} mutableCopy];
	}
	
	return self;
}

- (NSInteger)addButtonWithTitle:(NSString *)title withHandler:(MJSAlertViewHandler)handler {
	NSInteger btnIdx = [self addButtonWithTitle:title];
	
	MJSAlertViewHandler handlerCopy = Block_copy(handler);
	
	_handlers[@(btnIdx)] = handlerCopy;
	
	Block_release(handlerCopy);
	
	return btnIdx;
}

- (NSInteger)addCancelButtonWithTitle:(NSString *)title withHandler:(MJSAlertViewHandler)handler {
	NSInteger btnIdx = [self addButtonWithTitle:title withHandler:handler];
	
	self.cancelButtonIndex = btnIdx;
	
	return btnIdx;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	MJSAlertViewHandler handler = _handlers[@(buttonIndex)];
	
	if(handler) {
		handler(self);
	}
}

- (void)dealloc {
	[_handlers release];
	_handlers = nil;
	
	[super dealloc];
}

@end
