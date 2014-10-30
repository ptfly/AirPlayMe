//
//  Utils.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 19.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "Utils.h"
#import "Config.h"

@implementation Utils

+(void)addToPlaylist:(NSString *)path
{
    NSMutableArray *list = [[[NSUserDefaults standardUserDefaults] objectForKey:kPlaylistStorageKey] mutableCopy];
    if(!list) list = [NSMutableArray new];
    
    [list addObject:path];
    
    NSArray *unique = [list valueForKeyPath:@"@distinctUnionOfObjects.self"];
    NSArray *sorted = [unique sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    [[NSUserDefaults standardUserDefaults] setObject:sorted forKey:kPlaylistStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)removeFromPlaylist:(NSString *)path
{
    NSMutableArray *list = [[[NSUserDefaults standardUserDefaults] objectForKey:kPlaylistStorageKey] mutableCopy];
    
    [list removeObject:path];
    [[NSUserDefaults standardUserDefaults] setObject:list forKey:kPlaylistStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSArray *)getPlayListItems
{
    NSMutableArray *list = [[[NSUserDefaults standardUserDefaults] objectForKey:kPlaylistStorageKey] mutableCopy];
    if(!list) list = [NSMutableArray new];
    
    return list;
}

+(void)clearPlaylist
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPlaylistStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)stringValue:(NSString *)string
{
    return [Utils isNilOrEmpty:string] ? @"" : [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+(NSString *)stringValue:(NSString *)string fallBack:(NSString *)fallBack
{
    return [Utils isNilOrEmpty:string] ? fallBack : [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+(CGFloat)heightForString:(NSString *)myString font:(NSFont *)myFont containerWidth:(CGFloat)myWidth
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:myString];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(myWidth, FLT_MAX)];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textStorage addAttribute:NSFontAttributeName value:myFont range:NSMakeRange(0, [textStorage length])];
    [textContainer setLineFragmentPadding:0.0];
    
    (void) [layoutManager glyphRangeForTextContainer:textContainer];
    return [layoutManager usedRectForTextContainer:textContainer].size.height;
}

+(NSString *)uuid
{
    return [[NSUUID UUID] UUIDString];
}

+(NSString *)timeIntervalFromDate:(NSDate *)dateStart toDate:(NSDate *)dateEnd
{
    NSMutableArray *parts = [NSMutableArray new];
    NSCalendarUnit units = NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units fromDate:dateStart toDate:dateEnd options:0];
    
    NSInteger days = [components day];
    if(days > 0){
        [parts addObject:[NSString stringWithFormat:@"%ldd", (long)days]];
    }
    
    NSInteger hours = [components hour];
    if(hours > 0){
        [parts addObject:[NSString stringWithFormat:@"%ldh", (long)hours]];
    }
    
    NSInteger minutes = [components minute];
    if(minutes > 0){
        [parts addObject:[NSString stringWithFormat:@"%ldm", (long)minutes]];
    }
    
    NSInteger seconds = [components second];
    if(seconds > 0){
        [parts addObject:[NSString stringWithFormat:@"%lds", (long)seconds]];
    }
    
    if(parts.count == 0){
        return @"0s";
    }
    
    return [parts componentsJoinedByString:@" "];
}

+(NSString *)formatDistance:(double)distance
{
    return [NSString stringWithFormat:(distance >= 1000 ? @"%.2f km" : @"%.2f m"), (distance >= 1000 ? distance/1000 : distance)];
}

+(BOOL)isNilOrEmpty:(id)object
{
    if(object == nil || object == [NSNull null]) return YES;
    
    if([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSMutableString class]] || [object isKindOfClass:[NSAttributedString class]] || [object isKindOfClass:[NSMutableAttributedString class]]){
        return [object isEqualToString:@""];
    }
    
    return NO;
}

+(void)showInfo:(NSString*)message withTitle:(NSString*)title
{
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:title];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    [alert beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] completionHandler:nil];
}

+(void)showError:(NSString*)message
{
    [Utils showInfo:message withTitle:@"Error"];
}

+(void)makeGetRequest:(NSString *)url parameters:(NSDictionary *)params callback:(void (^)(id response, BOOL success))callbackBlock
{
//    NSLog(@"%@ - %@", url, params);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(!callbackBlock) return;
        callbackBlock(responseObject, YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(!callbackBlock) return;
        callbackBlock(error, NO);
    }];
}

+(NSImage*)roundCorners:(NSImage *)image
{
    NSImage *existingImage = image;
    NSSize existingSize = [existingImage size];
    NSSize newSize = NSMakeSize(existingSize.height, existingSize.width);
    NSImage *composedImage = [[NSImage alloc] initWithSize:newSize];
    
    [composedImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    
    NSRect imageFrame = NSRectFromCGRect(CGRectMake(0, 0, image.size.width, image.size.height));
    NSBezierPath *clipPath = [NSBezierPath bezierPathWithRoundedRect:imageFrame xRadius:4 yRadius:4];
    [clipPath setWindingRule:NSEvenOddWindingRule];
    [clipPath addClip];
    
    [image drawAtPoint:NSZeroPoint fromRect:NSMakeRect(0, 0, newSize.width, newSize.height) operation:NSCompositeSourceOver fraction:1];
    
    [composedImage unlockFocus];
    
    return composedImage;
}

@end
