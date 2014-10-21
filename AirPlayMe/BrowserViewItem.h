//
//  BrowserViewItem.h
//  AirPlayMe
//
//  Created by Plamen Todorov on 19.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface BrowserViewItem : NSCollectionViewItem

@property (weak) IBOutlet NSTextField *nameField;
@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSTextField *yearField;

@end
