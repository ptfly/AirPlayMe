//
//  AutoHeightField.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 21.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "AutoHeightField.h"

@implementation AutoHeightField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(NSSize)intrinsicContentSize
{
    if ( ![self.cell wraps] ) {
        return [super intrinsicContentSize];
    }
    
    NSRect frame = [self frame];
    
    CGFloat width = frame.size.width;
    
    // Make the frame very high, while keeping the width
    frame.size.height = CGFLOAT_MAX;
    
    // Calculate new height within the frame
    // with practically infinite height.
    CGFloat height = [self.cell cellSizeForBounds:frame].height;
    
    return NSMakeSize(width, height);
}

// you need to invalidate the layout on text change, else it wouldn't grow by changing the text
- (void)textDidChange:(NSNotification *)notification
{
    [super textDidChange:notification];
    [self invalidateIntrinsicContentSize];
}

-(void)updateSize
{
    [self invalidateIntrinsicContentSize];
}
@end
