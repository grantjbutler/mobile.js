//
//  MJSJavaScriptUITableView.m
//  mobile.js
//
//  Created by Grant Butler on 3/29/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "MJSJavaScriptUITableView.h"
#import "MJSTableViewSection.h"
#import "MJSJavaScriptUITableViewCell.h"
#import "MJSTableViewContentCell.h"
#import "MJSTableViewCell.h"
#import "MJSJavaScriptUITableViewCell.h"
#import "MJSIndexPath.h"

@interface MJSJavaScriptUITableView () <UITableViewDataSource>

@end

@implementation MJSJavaScriptUITableView {
	NSMutableArray *_sections;
	
	NSMutableArray *_reusableCells;
}

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if((self = [super initWithContext:ctxp argc:argc argv:argv])) {
		_sections = [[NSMutableArray alloc] init];
		
		_reusableCells = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)makeBackingViewWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	EJ_MIN_ARGS_NO_RETURN(argc, 1)
	
	UITableViewStyle style = JSValueToNumberFast(ctxp, argv[0]);
	
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
	tableView.dataSource = self;
	
	_backingView = tableView;
}

- (UITableView *)tableView {
	return (UITableView *)_backingView;
}

#pragma mark - Data Methods

EJ_BIND_FUNCTION(addSection, ctx, argc, argv) {
	EJ_MIN_ARGS(argc, 1)
	
	if(!JSValueIsObject(ctx, argv[0])) {
		[MJSExceptionForType(MJSInvalidArgumentTypeException) raise];
		
		return NULL;
	}
	
	JSObjectRef obj = JSValueToObject(ctx, argv[0], NULL);
	
	MJSTableViewSection *section = [[MJSTableViewSection alloc] initWithContext:ctx argc:0 argv:NULL];
	JSObjectRef sectionObject = [MJSTableViewSection createJSObjectWithContext:ctx controller:controller instance:section];
	
	JSObjectRef args[] = {
		sectionObject
	};
	
	[controller invokeCallback:obj thisObject:jsObject argc:1 argv:(JSValueRef *)args];
	
	[_sections addObject:section];
	
	return NULL;
}

#pragma mark - Constants

EJ_BIND_STATIC_CONST(PLAIN_STYLE, UITableViewStylePlain)
EJ_BIND_STATIC_CONST(GROUPED_STYLE, UITableViewStyleGrouped)

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	MJSTableViewSection *tableViewSection = _sections[section];
	
	return [tableViewSection.cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MJSTableViewSection *tableViewSection = _sections[indexPath.section];
	MJSTableViewContentCell *contentCell = tableViewSection.cells[indexPath.row];
	
	MJSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contentCell.reuseIdentifier];
	MJSJavaScriptUITableViewCell *jsCell = cell.jsObject;
	
	if(!cell) {
		cell = [[MJSTableViewCell alloc] initWithStyle:contentCell.style reuseIdentifier:contentCell.reuseIdentifier];
		jsCell = [[MJSJavaScriptUITableViewCell alloc] initWithView:cell];
		cell.jsObject = jsCell;
		[MJSJavaScriptUITableViewCell createJSObjectWithContext:controller.jsGlobalContext controller:controller instance:jsCell];
		
		JSValueProtect(controller.jsGlobalContext, jsCell.jsObject);
		
		[_reusableCells addObject:jsCell];
	}
	
	MJSIndexPath *jsIndexPath = [[MJSIndexPath alloc] initWithIndexPath:indexPath];
	JSObjectRef indexPathObject = [MJSIndexPath createJSObjectWithContext:controller.jsGlobalContext controller:controller instance:jsIndexPath];
	
	JSObjectRef cellObject = jsCell.jsObject;
	
	JSObjectRef args[] = {
		cellObject,
		indexPathObject
	};
	
	[controller invokeCallback:contentCell.jsConfigureFunction thisObject:jsCell.jsObject argc:2 argv:(JSValueRef *)args];
	
	return cell;
}

- (void)dealloc {
	[_sections release];
	_sections = nil;
	
	for(MJSJavaScriptUITableViewCell *cell in _reusableCells) {
		JSValueUnprotectSafe(controller.jsGlobalContext, cell.jsObject);
	}
	
	[_reusableCells release];
	_reusableCells = nil;
	
	[super dealloc];
}

@end
