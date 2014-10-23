//
//  BackDropView.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 23.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "BackDropView.h"

@implementation BackDropView
@synthesize image,backgroundColor;

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if(self.cornerRadius > 0){
        self.layer.cornerRadius = self.cornerRadius;
        self.layer.masksToBounds = YES;
    }
    
    // create blank image and lock drawing on it
    if(image)
    {
        [image lockFocus];
        
        // draw your image patter on the new blank image
        [[NSColor colorWithPatternImage:image] set];
        NSRectFill(self.bounds);
        
        [image unlockFocus];
        
        // draw your new image
        [image drawInRect:dirtyRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.4f];
    }
    else {
        [self.backgroundColor setFill];
        NSRectFill(dirtyRect);
    }
}

@end
