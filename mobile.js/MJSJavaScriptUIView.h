//
//  MJSJavaScriptUIView.h
//  mobile.js
//
//  Created by Grant Butler on 3/28/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "EJBindingBase.h"

@interface MJSJavaScriptUIView : EJBindingBase {
	@protected
		UIView *_backingView;
}

@property (nonatomic, retain, readonly) UIView *backingView;

- (id)initWithView:(UIView *)view; // Use this if you have an existing view in code that
								   // you want to be made accessible to JavaScript.

- (void)makeBackingView; //Made available for subclasses. The view you create should be
						 // assigned to _backingView.

@end
