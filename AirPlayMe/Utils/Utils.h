//
//  Utils.h
//  AirPlayMe
//
//  Created by Plamen Todorov on 19.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "AFNetworking.h"

@interface Utils : NSObject

+(NSString *)stringValue:(NSString *)string;
+(CGFloat)heightForString:(NSString *)myString font:(NSFont *)myFont containerWidth:(CGFloat)myWidth;
+(NSString *)uuid;
+(NSString *)timeIntervalFromDate:(NSDate *)dateStart toDate:(NSDate *)dateEnd;
+(NSString *)formatDistance:(double)distance;
+(BOOL)isNilOrEmpty:(id)object;
+(void)showInfo:(NSString*)message withTitle:(NSString*)title;
+(void)showError:(NSString*)message;

+(void)makeGetRequest:(NSString *)url parameters:(NSDictionary *)params callback:(void (^)(id response, BOOL success))callbackBlock;
+(NSImage*)roundCorners:(NSImage *)image;
@end
