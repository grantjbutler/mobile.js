//
//  MJSJavaScriptUITableViewData.h
//  mobile.js
//
//  Created by Grant Butler on 3/29/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "EJBindingBase.h"

@interface MJSJavaScriptUITableViewData : EJBindingBase  <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy, readonly) NSString *cellReuseIdentifier;
@property (nonatomic, retain, readonly) UITableViewCell *reusableCell;
@property (nonatomic, assign, readonly) NSInteger count;

- (JSObjectRef)objectAtIndex:(NSInteger)index;

@end
