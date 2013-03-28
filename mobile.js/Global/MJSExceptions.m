//
//  MJSExceptions.m
//  mobile.js
//
//  Created by Grant Butler on 11/22/12.
//  Copyright (c) 2012 Grant Butler. All rights reserved.
//

#import "MJSExceptions.h"

NSString *const MJSTooFewArgumentsException = @"MJSTooFewArgumentsException";
NSString *const MJSInvalidArgumentTypeException = @"MJSInvalidArgumentTypeException";

NSException *MJSExceptionForType(NSString *type) {
	NSString *message = @"Unkown error";
	
	if([type isEqualToString:MJSTooFewArgumentsException]) {
		message = @"Too few arguments";
	} else if([type isEqualToString:MJSInvalidArgumentTypeException]) {
		message = @"Invalid argument type";
	}
	
	return [NSException exceptionWithName:type reason:message userInfo:nil];
}
