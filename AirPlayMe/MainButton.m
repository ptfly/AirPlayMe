//
//  MainButton.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 21.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "MainButton.h"
#import "Config.h"

@interface MainButton ()

@end

@implementation MainButton
@synthesize activeColor;

-(void)drawRect:(NSRect)dirtyRect
{
    [self updateButtonView];
    [super drawRect:dirtyRect];
}

-(void)updateButtonView
{
    NSColor *color = rgba(255,255,255,1);

    if(self.state == NSOnState){
        color = (self.activeColor ? self.activeColor : TINT_COLOR);
    }
    
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedTitle];
    
    NSRange range = NSMakeRange(0, attrTitle.length);
    [attrTitle addAttribute:NSForegroundColorAttributeName value:color range:range];
    [attrTitle fixAttributesInRange:range];
    
    [self setAttributedTitle:attrTitle];
    [self setButtonType:NSToggleButton];
}

-(void)setActive
{
    [self setState:NSOnState];
    [self updateButtonView];
}

-(void)setInactive
{
    [self setState:NSOffState];
    [self updateButtonView];
}

@end
