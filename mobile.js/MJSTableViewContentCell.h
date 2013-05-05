//
//  MJSTableViewContentCell.h
//  mobile.js
//
//  Created by Grant Butler on 5/5/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "EJBindingBase.h"

@interface MJSTableViewContentCell : EJBindingBase

@property (nonatomic, assign) UITableViewCellStyle style;
@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic, assign) JSObjectRef jsConfigureFunction;

@end
