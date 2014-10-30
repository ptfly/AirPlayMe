//
//  CustomButton.h
//  AirPlayMe
//
//  Created by Plamen Todorov on 29.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CustomButton : NSButton
@property (strong, nonatomic) NSColor *titleColor;
@property (assign, nonatomic) BOOL disabled;
@end
