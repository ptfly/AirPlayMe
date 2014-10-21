//
//  WindowController.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 16.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "WindowController.h"
#import "Config.h"

@interface WindowController ()

@end

@implementation WindowController

-(void)windowDidLoad
{
    [super windowDidLoad];
    
    self.window.backgroundColor = WINDOW_COLOR;
    self.window.opaque = YES;
    
//    NSRect boundsRect = [[[self.window contentView] superview] bounds];
//    NSView *titleView = [[NSView alloc] initWithFrame:boundsRect];
//    titleView.layer.backgroundColor = self.window.backgroundColor.CGColor;
//    [titleView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
//
//    [[[self.window contentView] superview] addSubview:titleView positioned:NSWindowBelow relativeTo:[[[[self.window contentView] superview] subviews] objectAtIndex:0]];

}

//-(UIView *)titleViewWithFrame:(NSRect)frame
//{
//    static NSDictionary *att = nil;
//    static NSString *title = @"AirPlayMe";
//    
//    if(!att)
//    {
//        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//        [style setLineBreakMode:NSLineBreakByTruncatingTail];
//        [style setAlignment:NSCenterTextAlignment];
//        att = [[NSDictionary alloc] initWithObjectsAndKeys: style, NSParagraphStyleAttributeName,[NSColor whiteColor], NSForegroundColorAttributeName,[NSFont fontWithName:@"Helvetica" size:12], NSFontAttributeName, nil];
//    }
//    
//    NSRect titlebarRect = NSMakeRect(frame.origin.x+20, frame.origin.y-4, frame.size.width, frame.size.height);
//    [title drawInRect:titlebarRect withAttributes:att];
//}


@end
