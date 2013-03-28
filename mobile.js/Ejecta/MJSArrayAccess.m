//
//  MJSArrayAccess.m
//  mobile.js
//
//  Created by Grant Butler on 3/10/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSArrayAccess.h"

@implementation MJSArrayAccess {
	NSMutableArray *_array;
}

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if((self = [super initWithContext:ctxp argc:argc argv:argv])) {
		_array = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (BOOL)hasProperty:(NSString *)name context:(JSContextRef)ctx {
	NSInteger index = [name integerValue];
	
	if(index < 0 || index >= [_array count]) {
		return NO;
	}
	
	return YES;
}

- (JSValueRef)getProperty:(NSString *)name context:(JSContextRef)ctx {
	NSInteger index = [name integerValue];
	
	if(index < 0 || index >= [_array count]) {
		return NULL;
	}
	
	NSValue *objcValue = [_array objectAtIndex:index];
	JSValueRef value = (JSValueRef)[objcValue pointerValue];
	
	return value;
}

- (void)setProperty:(NSString *)name value:(JSValueRef)value context:(JSContextRef)ctx {
	if(!self.isMutable) {
		return;
	}
	
	NSInteger index = [name integerValue];
	
	JSValueProtect(ctx, value);
	NSValue *objcValue = [NSValue valueWithPointer:value];
	
	if(index < 0 || index >= [_array count]) {
		NSValue *oldObjcValue = [_array objectAtIndex:index];
		JSValueRef oldValue = (JSValueRef)[oldObjcValue pointerValue];
		JSValueUnprotectSafe(ctx, oldValue);
		
		[_array replaceObjectAtIndex:index withObject:objcValue];
	} else {
		[_array insertObject:objcValue atIndex:index];
	}
}

- (void)deleteProperty:(NSString *)name context:(JSContextRef)ctx {
	if(!self.isMutable) {
		return;
	}
	
	[self setProperty:name value:controller->jsUndefined context:ctx];
}

- (void)dealloc {
	for(NSValue *objcValue in _array) {
		JSValueRef value = (JSValueRef)[objcValue pointerValue];
		JSValueUnprotectSafe(controller.jsGlobalContext, value);
	}
	
	[_array release];
	_array = nil;
	
	[super dealloc];
}

@end
