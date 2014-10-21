//
//  Movie.h
//  AirPlayMe
//
//  Created by Plamen Todorov on 21.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Movie : NSManagedObject

@property (nonatomic, assign) BOOL parsed;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, assign) BOOL watched;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSNumber * adult;
@property (nonatomic, retain) NSNumber * tmdbID;
@property (nonatomic, retain) NSString * original_title;
@property (nonatomic, retain) NSString * overview;
@property (nonatomic, retain) NSNumber * popularity;
@property (nonatomic, retain) NSData * poster;
@property (nonatomic, retain) NSString * poster_path;
@property (nonatomic, retain) NSDate * release_date;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * vote_average;
@property (nonatomic, retain) NSNumber * vote_count;
@property (nonatomic, retain) NSString * backdrop_path;
@property (nonatomic, retain) NSData * backdrop;

@end
