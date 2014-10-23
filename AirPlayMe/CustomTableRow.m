//
//  CustomTableRow.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 23.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "CustomTableRow.h"
#import "Config.h"

@interface CustomTableRow ()
{
    NSTrackingArea *trackingArea;
}

@end

@implementation CustomTableRow

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if(self.selected){
        [rgba(27,45,76,1) setFill];
    }
    else {
        [rgba(31,32,37,1) setFill];
    }
    
    CGFloat sep = 1;
    NSRectFill(CGRectMake(0, 0, dirtyRect.size.width, dirtyRect.size.height-sep));
    
    [[NSColor blackColor] setFill];
    NSRectFill(CGRectMake(0, dirtyRect.size.height-sep, dirtyRect.size.width, sep));
}

-(void)mouseEntered:(NSEvent *)theEvent
{
    self.layer.backgroundColor = rgba(45,117,223,1).CGColor;
    [self needsDisplay];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    self.layer.backgroundColor = [NSColor clearColor].CGColor;
    [self needsDisplay];
}

-(void)updateTrackingAreas
{
    if(trackingArea != nil) {
        [self removeTrackingArea:trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds] options:opts owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}

@end
