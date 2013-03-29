//
//  MJSJavaScriptUITableViewData.m
//  mobile.js
//
//  Created by Grant Butler on 3/29/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSJavaScriptUITableViewData.h"
#import "MJSJavaScriptUITableViewCell.h"

@implementation MJSJavaScriptUITableViewData {
	JSObjectRef _data;
	JSObjectRef _reusableCell;
	
	NSMutableDictionary *_bindings;
}

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if((self = [super initWithContext:ctxp argc:argc argv:argv])) {
		_bindings = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (void)dealloc {
	for(NSString *key in _bindings) {
		id binding = _bindings[key];
		
		if([binding isKindOfClass:[NSValue class]]) {
			JSObjectRef object = (JSObjectRef)[(NSValue *)binding pointerValue];
			
			JSValueUnprotectSafe(controller.jsGlobalContext, object);
		}
	}
	
	JSValueUnprotectSafe(controller.jsGlobalContext, _data);
	JSValueUnprotectSafe(controller.jsGlobalContext, _reusableCell);
	
	[super dealloc];
}

- (NSInteger)count {
	if(!_data) {
		return 0;
	}
	
	JSStringRef lengthString = JSStringCreateWithCFString(CFSTR("length"));
	JSValueRef length = JSObjectGetProperty(controller.jsGlobalContext, _data, lengthString, NULL);
	JSStringRelease(lengthString);
	
	return JSValueToNumber(controller.jsGlobalContext, length, NULL);
}

- (JSObjectRef)objectAtIndex:(NSInteger)index {
	if(!_data) {
		return NULL;
	}
	
	JSStringRef indexString = JSStringCreateWithUTF8CString([[NSString stringWithFormat:@"%d", index] UTF8String]);
	JSValueRef object = JSObjectGetProperty(controller.jsGlobalContext, _data, indexString, NULL);
	JSStringRelease(indexString);
	
	return JSValueToObject(controller.jsGlobalContext, object, NULL);
}

- (NSString *)cellReuseIdentifier {
	return self.reusableCell.reuseIdentifier;
}

- (UITableViewCell *)reusableCell {
	JSObjectRef jsObject_ = JSValueToObject(controller.jsGlobalContext, _reusableCell, NULL);
	return (UITableViewCell *)JSObjectGetPrivate(jsObject_);
}

#pragma mark - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellReuseIdentifier];
	
	if(!cell) {
		NSData *tempArchivedCell = [NSKeyedArchiver archivedDataWithRootObject:self.reusableCell];
		cell = (UITableViewCell *)[NSKeyedUnarchiver unarchiveObjectWithData:tempArchivedCell];
	}
	
	// TODO: Iterate over bindings to set everything.
	
	return cell;
}

#pragma mark - Properties

EJ_BIND_GET(data, ctx) {
	return _data;
}

EJ_BIND_SET(data, ctx, newData) {
	JSValueUnprotectSafe(ctx, _data);
	
	JSValueProtect(ctx, newData);
	_data = JSValueToObject(ctx, newData, NULL);
}

EJ_BIND_GET(reusableCell, ctx) {
	return _reusableCell;
}

EJ_BIND_SET(reusableCell, ctx, newCell) {
	if(!JSValueIsObject(ctx, newCell)) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return;
	}
	
	JSObjectRef jsObject_ = JSValueToObject(ctx, newCell, NULL);
	id instance = JSObjectGetPrivate(jsObject_);
	
	if(![instance isKindOfClass:[MJSJavaScriptUITableViewCell class]]) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return;
	}
	
	JSValueUnprotectSafe(ctx, _reusableCell);
	
	JSValueProtect(ctx, jsObject_);
	_reusableCell = jsObject_;
}

#pragma mark - Methods

// .createBinding('textLabel.text', 'username');
// .createBinding('imageView.image', function(object) {
//										if(object.isUnread) {
//											var img = new UI.Image();
//											img.src = 'app://unreadIndicator.png';
//											return img;
//										}
//									});
EJ_BIND_FUNCTION(createBinding, ctx, argc, argv) {
	EJ_MIN_ARGS(argc, 2)
	
	if(!JSValueIsString(ctx, argv[0])) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return NULL;
	}
	
	if(!JSValueIsString(ctx, argv[1]) || !JSValueIsObject(ctx, argv[1])) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return NULL;
	}
	
	NSString *keyPath = JSValueToNSString(ctx, argv[0]);
	id binding = nil;
	
	if(JSValueIsString(ctx, argv[1])) {
		binding = JSValueToNSString(ctx, argv[1]);
	} else if(JSValueIsObject(ctx, argv[1])) {
		JSObjectRef callbackFunction = JSValueToObject(ctx, argv[1], NULL);
		JSValueProtect(ctx, callbackFunction);
		
		binding = [NSValue valueWithPointer:callbackFunction];
	}
	
	if(binding) {
		_bindings[keyPath] = binding;
	}
	
	return NULL;
}

@end
