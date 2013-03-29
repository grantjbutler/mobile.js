#import "EJClassLoader.h"
#import "EJBindingBase.h"
#import "MJSMobileJSController.h"


static NSMutableDictionary *EJGlobalJSClassCache;
static NSMutableDictionary *EJGlobalJSConstructorCache;

typedef struct {
	Class class;
	MJSMobileJSController *controller;
} EJClassWithController;

JSObjectRef EJCallAsConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
	
	// Unpack the class and scriptView from the constructor's private data
	EJClassWithController *classWithController = (EJClassWithController *)JSObjectGetPrivate(constructor);
	Class class = classWithController->class;
	MJSMobileJSController *controller = classWithController->controller;
	
	// Init the native class and create the JSObject with it
	EJBindingBase *instance = [(EJBindingBase *)[class alloc] initWithContext:ctx argc:argc argv:argv];
	JSObjectRef obj = [class createJSObjectWithContext:ctx controller:controller instance:instance];
	[instance release];
	
	return obj;
}

bool MJSHasInstance(JSContextRef ctx, JSObjectRef constructor, JSValueRef possibleInstance, JSValueRef* exception) {
	EJClassWithController *classWithController = (EJClassWithController *)JSObjectGetPrivate(constructor);
	JSObjectRef obj = JSValueToObject(ctx, possibleInstance, NULL);
	id instance = JSObjectGetPrivate(obj);
	
	return [instance isKindOfClass:classWithController->class];
}

void EJConstructorFinalize(JSObjectRef object) {
	EJClassWithController *classWithController = (EJClassWithController *)JSObjectGetPrivate(object);
	free(classWithController);
}


@implementation EJClassLoader

+ (JSClassRef)getJSConstructor:(id)class {
	JSClassRef jsConstructor = [EJGlobalJSConstructorCache[class] pointerValue];
	if(jsConstructor) {
		return jsConstructor;
	}
	
	jsConstructor = [self createJSConstructor:class];
	EJGlobalJSConstructorCache[class] = [NSValue valueWithPointer:jsConstructor];
	return jsConstructor;
}

+ (JSClassRef)createJSConstructor:(id)class {
	// Gather all class methods that return C callbacks for this class or it's parents
//	NSMutableArray *methods = [[NSMutableArray alloc] init];
	NSMutableArray *properties = [[NSMutableArray alloc] init];
	
	// Traverse this class and all its super classes
	Class base = EJBindingBase.class;
	for( Class sc = class; sc != base && [sc isSubclassOfClass:base]; sc = sc.superclass ) {
		
		// Traverse all class methods for this class; i.e. all classes that are defined with the
		// EJ_BIND_CONST macros
		u_int count;
		Method *methodList = class_copyMethodList(object_getClass(sc), &count);
		for (int i = 0; i < count ; i++) {
			SEL selector = method_getName(methodList[i]);
			NSString *name = NSStringFromSelector(selector);
			
			/*if( [name hasPrefix:@"_ptr_to_func_"] ) {
				[methods addObject: [name substringFromIndex:sizeof("_ptr_to_func_")-1] ];
			}
			else*/ if( [name hasPrefix:@"_ptr_to_const_"] ) {
				// We only look for getters - a property that has a setter, but no getter will be ignored
				[properties addObject: [name substringFromIndex:sizeof("_ptr_to_const_")-1] ];
			}
		}
		free(methodList);
	}
	
	
	// Set up the JSStaticValue struct array
	JSStaticValue *values = calloc( properties.count + 1, sizeof(JSStaticValue) );
	for( int i = 0; i < properties.count; i++ ) {
		NSString *name = properties[i];
		
		values[i].name = name.UTF8String;
		values[i].attributes = kJSPropertyAttributeDontDelete;
		
		SEL get = NSSelectorFromString([@"_ptr_to_const_" stringByAppendingString:name]);
		values[i].getProperty = (JSObjectGetPropertyCallback)[class performSelector:get];
		values[i].attributes |= kJSPropertyAttributeReadOnly;
	}
	
	// Set up the JSStaticFunction struct array
//	JSStaticFunction *functions = calloc( methods.count + 1, sizeof(JSStaticFunction) );
//	for( int i = 0; i < methods.count; i++ ) {
//		NSString *name = methods[i];
//		
//		functions[i].name = name.UTF8String;
//		functions[i].attributes = kJSPropertyAttributeDontDelete;
//		
//		SEL call = NSSelectorFromString([@"_ptr_to_func_" stringByAppendingString:name]);
//		functions[i].callAsFunction = (JSObjectCallAsFunctionCallback)[class performSelector:call];
//	}
	
	JSClassDefinition constructorClassDef = kJSClassDefinitionEmpty;
	
	constructorClassDef.callAsConstructor = EJCallAsConstructor;
	constructorClassDef.finalize = EJConstructorFinalize;
	constructorClassDef.staticValues = values;
	constructorClassDef.hasInstance = MJSHasInstance;
	
	NSString *className = NSStringFromClass(class);
	
	if([className hasPrefix:@"MJS"]) {
		className = [className substringFromIndex:3];
	}
	
	if([className hasPrefix:@"JavaScript"]) {
		className = [className substringFromIndex:10];
	}
	
	if([className hasPrefix:@"UI"]) {
		className = [className substringFromIndex:2];
	}
	
	constructorClassDef.className = [[className stringByAppendingString:@"Constructor"] UTF8String];
	
	JSClassRef jsConstructor = JSClassCreate(&constructorClassDef);
	
	free( values );
//	free( functions );
	
	[properties release];
//	[methods release];
	
	return jsConstructor;
}

+ (JSClassRef)getJSClass:(id)class {
	// Try the cache first
	JSClassRef jsClass = [EJGlobalJSClassCache[class] pointerValue];
	if( jsClass ) {
		return jsClass;
	}
	
	// Still here? Create and insert into cache
	jsClass = [self createJSClass:class];
	EJGlobalJSClassCache[class] = [NSValue valueWithPointer:jsClass];
	return jsClass;
}

+ (JSClassRef)createJSClass:(id)class {
	// Gather all class methods that return C callbacks for this class or it's parents
	NSMutableArray *methods = [[NSMutableArray alloc] init];
	NSMutableArray *properties = [[NSMutableArray alloc] init];
		
	// Traverse this class and all its super classes
	Class base = EJBindingBase.class;
	for( Class sc = class; sc != base && [sc isSubclassOfClass:base]; sc = sc.superclass ) {
	
		// Traverse all class methods for this class; i.e. all classes that are defined with the
		// EJ_BIND_FUNCTION, EJ_BIND_GET or EJ_BIND_SET macros
		u_int count;
		Method *methodList = class_copyMethodList(object_getClass(sc), &count);
		for (int i = 0; i < count ; i++) {
			SEL selector = method_getName(methodList[i]);
			NSString *name = NSStringFromSelector(selector);
			
			if( [name hasPrefix:@"_ptr_to_func_"] ) {
				[methods addObject: [name substringFromIndex:sizeof("_ptr_to_func_")-1] ];
			}
			else if( [name hasPrefix:@"_ptr_to_get_"] ) {
				// We only look for getters - a property that has a setter, but no getter will be ignored
				[properties addObject: [name substringFromIndex:sizeof("_ptr_to_get_")-1] ];
			}
		}
		free(methodList);
	}
	
	
	// Set up the JSStaticValue struct array
	JSStaticValue *values = calloc( properties.count + 1, sizeof(JSStaticValue) );
	for( int i = 0; i < properties.count; i++ ) {
		NSString *name = properties[i];
		
		values[i].name = name.UTF8String;
		values[i].attributes = kJSPropertyAttributeDontDelete;
		
		SEL get = NSSelectorFromString([@"_ptr_to_get_" stringByAppendingString:name]);
		values[i].getProperty = (JSObjectGetPropertyCallback)[class performSelector:get];
		
		// Property has a setter? Otherwise mark as read only
		SEL set = NSSelectorFromString([@"_ptr_to_set_"stringByAppendingString:name]);
		if( [class respondsToSelector:set] ) {
			values[i].setProperty = (JSObjectSetPropertyCallback)[class performSelector:set];
		}
		else {
			values[i].attributes |= kJSPropertyAttributeReadOnly;
		}
	}
	
	// Set up the JSStaticFunction struct array
	JSStaticFunction *functions = calloc( methods.count + 1, sizeof(JSStaticFunction) );
	for( int i = 0; i < methods.count; i++ ) {
		NSString *name = methods[i];
				
		functions[i].name = name.UTF8String;
		functions[i].attributes = kJSPropertyAttributeDontDelete;
		
		SEL call = NSSelectorFromString([@"_ptr_to_func_" stringByAppendingString:name]);
		functions[i].callAsFunction = (JSObjectCallAsFunctionCallback)[class performSelector:call];
	}
	
	JSClassDefinition classDef = kJSClassDefinitionEmpty;
	
	NSString *className = NSStringFromClass(class);
	
	if([className hasPrefix:@"MJS"]) {
		className = [className substringFromIndex:3];
	}
	
	if([className hasPrefix:@"JavaScript"]) {
		className = [className substringFromIndex:10];
	}
	
	if([className hasPrefix:@"UI"]) {
		className = [className substringFromIndex:2];
	}
	
	classDef.className = [className UTF8String];
	classDef.finalize = EJBindingBaseFinalize;
	classDef.staticValues = values;
	classDef.staticFunctions = functions;
	
	Class superClass = [class superclass];
	
	if(superClass != [EJBindingBase class]) {
		classDef.parentClass = [self getJSClass:superClass];
	}
	
	if([class instancesRespondToSelector:@selector(hasProperty:context:)]) {
		classDef.hasProperty = MJSHasProperty;
	}
	
	if([class instancesRespondToSelector:@selector(getProperty:context:)]) {
		classDef.getProperty = MJSGetProperty;
	}
	
	if([class instancesRespondToSelector:@selector(setProperty:value:context:)]) {
		classDef.setProperty = MJSSetProperty;
	}
	
	if([class instancesRespondToSelector:@selector(deleteProperty:context:)]) {
		classDef.deleteProperty = MJSDeleteProperty;
	}
	
	if([class instancesRespondToSelector:@selector(performFunction:argc:argv:context:)]) {
		classDef.callAsFunction = MJSCallAsFunction;
	}
	
	JSClassRef jsClass = JSClassCreate(&classDef);
	
	free( values );
	free( functions );
	
	[properties release];
	[methods release];
	
	return jsClass;
}

+ (void)initialize {
	if(self == [EJClassLoader class]) {
		EJGlobalJSClassCache = [[NSMutableDictionary alloc] initWithCapacity:16];
		EJGlobalJSConstructorCache = [[NSMutableDictionary alloc] initWithCapacity:16];
		
		atexit_b(^{
			[EJGlobalJSClassCache release];
			[EJGlobalJSConstructorCache release];
		});
	}
}

+ (JSValueRef)getConstructorOfClass:(id)class controller:(MJSMobileJSController *)controller context:(JSContextRef)ctx {
	if(![class isSubclassOfClass:EJBindingBase.class]) {
		return controller->jsUndefined;
	}
	
	// Pack the class together with the controller into a struct, so it can
	// be put in the constructor's private data
	EJClassWithController *classWithController = malloc(sizeof(EJClassWithController));
	classWithController->class = class;
	classWithController->controller = controller;
	
	return JSObjectMake( ctx, [self getJSConstructor:class], (void *)classWithController );
}

@end

