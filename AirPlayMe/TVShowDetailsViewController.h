//
//  TVShowDetailsViewController.h
//  AirPlayMe
//
//  Created by Plamen Todorov on 21.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TVShow.h"
#import "TVEpisode.h"
#import "EDStarRating.h"

@interface TVShowDetailsViewController : NSViewController

@property (strong, nonatomic) TVShow *show;
@end
