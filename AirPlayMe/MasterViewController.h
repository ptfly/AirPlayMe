//
//  MasterViewController.h
//  AirPlayMe
//
//  Created by Plamen Todorov on 17.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum : NSUInteger {
    BrowseControllerMovies = 1,
    BrowseControllerTVShows,
    BrowseControllerPlaylist,
} BrowseControllerMode;

@interface MasterViewController : NSViewController

@end
