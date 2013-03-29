//
//  MJSJavaScriptUIScrollView.m
//  mobile.js
//
//  Created by Grant Butler on 3/28/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSJavaScriptUIScrollView.h"

@implementation MJSJavaScriptUIScrollView

+ (Class)backingViewClass {
	return [UIScrollView class];
}

- (UIScrollView *)scrollView {
	return (UIScrollView *)self.backingView;
}

@end
