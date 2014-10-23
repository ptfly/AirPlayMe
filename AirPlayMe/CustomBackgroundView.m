//
//  CustomBackgroundView.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 23.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "CustomBackgroundView.h"

@interface CustomBackgroundView ()

@property (strong, nonatomic) NSColor *backgroundColor;
@property (assign, nonatomic) CGFloat cornerRadius;
@end

@implementation CustomBackgroundView

-(void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if(self.cornerRadius > 0){
        self.layer.cornerRadius = self.cornerRadius;
        self.layer.masksToBounds = YES;
    }
    [self.backgroundColor setFill];
    NSRectFill(dirtyRect);
}

@end
