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
	static NSCharacterSet *spaceCommaCharacterSet = nil;
	static NSDictionary *namedColorsDictionary = nil;
	
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
	} else {
		if(!namedColorsDictionary) {
#define RGBCOLOR(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
			
			namedColorsDictionary = [(@{
									 @"aliceblue": RGBCOLOR(240,248,255),
									 @"antiquewhite": RGBCOLOR(250,235,215),
									 @"aqua": RGBCOLOR(0,255,255),
									 @"aquamarine": RGBCOLOR(127,255,212),
									 @"azure": RGBCOLOR(240,255,255),
									 @"beige": RGBCOLOR(245,245,220),
									 @"bisque": RGBCOLOR(255,228,196),
									 @"black": RGBCOLOR(0,0,0),
									 @"blanchedalmond": RGBCOLOR(255,235,205),
									 @"blue": RGBCOLOR(0,0,255),
									 @"blueviolet": RGBCOLOR(138,43,226),
									 @"brown": RGBCOLOR(165,42,42),
									 @"burlywood": RGBCOLOR(222,184,135),
									 @"cadetblue": RGBCOLOR(95,158,160),
									 @"chartreuse": RGBCOLOR(127,255,0),
									 @"chocolate": RGBCOLOR(210,105,30),
									 @"coral": RGBCOLOR(255,127,80),
									 @"cornflowerblue": RGBCOLOR(100,149,237),
									 @"cornsilk": RGBCOLOR(255,248,220),
									 @"crimson": RGBCOLOR(220,20,60),
									 @"cyan": RGBCOLOR(0,255,255),
									 @"darkblue": RGBCOLOR(0,0,139),
									 @"darkcyan": RGBCOLOR(0,139,139),
									 @"darkgoldenrod": RGBCOLOR(184,134,11),
									 @"darkgray": RGBCOLOR(169,169,169),
									 @"darkgreen": RGBCOLOR(0,100,0),
									 @"darkgrey": RGBCOLOR(169,169,169),
									 @"darkkhaki": RGBCOLOR(189,183,107),
									 @"darkmagenta": RGBCOLOR(139,0,139),
									 @"darkolivegreen": RGBCOLOR(85,107,47),
									 @"darkorange": RGBCOLOR(255,140,0),
									 @"darkorchid": RGBCOLOR(153,50,204),
									 @"darkred": RGBCOLOR(139,0,0),
									 @"darksalmon": RGBCOLOR(233,150,122),
									 @"darkseagreen": RGBCOLOR(143,188,143),
									 @"darkslateblue": RGBCOLOR(72,61,139),
									 @"darkslategray": RGBCOLOR(47,79,79),
									 @"darkslategrey": RGBCOLOR(47,79,79),
									 @"darkturquoise": RGBCOLOR(0,206,209),
									 @"darkviolet": RGBCOLOR(148,0,211),
									 @"deeppink": RGBCOLOR(255,20,147),
									 @"deepskyblue": RGBCOLOR(0,191,255),
									 @"dimgray": RGBCOLOR(105,105,105),
									 @"dimgrey": RGBCOLOR(105,105,105),
									 @"dodgerblue": RGBCOLOR(30,144,255),
									 @"firebrick": RGBCOLOR(178,34,34),
									 @"floralwhite": RGBCOLOR(255,250,240),
									 @"forestgreen": RGBCOLOR(34,139,34),
									 @"fuchsia": RGBCOLOR(255,0,255),
									 @"gainsboro": RGBCOLOR(220,220,220),
									 @"ghostwhite": RGBCOLOR(248,248,255),
									 @"gold": RGBCOLOR(255,215,0),
									 @"goldenrod": RGBCOLOR(218,165,32),
									 @"gray": RGBCOLOR(128,128,128),
									 @"green": RGBCOLOR(0,128,0),
									 @"greenyellow": RGBCOLOR(173,255,47),
									 @"grey": RGBCOLOR(128,128,128),
									 @"honeydew": RGBCOLOR(240,255,240),
									 @"hotpink": RGBCOLOR(255,105,180),
									 @"indianred": RGBCOLOR(205,92,92),
									 @"indigo": RGBCOLOR(75,0,130),
									 @"ivory": RGBCOLOR(255,255,240),
									 @"khaki": RGBCOLOR(240,230,140),
									 @"lavender": RGBCOLOR(230,230,250),
									 @"lavenderblush": RGBCOLOR(255,240,245),
									 @"lawngreen": RGBCOLOR(124,252,0),
									 @"lemonchiffon": RGBCOLOR(255,250,205),
									 @"lightblue": RGBCOLOR(173,216,230),
									 @"lightcoral": RGBCOLOR(240,128,128),
									 @"lightcyan": RGBCOLOR(224,255,255),
									 @"lightgoldenrodyellow": RGBCOLOR(250,250,210),
									 @"lightgray": RGBCOLOR(211,211,211),
									 @"lightgreen": RGBCOLOR(144,238,144),
									 @"lightgrey": RGBCOLOR(211,211,211),
									 @"lightpink": RGBCOLOR(255,182,193),
									 @"lightsalmon": RGBCOLOR(255,160,122),
									 @"lightseagreen": RGBCOLOR(32,178,170),
									 @"lightskyblue": RGBCOLOR(135,206,250),
									 @"lightslategray": RGBCOLOR(119,136,153),
									 @"lightslategrey": RGBCOLOR(119,136,153),
									 @"lightsteelblue": RGBCOLOR(176,196,222),
									 @"lightyellow": RGBCOLOR(255,255,224),
									 @"lime": RGBCOLOR(0,255,0),
									 @"limegreen": RGBCOLOR(50,205,50),
									 @"linen": RGBCOLOR(250,240,230),
									 @"magenta": RGBCOLOR(255,0,255),
									 @"maroon": RGBCOLOR(128,0,0),
									 @"mediumaquamarine": RGBCOLOR(102,205,170),
									 @"mediumblue": RGBCOLOR(0,0,205),
									 @"mediumorchid": RGBCOLOR(186,85,211),
									 @"mediumpurple": RGBCOLOR(147,112,219),
									 @"mediumseagreen": RGBCOLOR(60,179,113),
									 @"mediumslateblue": RGBCOLOR(123,104,238),
									 @"mediumspringgreen": RGBCOLOR(0,250,154),
									 @"mediumturquoise": RGBCOLOR(72,209,204),
									 @"mediumvioletred": RGBCOLOR(199,21,133),
									 @"midnightblue": RGBCOLOR(25,25,112),
									 @"mintcream": RGBCOLOR(245,255,250),
									 @"mistyrose": RGBCOLOR(255,228,225),
									 @"moccasin": RGBCOLOR(255,228,181),
									 @"navajowhite": RGBCOLOR(255,222,173),
									 @"navy": RGBCOLOR(0,0,128),
									 @"oldlace": RGBCOLOR(253,245,230),
									 @"olive": RGBCOLOR(128,128,0),
									 @"olivedrab": RGBCOLOR(107,142,35),
									 @"orange": RGBCOLOR(255,165,0),
									 @"orangered": RGBCOLOR(255,69,0),
									 @"orchid": RGBCOLOR(218,112,214),
									 @"palegoldenrod": RGBCOLOR(238,232,170),
									 @"palegreen": RGBCOLOR(152,251,152),
									 @"paleturquoise": RGBCOLOR(175,238,238),
									 @"palevioletred": RGBCOLOR(219,112,147),
									 @"papayawhip": RGBCOLOR(255,239,213),
									 @"peachpuff": RGBCOLOR(255,218,185),
									 @"peru": RGBCOLOR(205,133,63),
									 @"pink": RGBCOLOR(255,192,203),
									 @"plum": RGBCOLOR(221,160,221),
									 @"powderblue": RGBCOLOR(176,224,230),
									 @"purple": RGBCOLOR(128,0,128),
									 @"red": RGBCOLOR(255,0,0),
									 @"rosybrown": RGBCOLOR(188,143,143),
									 @"royalblue": RGBCOLOR(65,105,225),
									 @"saddlebrown": RGBCOLOR(139,69,19),
									 @"salmon": RGBCOLOR(250,128,114),
									 @"sandybrown": RGBCOLOR(244,164,96),
									 @"seagreen": RGBCOLOR(46,139,87),
									 @"seashell": RGBCOLOR(255,245,238),
									 @"sienna": RGBCOLOR(160,82,45),
									 @"silver": RGBCOLOR(192,192,192),
									 @"skyblue": RGBCOLOR(135,206,235),
									 @"slateblue": RGBCOLOR(106,90,205),
									 @"slategray": RGBCOLOR(112,128,144),
									 @"slategrey": RGBCOLOR(112,128,144),
									 @"snow": RGBCOLOR(255,250,250),
									 @"springgreen": RGBCOLOR(0,255,127),
									 @"steelblue": RGBCOLOR(70,130,180),
									 @"tan": RGBCOLOR(210,180,140),
									 @"teal": RGBCOLOR(0,128,128),
									 @"thistle": RGBCOLOR(216,191,216),
									 @"tomato": RGBCOLOR(255,99,71),
									 @"turquoise": RGBCOLOR(64,224,208),
									 @"violet": RGBCOLOR(238,130,238),
									 @"wheat": RGBCOLOR(245,222,179),
									 @"white": RGBCOLOR(255,255,255),
									 @"whitesmoke": RGBCOLOR(245,245,245),
									 @"yellow": RGBCOLOR(255,255,0),
									 @"yellowgreen": RGBCOLOR(154,205,50),
									 }) retain];

#undef RGBCOLOR
		}
		
		return [namedColorsDictionary objectForKey:string];
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
