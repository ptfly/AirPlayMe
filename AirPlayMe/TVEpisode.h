//
//  TVEpisode.h
//  AirPlayMe
//
//  Created by Plamen Todorov on 21.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TVShow;

@interface TVEpisode : NSManagedObject

@property (nonatomic, retain) NSDate * air_date;
@property (nonatomic, retain) NSNumber * tmdbID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * overview;
@property (nonatomic, retain) NSData * still;
@property (nonatomic, retain) NSString * still_path;
@property (nonatomic, retain) NSNumber * vote_average;
@property (nonatomic, retain) NSNumber * vote_count;
@property (nonatomic, retain) NSNumber * episode;
@property (nonatomic, assign) BOOL parsed;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSNumber * season;
@property (nonatomic, assign) BOOL watched;
@property (nonatomic, retain) NSString * original_name;
@property (nonatomic, retain) TVShow *show;

@end
