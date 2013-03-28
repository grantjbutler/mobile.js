//
//  MJSExceptions.h
//  mobile.js
//
//  Created by Grant Butler on 11/22/12.
//  Copyright (c) 2012 Grant Butler. All rights reserved.
//

extern NSString *const MJSTooFewArgumentsException;
extern NSString *const MJSInvalidArgumentTypeException;

NSException *MJSExceptionForType(NSString *type);

