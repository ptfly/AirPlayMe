//
//  Config.h
//  AirPlayMe
//
//  Created by Plamen Todorov on 19.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "Utils.h"
#import "YLMoment.h"
#import "RegExCategories.h"

#define rgba(r, g, b, a) [NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define WINDOW_COLOR rgba(23,24,27,1)
#define BACKGROUND_COLOR rgba(23,24,27,1)
#define SHADOW_COLOR rgba(0,0,0,1)
#define CORNER_RADIUS 5.0

#define TMDB_API_KEY @"b8f652f4b231d6653c9146910628e547"

#define kMoviesLibraryPathKey  @"MoviesLibraryPath"
#define kTVShowsLibraryPathKey @"TVShowsLibraryPath"

#define kNotificationPlayItem @"NotificationPlayItem"
#define kNotificationOpenMovieDetails @"NotificationOpenMovieDetails"
#define kNotificationOpenTVShowDetails @"NotificationOpenTVShowDetails"
