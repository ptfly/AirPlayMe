//
//  BackDropView.h
//  AirPlayMe
//
//  Created by Plamen Todorov on 23.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BackDropView : NSView

@property (strong, nonatomic) NSImage *image;
@property (strong, nonatomic) NSColor *backgroundColor;
@property (assign, nonatomic) CGFloat cornerRadius;
@end
