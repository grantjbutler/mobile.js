//
//  MJSDirectoryEntry.m
//  mobile.js
//
//  Created by Grant Butler on 11/24/12.
//  Copyright (c) 2012 Grant Butler. All rights reserved.
//

#import "MJSDirectoryEntry.h"

@implementation MJSDirectoryEntry

EJ_BIND_GET(isDirectory, ctx) {
	return JSValueMakeBoolean(ctx, YES);
}

EJ_BIND_FUNCTION(getDirectory, ctx, argc, argv) {
	EJ_MIN_ARGS(argc, 1)
	
	if(argc >= 2 && !JSValueIsObject(ctx, argv[1])) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return NULL;
	} else if(argc >= 3 && !JSValueIsObject(ctx, argv[2])) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return NULL;
	} else if(argc >= 4 && !JSValueIsObject(ctx, argv[3])) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return NULL;
	}
	
	NSString *directory = [JSValueToNSString(ctx, argv[0]) retain];
	JSObjectRef options = NULL;
	JSObjectRef callback = NULL;
	JSObjectRef errorCallback = NULL;
	
	if(argc >= 2) {
		options = JSValueToObject(ctx, argv[1], NULL);
		JSValueProtect(ctx, options);
	}
	
	if(argc >= 3) {
		callback = JSValueToObject(ctx, argv[2], NULL);
		JSValueProtect(ctx, callback);
	}
	
	if(argc >= 4) {
		errorCallback = JSValueToObject(ctx, argv[3], NULL);
		JSValueProtect(ctx, errorCallback);
	}
	
	NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:@selector(getDirectoryForPath:options:callback:errorCallback:)];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setTarget:self];
	[invocation setSelector:@selector(getDirectoryForPath:options:callback:errorCallback:)];
	[invocation setArgument:&directory atIndex:2];
	[invocation setArgument:&options atIndex:3];
	[invocation setArgument:&callback atIndex:4];
	[invocation setArgument:&errorCallback atIndex:5];
	[invocation performSelectorInBackground:@selector(invoke) withObject:nil];
	
	return NULL;
}

- (void)getDirectoryForPath:(NSString *)directory options:(JSObjectRef)options callback:(JSObjectRef)callback errorCallback:(JSObjectRef)errorCallback {
	JSContextRef ctx = controller.jsGlobalContext;
	
	BOOL create = NO;
	BOOL exclusive = NO;
	
	if(options) {
		JSStringRef createString = JSStringCreateWithCFString((CFStringRef)@"create");
		JSStringRef exclusiveString = JSStringCreateWithCFString((CFStringRef)@"exclusive");
		
		if(JSObjectHasProperty(ctx, options, createString)) {
			JSValueRef createValue = JSObjectGetProperty(ctx, options, createString, NULL);
			
			create = JSValueToBoolean(ctx, createValue);
			
			if(JSObjectHasProperty(ctx, options, exclusiveString)) {
				JSValueRef exclusiveValue = JSObjectGetProperty(ctx, options, exclusiveString, NULL);
				
				exclusive = JSValueToBoolean(ctx, exclusiveValue);
			}
		}
		
		JSStringRelease(createString);
		JSStringRelease(exclusiveString);
	}
	
	NSString *path = [self.fullPath stringByAppendingPathComponent:directory];
	
	BOOL isDir;
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
	JSValueRef error = NULL;
	
	if(create) {
		if((fileExists && exclusive) || (fileExists && !isDir)) {
			if(errorCallback) {
				error = JSMakeError(ctx, @"File exists or is not a directory.");
				
				[controller invokeCallback:errorCallback thisObject:NULL argc:1 argv:(JSValueRef *)&error];
			}
		} else if(!fileExists) {
			NSError *err;
			
			if(![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&err]) {
				if(errorCallback) {
					error = NSErrorToJSValue(ctx, err);
					
					[controller invokeCallback:errorCallback thisObject:NULL argc:1 argv:(JSValueRef *)&error];
				}
			}
		}
	} else {
		if(!fileExists) {
			if(errorCallback) {
				error = JSMakeError(ctx, @"Directory does not exist.");
				
				[controller invokeCallback:errorCallback thisObject:NULL argc:1 argv:(JSValueRef *)&error];
			}
		}
	}
	
	if(!error) {
		MJSDirectoryEntry *dirEntry = [[MJSDirectoryEntry alloc] initWithPath:path context:ctx];
		dirEntry.fileSystem = self.fileSystem;
		JSObjectRef dirEntryObjRef = [MJSDirectoryEntry createJSObjectWithContext:ctx controller:controller instance:dirEntry];
		
		if(callback) {
			[controller invokeCallback:callback thisObject:NULL argc:1 argv:(JSValueRef *)&dirEntryObjRef];
		}
		
		[dirEntry release];
	}
	
	[directory release];
	
	if(options) {
		JSValueUnprotect(ctx, options);
	}
	
	if(callback) {
		JSValueUnprotect(ctx, callback);
	}
	
	if(errorCallback) {
		JSValueUnprotect(ctx, errorCallback);
	}
}

EJ_BIND_FUNCTION_NOT_IMPLEMENTED(createReader)
EJ_BIND_FUNCTION_NOT_IMPLEMENTED(getFile)
EJ_BIND_FUNCTION_NOT_IMPLEMENTED(removeRecursively)

@end
