#import "EJBindingBase.h"
#import "EJClassLoader.h"
#import "EJConvert.h"
#import <objc/runtime.h>


@implementation EJBindingBase

@synthesize controller;
@synthesize jsObject;

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super init] ) {
	}
	return self;
}

- (void)createWithJSObject:(JSObjectRef)obj controller:(MJSMobileJSController *)controllerp {
	jsObject = obj;
	controller = controllerp;
}

- (void)prepareGarbageCollection {
	// Called in EJBindingBaseFinalize before sending 'release'.
	// Cancel loading callbacks and the like here.
}

+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx
	controller:(MJSMobileJSController *)controllerp
	instance:(EJBindingBase *)instance
{
	// Create JSObject with the JSClass for this ObjC-Class
	JSObjectRef obj = JSObjectMake( ctx, [EJClassLoader getJSClass:self], NULL );
	
	// The JSObject retains the instance; it will be released by EJBindingBaseFinalize
	JSObjectSetPrivate( obj, (void *)[instance retain] );
	[instance createWithJSObject:obj controller:controllerp];
	
	return obj;
}

void EJBindingBaseFinalize(JSObjectRef object) {
	id instance = (id)JSObjectGetPrivate(object);
	[instance prepareGarbageCollection];
	[instance release];
}

bool MJSHasProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName) {
	id<EJBindingBase> instance = (id<EJBindingBase>)JSObjectGetPrivate(object);
	
	NSString *name = [((NSString *)JSStringCopyCFString(kCFAllocatorDefault, propertyName)) autorelease];
	
	if([instance respondsToSelector:@selector(hasProperty:context:)]) {
		return [instance hasProperty:name context:ctx];
	}
	
	return NO;
}

JSValueRef MJSGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) {
	id<EJBindingBase> instance = (id)JSObjectGetPrivate(object);
	
	NSString *name = [((NSString *)JSStringCopyCFString(kCFAllocatorDefault, propertyName)) autorelease];
	
	JSValueRef res = NULL;
	
	if([instance respondsToSelector:@selector(getProperty:context:)]) {
		res = [instance getProperty:name context:ctx];
	}
	
	return res ? res : NULL;
}

bool MJSSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception) {
	id<EJBindingBase> instance = (id<EJBindingBase>)JSObjectGetPrivate(object);
	
	NSString *name = [((NSString *)JSStringCopyCFString(kCFAllocatorDefault, propertyName)) autorelease];
	
	if([instance respondsToSelector:@selector(setProperty:value:context:)]) {
		[instance setProperty:name value:value context:ctx];
		
		return true;
	}
	
	return false;
}

bool MJSDeleteProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) {
	id<EJBindingBase> instance = (id<EJBindingBase>)JSObjectGetPrivate(object);
	
	NSString *name = [((NSString *)JSStringCopyCFString(kCFAllocatorDefault, propertyName)) autorelease];
	
	if([instance respondsToSelector:@selector(deleteProperty:context:)]) {
		[instance deleteProperty:name context:ctx];
		
		return true;
	}
	
	return false;
}

JSValueRef MJSCallAsFunction(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
	id<EJBindingBase> instance = (id<EJBindingBase>)JSObjectGetPrivate(thisObject);
	
	if(!JSObjectIsFunction(ctx, function)) {
		return JSValueMakeUndefined(ctx);
	}
	
	NSString *name = JSValueToNSString(ctx, function);
	
	JSValueRef ret = NULL;
	
	if([instance respondsToSelector:@selector(performFunction:argc:argv:context:)]) {
		ret = [instance performFunction:name argc:argumentCount argv:(JSValueRef *)arguments context:ctx];
	}
	
	return ret ? ret : JSValueMakeUndefined(ctx);
}


@end
