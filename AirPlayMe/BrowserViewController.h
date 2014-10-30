//
//  BrowserViewController.h
//  AirPlayMe
//
//  Created by Plamen Todorov on 17.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum : NSUInteger {
    BrowseMovies = 0,
    BrowseTVShows,
} BrowseType;

typedef enum : NSUInteger {
    FilterAll = 0,
    FilterNew,
    FilterWatched,
} FilterType;

@interface BrowserViewController : NSViewController

@property (assign, nonatomic) FilterType filter;
@property (assign, nonatomic) BrowseType type;

@end
