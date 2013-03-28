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

UIColor *JSValueToUIColor(JSContextRef ctx, JSValueRef v) {
	// TODO: Support named colors.
	static NSCharacterSet *spaceCommaCharacterSet = nil;
	
	NSString *string = JSValueToNSString(ctx, v);
	
	NSScanner *scanner = [[[NSScanner alloc] initWithString:string] autorelease];
	
	if([string hasPrefix:@"#"]) {
		unsigned hexNum;
		
		[scanner scanString:@"#" intoString:nil];
		[scanner scanHexInt:&hexNum];
		
		int r = (hexNum >> 16) & 0xFF;
		int g = (hexNum >> 8) & 0xFF;
		int b = (hexNum) & 0xFF;
		
		return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
	} else if([string hasPrefix:@"rgb("] || [string hasPrefix:@"rgba("]) {
		if(!spaceCommaCharacterSet) {
			spaceCommaCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@", "] retain];
		}
		
		int r = 0;
		int g = 0;
		int b = 0;
		double alpha = 1.0;
		
		if(![scanner scanString:@"rgb(" intoString:nil]) {
			if(![scanner scanString:@"rgba(" intoString:nil]) {
				return nil;
			}
		}
		
		[scanner scanInt:&r];
		[scanner scanCharactersFromSet:spaceCommaCharacterSet intoString:nil];
		[scanner scanInt:&g];
		[scanner scanCharactersFromSet:spaceCommaCharacterSet intoString:nil];
		[scanner scanInt:&b];
		
		if([scanner scanCharactersFromSet:spaceCommaCharacterSet intoString:nil]) {
			[scanner scanDouble:&alpha];
		}
		
		return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:alpha];
	}
	
	return nil;
}

JSValueRef UIColorToJSValue(JSContextRef ctx, UIColor *color) {
	CGColorRef cgColor = color.CGColor;
	const CGFloat *components = CGColorGetComponents(cgColor);
	CGFloat alpha = CGColorGetAlpha(cgColor);
	CGColorSpaceModel model = CGColorSpaceGetModel(CGColorGetColorSpace(cgColor));
	NSString *string = nil;
	
	if(model == kCGColorSpaceModelMonochrome) {
		string = [NSString stringWithFormat:@"rgba(%f, %f, %f, %f)", components[0] * 255.0, components[0] * 255.0, components[0] * 255.0, alpha];
	} else if(model == kCGColorSpaceModelRGB) {
		string = [NSString stringWithFormat:@"rgba(%f, %f, %f, %f)", components[0] * 255.0, components[1] * 255.0, components[2] * 255.0, alpha];
	}
	
	return (string) ? NSStringToJSValue(ctx, string) : NULL;
}

