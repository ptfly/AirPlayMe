//
//  ShadowTextField.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 22.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "ShadowTextField.h"
#import "Config.h"

@implementation ShadowTextField

-(id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if(self)
    {
        self.wantsLayer = YES;
        
        NSShadow *dropShadow = [[NSShadow alloc] init];
        [dropShadow setShadowColor:SHADOW_COLOR];
        [dropShadow setShadowOffset:NSMakeSize(0, 0)];
        [dropShadow setShadowBlurRadius:2.0];
        [self setShadow: dropShadow];
    }
    
    return self;
}

@end
