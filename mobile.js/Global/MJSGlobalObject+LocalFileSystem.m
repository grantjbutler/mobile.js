//
//  MJSLocalFileSystem.m
//  mobile.js
//
//  Created by Grant Butler on 11/22/12.
//  Copyright (c) 2012 Grant Butler. All rights reserved.
//

#import "MJSGlobalObject+LocalFileSystem.h"
#import "MJSFileSystem.h"
#import "EJClassLoader.h"

@implementation MJSGlobalObject (LocalFileSystem)

EJ_BIND_FUNCTION(requestFileSystem, ctx, argc, argv) {
	EJ_MIN_ARGS(argc, 3)
	
	MJSFileSystem *fileSystem = [[MJSFileSystem alloc] initWithContext:ctx argc:argc argv:argv];
	JSObjectRef fileSystemObject = [MJSFileSystem createJSObjectWithContext:ctx controller:controller instance:fileSystem];
	JSObjectCallAsFunction(ctx, (JSObjectRef)argv[2], NULL, 1, (JSValueRef *)&fileSystemObject, NULL);
	[fileSystem release];
	
	return NULL;
}

EJ_BIND_FUNCTION_NOT_IMPLEMENTED(resolveLocalFileSystemURL)

EJ_BIND_CONST(TEMPORARY, kMJSFileSystemTypeTemporary)
EJ_BIND_CONST(PERSISTENT, kMJSFileSystemTypePersistent)

@end
