//
//  MJSEntry.m
//  mobile.js
//
//  Created by Grant Butler on 11/24/12.
//  Copyright (c) 2012 Grant Butler. All rights reserved.
//

#import "MJSEntry.h"

@implementation MJSEntry

- (id)initWithPath:(NSString *)path context:(JSContextRef)ctx {
	if((self = [super initWithContext:ctx argc:0 argv:NULL])) {
		_fullPath = [path copy];
	}
	
	return self;
}

EJ_BIND_GET(isFile, ctx) {
	return JSValueMakeBoolean(ctx, NO);
}

EJ_BIND_GET(isDirectory, ctx) {
	return JSValueMakeBoolean(ctx, NO);
}

EJ_BIND_GET(name, ctx) {
	return NSStringToJSValue(ctx, [self.fullPath lastPathComponent]);
}

EJ_BIND_GET(fullPath, ctx) {
	// TODO: Re-evaluate this. Docs say "The full absolute path from the root to the entry."
	return NSStringToJSValue(ctx, self.fullPath);
}

EJ_BIND_GET(filesystem, ctx) {
	return [MJSFileSystem createJSObjectWithContext:ctx controller:controller instance:self.fileSystem];
}

EJ_BIND_FUNCTION(getMetadata, ctx, argc, argv) {
	EJ_MIN_ARGS(argc, 1)
	
	if(!JSValueIsObject(ctx, argv[0])) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return NULL;
	} else if(argc >= 2 && !JSValueIsObject(ctx, argv[1])) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return NULL;
	}
	
	JSObjectRef callback = JSValueToObject(ctx, argv[0], NULL);
	JSValueProtect(ctx, callback);
	
	JSObjectRef errorCallback = NULL;
	
	if(argc >= 2) {
		errorCallback = JSValueToObject(ctx, argv[1], NULL);
		JSValueProtect(ctx, errorCallback);
	}
	
	NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:@selector(getMetadataWithCallback:errorCallback:)];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setTarget:self];
	[invocation setSelector:@selector(getMetadataWithCallback:errorCallback:)];
	[invocation setArgument:&callback atIndex:2];
	[invocation setArgument:&errorCallback atIndex:3];
	[invocation performSelectorInBackground:@selector(invoke) withObject:nil];
	
	return NULL;
}

- (void)getMetadataWithCallback:(JSObjectRef)callback errorCallback:(JSObjectRef)errorCallback {
	JSContextRef ctx = controller.jsGlobalContext;
	
	NSError *error;
	NSDictionary *attributes;
	
	if(!(attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.fullPath error:&error])) {
		if(errorCallback != NULL) {
			JSValueRef jsError = NSErrorToJSValue(ctx, error);
			
			[controller invokeCallback:errorCallback thisObject:NULL argc:1 argv:(JSValueRef *)&jsError];
		}
	} else {
		JSObjectRef jsObject_ = JSObjectMake(ctx, NULL, NULL);
		
		JSStringRef sizeString = JSStringCreateWithCFString((CFStringRef)@"size");
		JSValueRef size = NULL;
		
		if([attributes[NSFileType] isEqualToString:NSFileTypeDirectory]) {
			size = JSValueMakeNumber(ctx, 0.0);
		} else {
			size = JSValueMakeNumber(ctx, [attributes[NSFileSize] doubleValue]);
		}
		
		JSObjectSetProperty(ctx, jsObject_, sizeString, size, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete, NULL);
		
		JSStringRef modificationTimeString = JSStringCreateWithCFString((CFStringRef)@"modificationTime");
		
		JSValueRef timestampValue = JSValueMakeNumber(ctx, [attributes[NSFileModificationDate] timeIntervalSince1970] * 1000);
		JSObjectRef modificationDate = JSObjectMakeDate(ctx, 1, (JSValueRef *)&timestampValue, NULL);
		
		JSObjectSetProperty(ctx, jsObject_, modificationTimeString, modificationDate, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete, NULL);
		
		[controller invokeCallback:callback thisObject:NULL argc:1 argv:(JSValueRef *)&jsObject_];
	}
	
	JSValueUnprotect(ctx, callback);
	
	if(errorCallback != NULL) {
		JSValueUnprotect(ctx, errorCallback);
	}
}

EJ_BIND_FUNCTION_NOT_IMPLEMENTED(moveTo)
EJ_BIND_FUNCTION_NOT_IMPLEMENTED(copyTo)
EJ_BIND_FUNCTION_NOT_IMPLEMENTED(toURL)
EJ_BIND_FUNCTION_NOT_IMPLEMENTED(remove)
EJ_BIND_FUNCTION_NOT_IMPLEMENTED(getParent)

- (void)dealloc {
	[_fileSystem release];
	_fileSystem = nil;
	
	[super dealloc];
}

@end
