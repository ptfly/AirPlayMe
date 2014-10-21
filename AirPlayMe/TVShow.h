//
//  TVShow.h
//  AirPlayMe
//
//  Created by Plamen Todorov on 21.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TVEpisode;

@interface TVShow : NSManagedObject

@property (nonatomic, retain) NSDate * first_air_date;
@property (nonatomic, retain) NSNumber * tmdbID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * original_name;
@property (nonatomic, retain) NSString * overview;
@property (nonatomic, retain) NSNumber * popularity;
@property (nonatomic, retain) NSData * poster;
@property (nonatomic, retain) NSString * poster_path;
@property (nonatomic, retain) NSNumber * vote_average;
@property (nonatomic, retain) NSNumber * vote_count;
@property (nonatomic, retain) NSData * backdrop;
@property (nonatomic, retain) NSString * backdrop_path;
@property (nonatomic, retain) TVEpisode *episodes;

@end
