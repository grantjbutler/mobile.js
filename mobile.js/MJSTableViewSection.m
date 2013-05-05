//
//  MJSTableViewSection.m
//  mobile.js
//
//  Created by Grant Butler on 4/27/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSTableViewSection.h"
#import "MJSTableViewContentCell.h"

@implementation MJSTableViewSection {
	NSMutableArray *_cells;
}

@synthesize cells = _cells;

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if((self = [super initWithContext:ctxp argc:argc argv:argv])) {
		_cells = [[NSMutableArray alloc] init];
	}
	
	return self;
}

EJ_BIND_FUNCTION(addCell, ctx, argc, argv) {
	EJ_MIN_ARGS(argc, 1)
	
	if(!JSValueIsObject(ctx, argv[0])) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return NULL;
	}
	
	JSObjectRef obj = JSValueToObject(ctx, argv[0], NULL);
	
	MJSTableViewContentCell *contentCell = [[MJSTableViewContentCell alloc] initWithContext:ctx argc:0 argv:NULL];
	JSObjectRef contentCellObject = [MJSTableViewContentCell createJSObjectWithContext:ctx controller:controller instance:contentCell];
	
	JSValueProtect(ctx, obj);
	contentCell.jsConfigureFunction = obj;
	
	[_cells addObject:contentCell];
	
	return contentCellObject;
}

@end
