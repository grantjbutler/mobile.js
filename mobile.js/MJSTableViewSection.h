//
//  MJSTableViewSection.h
//  mobile.js
//
//  Created by Grant Butler on 4/27/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "EJBindingBase.h"

@class MJSJavaScriptUITableView;

@interface MJSTableViewSection : EJBindingBase

@property (nonatomic, assign) MJSJavaScriptUITableView *tableView;
@property (nonatomic, retain, readonly) NSArray *cells;

@end
