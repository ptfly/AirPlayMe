//
//  CustomButton.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 29.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "CustomButton.h"
#import "Config.h"

@implementation CustomButton

@synthesize titleColor, disabled;

-(void)drawRect:(NSRect)dirtyRect
{
    
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedTitle];
    
    NSRange range = NSMakeRange(0, attrTitle.length);
    [attrTitle addAttribute:NSForegroundColorAttributeName value:titleColor range:range];
    [attrTitle fixAttributesInRange:range];
    
    [self setAttributedTitle:attrTitle];
    [self setButtonType:NSToggleButton];
    
    [super drawRect:dirtyRect];
}

-(void)setEnabled:(BOOL)enabled
{
    self.disabled = !enabled;
    
    if(enabled){
        self.titleColor = [self.titleColor colorWithAlphaComponent:1];
    }
    else {
        self.titleColor = [self.titleColor colorWithAlphaComponent:0.5];
    }
    
    [self setNeedsDisplay];
//    [super setEnabled:enabled];
}

@end
