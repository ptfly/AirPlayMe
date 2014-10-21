//
//  ShadowView.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 21.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "ShadowView.h"
#import "Config.h"

@implementation ShadowView

-(id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if(self)
    {
        self.wantsLayer = YES;
        self.layer.cornerRadius = CORNER_RADIUS;
        self.layer.backgroundColor = BACKGROUND_COLOR.CGColor;
        
        NSShadow *dropShadow = [[NSShadow alloc] init];
        [dropShadow setShadowColor:SHADOW_COLOR];
        [dropShadow setShadowOffset:NSMakeSize(0, 0)];
        [dropShadow setShadowBlurRadius:3.0];
        [self setShadow: dropShadow];
    }
    
    return self;
}

@end
