//
//  MJSFileEntry.m
//  mobile.js
//
//  Created by Grant Butler on 11/24/12.
//  Copyright (c) 2012 Grant Butler. All rights reserved.
//

#import "MJSFileEntry.h"

@implementation MJSFileEntry

EJ_BIND_GET(isFile, ctx) {
	return JSValueMakeBoolean(ctx, YES);
}

EJ_BIND_FUNCTION_NOT_IMPLEMENTED(createWriter)
EJ_BIND_FUNCTION_NOT_IMPLEMENTED(file)

@end
