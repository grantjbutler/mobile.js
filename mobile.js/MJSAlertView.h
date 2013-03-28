//
//  MJSAlertView.h
//  mobile.js
//
//  Created by Grant Butler on 11/20/12.
//  Copyright (c) 2012 Grant Butler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MJSAlertView;

typedef void(^MJSAlertViewHandler)(MJSAlertView *alertView);

@interface MJSAlertView : UIAlertView <UIAlertViewDelegate>

- (id)initWithTitle:(NSString *)title message:(NSString *)message;

- (NSInteger)addButtonWithTitle:(NSString *)title withHandler:(MJSAlertViewHandler)handler;
- (NSInteger)addCancelButtonWithTitle:(NSString *)title withHandler:(MJSAlertViewHandler)handler;

@end
