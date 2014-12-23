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

#import <QuartzCore/QuartzCore.h>

#define rgba(r, g, b, a) [NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define WINDOW_COLOR rgba(10,10,10,1)
#define BACKGROUND_COLOR rgba(29,29,29,1)
#define SHADOW_COLOR rgba(0,0,0,0.9)
#define CORNER_RADIUS 5.0
#define TINT_COLOR rgba(27,131,251,1)

#define TMDB_API_URL                        @"http://api.themoviedb.org/3"
#define TMDB_API_KEY                        @"b8f652f4b231d6653c9146910628e547" // Please do not use mine :)

#define PLAYER_APP_NAME                     @"Beamer"
#define PLAYER_BUNDLE_ID                    @"com.tupil.beamer"

#define kLastSectionKey                     @"LastSectionKey"
#define kMoviesFilterKey                    @"MoviesFilterKey"
#define kMoviesLibraryPathKey               @"MoviesLibraryPath"
#define kTVShowsFilterKey                   @"TVShowsFilterKey"
#define kTVShowsLibraryPathKey              @"TVShowsLibraryPath"
#define kPlaylistStorageKey                 @"PlaylistStorageKey"

#define kNotificationScanComplete           @"NotificationScanComplete"
#define kNotificationPlayItem               @"NotificationPlayItem"
#define kNotificationPlayList               @"NotificationPlayList"
#define kNotificationPlaylistItemAdded      @"NotificationPlaylistItemAdded"
#define kNotificationOpenMovieDetails       @"NotificationOpenMovieDetails"
#define kNotificationOpenTVShowDetails      @"NotificationOpenTVShowDetails"

#define kNotificationApplyBrowseMode        @"NotificationApplyBrowseMode"
#define kNotificationApplyBrowseFilter      @"NotificationApplyBrowseFilter"
