#import "EJConvert.h"

NSString *JSValueToNSString( JSContextRef ctx, JSValueRef v ) {
	JSStringRef jsString = JSValueToStringCopy( ctx, v, NULL );
	if( !jsString ) return nil;
	
	NSString *string = (NSString *)JSStringCopyCFString( kCFAllocatorDefault, jsString );
	[string autorelease];
	JSStringRelease( jsString );
	
	return string;
}

JSValueRef NSStringToJSValue( JSContextRef ctx, NSString *string ) {
	JSStringRef jstr = JSStringCreateWithCFString((CFStringRef)string);
	JSValueRef ret = JSValueMakeString(ctx, jstr);
	JSStringRelease(jstr);
	return ret;
}

JSValueRef NSStringToJSValueProtect( JSContextRef ctx, NSString *string ) {
	JSValueRef ret = NSStringToJSValue( ctx, string );
	JSValueProtect(ctx, ret);
	return ret;
}

double JSValueToNumberFast( JSContextRef ctx, JSValueRef v ) {
	// This struct represents the memory layout of a C++ JSValue instance
	// See JSC/runtime/JSValue.h for an explanation of the tagging
	struct {
		unsigned char cppClassData[8];
		union {
			double asDouble;
			struct { int32_t asInt; int32_t tag; } asBits;
		} payload;
	} *decoded = (void *)v;
	
	return decoded->payload.asBits.tag < 0xfffffff9
		? decoded->payload.asDouble
		: decoded->payload.asBits.asInt;
}

void JSValueUnprotectSafe( JSContextRef ctx, JSValueRef v ) {
	if( ctx && v ) {
		JSValueUnprotect(ctx, v);
	}
}

JSValueRef NSExceptionToJSValue( JSContextRef ctx, NSException *e ) {
	NSString *errorType = @"Error";
	
	if([[e name] isEqualToString:MJSTooFewArgumentsException]) {
		errorType = @"TypeError";
	}
	
	return JSMakeErrorWithType(ctx, [e reason], errorType);
}

JSValueRef NSErrorToJSValue( JSContextRef ctx, NSError *e ) {
	return JSMakeError(ctx, [e localizedDescription]);
}

JSValueRef JSMakeError(JSContextRef ctx, NSString *message) {
	return JSMakeErrorWithType(ctx, message, @"Error");
}

JSValueRef JSMakeErrorWithType(JSContextRef ctx, NSString *message, NSString *type) {
	JSValueRef reason = NSStringToJSValue(ctx, message);
	
	JSStringRef scriptJS = JSStringCreateWithCFString((CFStringRef)[NSString stringWithFormat:@"return new %@(arguments[0]);", type]);
	JSObjectRef fn = JSObjectMakeFunction(ctx, NULL, 0, NULL, scriptJS, NULL, 1, NULL);
	JSValueRef result = JSObjectCallAsFunction(ctx, fn, NULL, 1, (JSValueRef *)&reason, NULL);
	JSStringRelease(scriptJS);
	
	return result;
}

