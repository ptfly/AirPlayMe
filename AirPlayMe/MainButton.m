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

-(id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if(self)
    {
        [self setButtonType:NSOnOffButton];
        [self updateButtonView];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [self updateButtonView];
}

-(void)updateButtonView
{
    NSColor *color = rgba(255,255,255,0.8);
    
    if(self.state == NSOnState){
        color = rgba(45,117,223,1);
    }
    
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedTitle]];
    long len = [attrTitle length];
    
    NSRange range = NSMakeRange(0, len);
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
