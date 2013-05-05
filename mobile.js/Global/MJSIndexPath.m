//
//  MJSIndexPath.m
//  mobile.js
//
//  Created by Grant Butler on 5/5/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSIndexPath.h"

@implementation MJSIndexPath

- (id)initWithIndexPath:(NSIndexPath *)indexPath {
	if((self = [super init])) {
		_indexPath = [indexPath copy];
	}
	
	return self;
}

EJ_BIND_GET(section, ctx) {
	return JSValueMakeNumber(ctx, self.indexPath.section);
}

EJ_BIND_GET(row, ctx) {
	return JSValueMakeNumber(ctx, self.indexPath.row);
}

EJ_BIND_GET(item, ctx) {
	return JSValueMakeNumber(ctx, self.indexPath.item);
}

@end
