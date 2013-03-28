//
//  MJSJavaScriptFileSystem.m
//  mobile.js
//
//  Created by Grant Butler on 11/22/12.
//  Copyright (c) 2012 Grant Butler. All rights reserved.
//

#import "MJSFileSystem.h"
#import "MJSGlobalObject+LocalFileSystem.h"
#import "MJSDirectoryEntry.h"
#import "EJClassLoader.h"

@implementation MJSFileSystem {
	NSURL *_rootPath;
	NSString *_name;
	
	MJSDirectoryEntry *_root;
}

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if((self = [super initWithContext:ctxp argc:argc argv:argv])) {
		double type = JSValueToNumberFast(ctxp, argv[0]);
		
		if(type == kMJSFileSystemTypePersistent) {
			_rootPath = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] copy];
			_name = [[[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey] stringByAppendingString:@":Persistent"] copy];
		} else if(type == kMJSFileSystemTypeTemporary) {
			_rootPath = [[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] copy];
			_name = [[[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey] stringByAppendingString:@":Temporary"] copy];
		} else {
			[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
			
			[self release];
			
			return nil;
		}
		
		_root = [[MJSDirectoryEntry alloc] initWithPath:[_rootPath path] context:ctxp];
		_root.fileSystem = self;
	}
	
	return self;
}

EJ_BIND_GET(name, ctx) {
	return NSStringToJSValue(ctx, _name);
}

EJ_BIND_GET(root, ctx) {
	return [MJSDirectoryEntry createJSObjectWithContext:ctx controller:controller instance:_root];
}

- (void)dealloc {
	[_rootPath release];
	_rootPath = nil;
	
	[_name release];
	_name = nil;
	
	[_root release];
	_root = nil;
	
	[super dealloc];
}

@end
