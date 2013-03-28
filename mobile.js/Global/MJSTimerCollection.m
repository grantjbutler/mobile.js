//
//  MJSTimerCollection.m
//  mobile.js
//
//  Created by Grant Butler on 11/22/12.
//  Copyright (c) 2012 Grant Butler. All rights reserved.
//

#import "MJSTimerCollection.h"
#import "MJSMobileJSController.h"

@interface MJSTimer : NSObject

@property (nonatomic, assign) MJSTimerCollection *parentCollection;
@property (nonatomic, assign) NSUInteger timerId;

- (id)initWithTimeout:(NSTimeInterval)timeout callback:(JSObjectRef)callback controller:(MJSMobileJSController *)controller repeats:(BOOL)repeats;
- (void)invalidate;

@end

@implementation MJSTimer {
	NSTimer *_timer;
	
	BOOL _repeats;
	NSTimeInterval _timeout;
	
	JSObjectRef _callback;
	MJSMobileJSController *_controller;
}

- (id)initWithTimeout:(NSTimeInterval)timeout callback:(JSObjectRef)callback controller:(MJSMobileJSController *)controller repeats:(BOOL)repeats {
	if((self = [super init])) {
		_timer = [[NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(performCallback) userInfo:nil repeats:repeats] retain];
		
		_controller = controller;
		
		_callback = callback;
		
		JSValueProtect(_controller.jsGlobalContext, _callback);
	}
	
	return self;
}

- (void)invalidate {
	[_timer invalidate];
	_timer = nil;
	
	JSValueUnprotect(_controller.jsGlobalContext, _callback);
}

- (void)performCallback {
	[_controller invokeCallback:_callback thisObject:NULL argc:0 argv:NULL];
	
	if(![_timer isValid]) {
		[_parentCollection clearTimerWithId:_timerId];
	}
}

- (void)dealloc {
	[self invalidate];
	
	[super dealloc];
}

@end

@implementation MJSTimerCollection {
	MJSMobileJSController *_controller;
	
	NSUInteger _timerId;
	NSMutableDictionary *_timers;
}

- (id)initWithController:(MJSMobileJSController *)controller {
    if((self = [super init])) {
		_controller = controller;
		
        _timers = [@{} mutableCopy];
		_timerId = 0;
    }
    
    return self;
}

- (NSUInteger)addTimerWithTimeout:(NSTimeInterval)timeout callback:(JSObjectRef)callback repeats:(BOOL)repeats {
    _timers[@(++_timerId)] = [[[MJSTimer alloc] initWithTimeout:timeout callback:callback controller:_controller repeats:repeats] autorelease];
    
    return _timerId;
}

- (void)clearTimerWithId:(NSUInteger)timerId {
    MJSTimer *timer = _timers[@(timerId)];
    
    if(!timer) {
        return;
    }
    
	[timer invalidate];
    [_timers removeObjectForKey:@(timerId)];
}

- (void)dealloc {
	[_timers release];
	_timers = nil;
	
	[super dealloc];
}


@end
