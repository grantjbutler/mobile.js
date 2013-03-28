//
//  MJSLocalFileSystem.h
//  mobile.js
//
//  Created by Grant Butler on 11/22/12.
//  Copyright (c) 2012 Grant Butler. All rights reserved.
//

#import "MJSGlobalObject.h"

typedef enum {
	kMJSFileSystemTypeTemporary = 0,
	kMJSFileSystemTypePersistent = 1,
} kMJSFileSystemType;

@interface MJSGlobalObject (LocalFileSystem)

@end
