//
//  MJSEntry.h
//  mobile.js
//
//  Created by Grant Butler on 11/24/12.
//  Copyright (c) 2012 Grant Butler. All rights reserved.
//

#import "EJBindingBase.h"
#import "MJSFileSystem.h"

@interface MJSEntry : EJBindingBase

@property (nonatomic, retain) MJSFileSystem *fileSystem;

@property (nonatomic, copy) NSString *fullPath;

- (id)initWithPath:(NSString *)path context:(JSContextRef)ctx;

@end
