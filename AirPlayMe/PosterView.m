//
//  PosterView.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 21.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "PosterView.h"
#import "Config.h"
#import "NSImage+RoundCorner.h"

@interface PosterView ()
{
    NSTrackingArea *trackingArea;
}

@end

@implementation PosterView

-(id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if(self)
    {
        self.imageScaling = NSImageScaleAxesIndependently;
        self.imageAlignment = NSImageAlignCenter;
        
        self.wantsLayer = YES;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = CORNER_RADIUS;
        self.layer.borderColor = [NSColor clearColor].CGColor;
        self.layer.borderWidth = 2;
    }
    
    return self;
}

-(CGPathRef)CGPath:(NSBezierPath *)sourcePath
{
    long i, numElements;
    
    // Need to begin a path here.
    CGPathRef           immutablePath = NULL;
    
    // Then draw the path elements.
    numElements = [sourcePath elementCount];
    if (numElements > 0)
    {
        CGMutablePathRef    path = CGPathCreateMutable();
        NSPoint             points[3];
        BOOL                didClosePath = YES;
        
        for (i = 0; i < numElements; i++)
        {
            switch ([sourcePath elementAtIndex:i associatedPoints:points])
            {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;
                    
                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    didClosePath = NO;
                    break;
                    
                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                          points[1].x, points[1].y,
                                          points[2].x, points[2].y);
                    didClosePath = NO;
                    break;
                    
                case NSClosePathBezierPathElement:
                    CGPathCloseSubpath(path);
                    didClosePath = YES;
                    break;
            }
        }
        
        // Be sure the path is closed or Quartz may not do valid hit detection.
        if (!didClosePath)
            CGPathCloseSubpath(path);
        
        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }
    
    return immutablePath;
}

-(void)mouseEntered:(NSEvent *)theEvent
{
    self.layer.borderColor = rgba(45,117,223,1).CGColor;
    [self setNeedsDisplay];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    self.layer.borderColor = [NSColor clearColor].CGColor;
    [self setNeedsDisplay];
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
