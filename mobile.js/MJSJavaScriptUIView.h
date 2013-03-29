//
//  MJSJavaScriptUIView.h
//  mobile.js
//
//  Created by Grant Butler on 3/28/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "EJBindingEventedBase.h"

@interface MJSJavaScriptUIView : EJBindingEventedBase {
	@protected
		UIView *_backingView;
}

@property (nonatomic, retain, readonly) UIView *backingView;

// Use this if you have an existing view in code that you want to be made accessible to JavaScript.
- (id)initWithView:(UIView *)view;

// Made available for subclasses. Provide the class of the view you want instansiated.
+ (Class)backingViewClass;

// Made available for subclasses. Override to perform custom instantiating logic for your view.
// The view you create should be assigned to _backingView.
- (void)makeBackingViewWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv;

@end
