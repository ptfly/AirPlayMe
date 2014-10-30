//
//  MovieDetailsViewController.h
//  AirPlayMe
//
//  Created by Plamen Todorov on 21.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Config.h"
#import "Movie.h"
#import "EDStarRating.h"

@interface MovieDetailsViewController : NSViewController

@property (strong, nonatomic) Movie *movie;
@property (strong, nonatomic) NSNumber *tmdbID;

@end
