//
//  MJSIndexPath.h
//  mobile.js
//
//  Created by Grant Butler on 5/5/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "EJBindingBase.h"

@interface MJSIndexPath : EJBindingBase

@property (nonatomic, retain, readonly) NSIndexPath *indexPath;

- (id)initWithIndexPath:(NSIndexPath *)indexPath;

@end
