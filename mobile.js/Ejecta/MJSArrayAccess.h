//
//  MJSArrayAccess.h
//  mobile.js
//
//  Created by Grant Butler on 3/10/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "EJBindingBase.h"

@interface MJSArrayAccess : EJBindingBase

@property (nonatomic, assign, getter = isMutable) BOOL mutable;

@end
