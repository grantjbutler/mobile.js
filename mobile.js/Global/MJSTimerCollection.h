//
//  MJSTimerCollection.h
//  mobile.js
//
//  Created by Grant Butler on 11/22/12.
//  Copyright (c) 2012 Grant Butler. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <JavaScriptCore/JavaScriptCore.h>

@class MJSMobileJSController;

@interface MJSTimerCollection : NSObject

- (id)initWithController:(MJSMobileJSController *)controller;
- (NSUInteger)addTimerWithTimeout:(NSTimeInterval)timeout callback:(JSObjectRef)callback repeats:(BOOL)repeats;
- (void)clearTimerWithId:(NSUInteger)timerId;

@end
