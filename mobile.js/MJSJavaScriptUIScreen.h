//
//  MJSJavaScriptUIScreen.h
//  mobile.js
//
//  Created by Grant Butler on 3/28/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "EJBindingBase.h"

@interface MJSJavaScriptUIScreen : EJBindingBase {
	@protected
		UIViewController *_viewController;
}

@property (nonatomic, retain, readonly) UIViewController *viewController;

- (void)makeViewController; // Made available for subclasses. The view controller you create
							// should be assigned to _viewController.

@end
