#import <Foundation/Foundation.h>
#import "MJSMobileJSController.h"
#import "EJConvert.h"
#import "MJSExceptions.h"

#include <objc/message.h>

// (Not sure if clever hack or really stupid...)

// All classes derived from this EJBindingBase will return a JSClassRef through the 
// 'getJSClass' class method. The properties and functions that are exposed to 
// JavaScript are defined through the 'staticFunctions' and 'staticValues' in this 
// JSClassRef.

// Since these functions don't have extra data (e.g. a void*), we have to define a 
// C callback function for each js function, for each js getter and for each js setter.

// Furthermore, a class method is added to the objc class to return the function pointer
// to the particular C callback function - this way we can later inflect the objc class
// and gather all function pointers.


#define EJ_BINDING_CLASS_PREFIX "MJSJavaScript"

// The class method that returns a pointer to the static C callback function
#define __EJ_GET_POINTER_TO(NAME) \
	+ (void *)_ptr_to##NAME { \
		return (void *)&NAME; \
	}


// ------------------------------------------------------------------------------------
// Function - use with EJ_BIND_FUNCTION( functionName, ctx, argc, argv ) { ... }

#define EJ_BIND_FUNCTION(NAME, CTX_NAME, ARGC_NAME, ARGV_NAME) \
	\
	/* The C callback function for the exposed method and class method that returns it */ \
	static JSValueRef _func_##NAME( \
		JSContextRef ctx, \
		JSObjectRef function, \
		JSObjectRef object, \
		size_t argc, \
		const JSValueRef argv[], \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		JSValueRef ret = NULL; \
		@try { \
			ret = (JSValueRef)objc_msgSend(instance, @selector(_func_##NAME:argc:argv:), ctx, argc, argv); \
		} @catch (NSException *e) { \
			if(exception != NULL) { \
				*exception = NSExceptionToJSValue(ctx, e); \
			} \
		} \
		return ret ? ret : ((EJBindingBase *)instance)->controller->jsUndefined; \
	} \
	__EJ_GET_POINTER_TO(_func_##NAME)\
	\
	/* The actual implementation for this method */ \
	- (JSValueRef)_func_##NAME:(JSContextRef)CTX_NAME argc:(size_t)ARGC_NAME argv:(const JSValueRef [])ARGV_NAME


// ------------------------------------------------------------------------------------
// Getter - use with EJ_BIND_GET( propertyName, ctx ) { ... }

#define EJ_BIND_GET(NAME, CTX_NAME) \
	\
	/* The C callback function for the exposed getter and class method that returns it */ \
	static JSValueRef _get_##NAME( \
		JSContextRef ctx, \
		JSObjectRef object, \
		JSStringRef propertyName, \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		return (JSValueRef)objc_msgSend(instance, @selector(_get_##NAME:), ctx); \
	} \
	__EJ_GET_POINTER_TO(_get_##NAME)\
	\
	/* The actual implementation for this getter */ \
	- (JSValueRef)_get_##NAME:(JSContextRef)CTX_NAME


// ------------------------------------------------------------------------------------
// Setter - use with EJ_BIND_SET( propertyName, ctx, value ) { ... }

#define EJ_BIND_SET(NAME, CTX_NAME, VALUE_NAME) \
	\
	/* The C callback function for the exposed setter and class method that returns it */ \
	static bool _set_##NAME( \
		JSContextRef ctx, \
		JSObjectRef object, \
		JSStringRef propertyName, \
		JSValueRef value, \
		JSValueRef* exception \
	) { \
		id instance = (id)JSObjectGetPrivate(object); \
		@try { \
			objc_msgSend(instance, @selector(_set_##NAME:value:), ctx, value); \
		} @catch(NSException *e) { \
			if(exception != NULL) { \
				*exception = NSExceptionToJSValue(ctx, e); \
			} \
			return false; \
		} \
		return true; \
	} \
	__EJ_GET_POINTER_TO(_set_##NAME) \
	\
	/* The actual implementation for this setter */ \
	- (void)_set_##NAME:(JSContextRef)CTX_NAME value:(JSValueRef)VALUE_NAME
		


// ------------------------------------------------------------------------------------
// Shorthand to define a function that logs a "not implemented" warning

#define EJ_BIND_FUNCTION_NOT_IMPLEMENTED(NAME) \
	static JSValueRef _func_##NAME( \
		JSContextRef ctx, \
		JSObjectRef function, \
		JSObjectRef object, \
		size_t argc, \
		const JSValueRef argv[], \
		JSValueRef* exception \
	) { \
		static bool didShowWarning; \
		if( !didShowWarning ) { \
			NSLog(@"Warning: method " @ #NAME @" is not yet implemented!"); \
			didShowWarning = true; \
		} \
		id instance = (id)JSObjectGetPrivate(object); \
		return ((EJBindingBase *)instance)->controller->jsUndefined; \
	} \
	__EJ_GET_POINTER_TO(_func_##NAME)


// ------------------------------------------------------------------------------------
// Shorthand to bind enums with name tables - use with
// EJ_BIND_ENUM( name, target, "name1", "name2", ...) );


#define EJ_BIND_ENUM(NAME, TARGET, ...) \
	static const char *_##NAME##EnumNames[] = {__VA_ARGS__}; \
	EJ_BIND_GET(NAME, ctx) { \
		JSStringRef src = JSStringCreateWithUTF8CString( _##NAME##EnumNames[TARGET] ); \
		JSValueRef ret = JSValueMakeString(ctx, src); \
		JSStringRelease(src); \
		return ret; \
	} \
	\
	EJ_BIND_SET(NAME, ctx, value) { \
		JSStringRef _str = JSValueToStringCopy(ctx, value, NULL); \
		const JSChar *_strptr = JSStringGetCharactersPtr( _str ); \
		int _length = JSStringGetLength(_str)-1; \
		const char ** _names = _##NAME##EnumNames; \
		int _target; \
		EJ_MAP_EXT(0, _EJ_LITERAL(else), _EJ_BIND_ENUM_COMPARE, __VA_ARGS__) \
		else { JSStringRelease( _str ); return; } \
		TARGET = _target; \
		JSStringRelease( _str );\
	}

#define _EJ_BIND_ENUM_COMPARE(INDEX, NAME) \
	if( _length == sizeof(NAME)-2 && JSStrIsEqualToStr( _strptr, _names[INDEX], _length) ) { _target = INDEX; }
	
static inline bool JSStrIsEqualToStr( const JSChar *s1, const char *s2, int length ) {
	for( int i = 0; i < length && *s1 == *s2; i++ ) {
		s1++;
		s2++;
	}
	return (*s1 == *s2);
}


// ------------------------------------------------------------------------------------
// Shorthand to bind const numbers

#define EJ_BIND_CONST(NAME, VALUE) \
	static JSValueRef _get_##NAME( \
		JSContextRef ctx, \
		JSObjectRef object, \
		JSStringRef propertyName, \
		JSValueRef* exception \
	) { \
		return JSValueMakeNumber(ctx, VALUE); \
	} \
	__EJ_GET_POINTER_TO(_get_##NAME)

#define EJ_BIND_STATIC_CONST(NAME, VALUE) \
	static JSValueRef _const_##NAME( \
		JSContextRef ctx, \
		JSObjectRef object, \
		JSStringRef propertyName, \
		JSValueRef* exception \
	) { \
		return JSValueMakeNumber(ctx, VALUE); \
	} \
	__EJ_GET_POINTER_TO(_const_##NAME)


// Commas can't be used directly in macro arguments
#define _EJ_COMMA() ,
#define _EJ_EMPTY()
#define _EJ_LITERAL(X) X _EJ_EMPTY


// ------------------------------------------------------------------------------------
// Expand a F(INDEX,ARG) macro for each argument, max 16 arguments - use with
// EJ_MAP( F, arg1, arg2, ... );

// An offset for the index as well as a joiner (a macro that is expanded between each
// F() expansion) can be specified with
// EJ_MAP_EXT( OFFSET, JOINER, F, arg1, arg2 );

// Adopted from https://github.com/swansontec/map-macro

#define EJ_MAP_EXT(OFFSET, JOINER, F, ...) _EJ_EVAL(_EJ_MAP1(OFFSET, JOINER, F, __VA_ARGS__, (), 0))
#define EJ_MAP(F, ...) _EJ_EVAL(_EJ_MAP1(0, _EJ_EMPTY, F, __VA_ARGS__, (), 0))

#define _EJ_EVAL0(...) __VA_ARGS__
#define _EJ_EVAL1(...) _EJ_EVAL0( _EJ_EVAL0(__VA_ARGS__) )
#define _EJ_EVAL2(...) _EJ_EVAL1( _EJ_EVAL1(__VA_ARGS__) )
#define _EJ_EVAL(...) _EJ_EVAL2( _EJ_EVAL2(__VA_ARGS__) )

#define _EJ_MAP_END(...)
#define _EJ_MAP_OUT
#define _EJ_MAP_GET_END() 0, _EJ_MAP_END
#define _EJ_MAP_NEXT0(ITEM, NEXT, ...) NEXT _EJ_MAP_OUT
#define _EJ_MAP_NEXT1(JOINER, ITEM, NEXT) _EJ_MAP_NEXT0 (ITEM, JOINER() NEXT, 0)
#define _EJ_MAP_NEXT(JOINER, ITEM, NEXT) _EJ_MAP_NEXT1 (JOINER, _EJ_MAP_GET_END ITEM, NEXT)

#define _EJ_MAP0(IDX, JOINER, F, NAME, PEEK, ...) F(IDX, NAME) _EJ_MAP_NEXT(JOINER, PEEK, _EJ_MAP1) (IDX+1, JOINER, F, PEEK, __VA_ARGS__)
#define _EJ_MAP1(IDX, JOINER, F, NAME, PEEK, ...) F(IDX, NAME) _EJ_MAP_NEXT(JOINER, PEEK, _EJ_MAP0) (IDX+1, JOINER, F, PEEK, __VA_ARGS__)


// ------------------------------------------------------------------------------------
// EJ_ARGC(...) - get the argument count in a macro with __VA_ARGS__; max 16 args

#define EJ_ARGC(...) _EJ_ARGC_SEQ(__VA_ARGS__,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1)
#define _EJ_ARGC_SEQ(x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,n,...) n


// ------------------------------------------------------------------------------------
// Unpack JavaScript values to numbers - use with
// EJ_UNPACK_ARGV(float value1, int value2, ...);
// or with an offset into argv
// EJ_UNPACK_ARGV_OFFSET(OFFSET, float value1, int value2, ...);

#define EJ_UNPACK_ARGV(...) EJ_UNPACK_ARGV_OFFSET(0, __VA_ARGS__)
#define EJ_UNPACK_ARGV_OFFSET(OFFSET, ...) \
	if( argc < EJ_ARGC(__VA_ARGS__)+OFFSET ) { \
		return NULL; \
	} \
	EJ_MAP_EXT(OFFSET, _EJ_LITERAL(;), _EJ_UNPACK_NUMBER, __VA_ARGS__)
	
#define _EJ_UNPACK_NUMBER(INDEX, NAME) NAME = JSValueToNumberFast(ctx, argv[INDEX]);

#define EJ_MIN_ARGS(ARGC, COUNT) \
	if(ARGC < COUNT) { \
		[MJSExceptionForType(MJSTooFewArgumentsException) raise]; \
		 \
		return NULL; \
	}

#define EJ_MIN_ARGS_NO_RETURN(ARGC, COUNT) \
	if(ARGC < COUNT) { \
		[MJSExceptionForType(MJSTooFewArgumentsException) raise]; \
		\
		return; \
	}


@protocol EJBindingBase <NSObject>

@optional

- (BOOL)hasProperty:(NSString *)name context:(JSContextRef)ctx;
- (void)setProperty:(NSString *)name value:(JSValueRef)value context:(JSContextRef)ctx;
- (JSValueRef)getProperty:(NSString *)name context:(JSContextRef)ctx;
- (void)deleteProperty:(NSString *)name context:(JSContextRef)ctx;

- (JSValueRef)performFunction:(NSString *)name argc:(size_t)argc argv:(JSValueRef [])argv context:(JSContextRef)ctx;

@end

@class EJJavaScriptView;
@interface EJBindingBase : NSObject <EJBindingBase> {
	JSObjectRef jsObject;
	
	// Puplic for fast access to instance->scriptView->jsUndefined in bound functions
	@public	MJSMobileJSController *controller;
}

- (id)initWithContext:(JSContextRef)ctxp argc:(size_t)argc argv:(const JSValueRef [])argv;
- (void)createWithJSObject:(JSObjectRef)obj controller:(MJSMobileJSController *)controller;
- (void)prepareGarbageCollection;
+ (JSObjectRef)createJSObjectWithContext:(JSContextRef)ctx
	controller:(MJSMobileJSController *)controller
	instance:(EJBindingBase *)instance;

void EJBindingBaseFinalize(JSObjectRef object);
bool MJSHasProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName);
JSValueRef MJSGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception);
bool MJSSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception);
bool MJSDeleteProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception);
JSValueRef MJSCallAsFunction(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception);

@property (nonatomic, readonly) MJSMobileJSController *controller;
@property (nonatomic, readonly) JSObjectRef jsObject;

@end

