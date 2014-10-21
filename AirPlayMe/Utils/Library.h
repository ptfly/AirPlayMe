//
//  Library.h
//  AirPlayMe
//
//  Created by Plamen Todorov on 21.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"
#import "Movie.h"
#import "TVShow.h"
#import "TVEpisode.h"

@interface Library : NSObject

+(id)sharedInstance;

// Local Scanner
-(void)scanMoviesLibrary;
-(void)scanTVShowsLibrary;

-(NSDictionary *)parseMovieName:(NSURL *)url standardParseFailed:(BOOL)parseFailed;
-(NSDictionary *)parseEpisodeName:(NSURL *)url standardParseFailed:(BOOL)parseFailed;

// TMDB Parser
-(void)getTMDBConfig:(void (^)(BOOL success))callbackBlock;

-(void)updateMovieItems;
-(void)updateEpisodeItems;

-(void)tmdbSearchMovie:(NSString *)name year:(NSString *)year standardSearch:(BOOL)standardSearch callback:(void (^)(NSDictionary *response, BOOL success))callbackBlock;
-(void)tmdbSearchTVShow:(NSString *)name standardSearch:(BOOL)standardSearch callback:(void (^)(NSDictionary *response, BOOL success))callbackBlock;

-(void)tmdbGetMovieInfo:(NSNumber *)movieId callback:(void (^)(NSDictionary *response, BOOL success))callbackBlock;
-(void)tmdbGetTVShowInfo:(NSNumber *)seriesId callback:(void (^)(NSDictionary *response, BOOL success))callbackBlock;
-(void)tmdbGetTVSeasonInfo:(NSNumber *)seriesId season:(NSNumber *)season callback:(void (^)(NSDictionary *response, BOOL success))callbackBlock;
-(void)tmdbGetEpisodeInfo:(NSNumber *)seriesId season:(NSNumber *)season episode:(NSNumber *)episode callback:(void (^)(NSDictionary *response, BOOL success))callbackBlock;

// Core Data
-(Movie *)movieItemExists:(NSURL *)itemUrl;
-(TVShow *)showItemExists:(NSNumber *)tmdbID;
-(TVEpisode *)episodeItemExists:(NSURL *)itemUrl;

-(void)addMovieItem:(NSURL *)itemUrl;
-(Movie *)updateMovieItem:(NSDictionary *)tmdbData forMovie:(Movie *)record;

-(TVShow *)addTVShowItem:(NSDictionary *)tmdbData forEpisode:(TVEpisode *)episode;

-(void)addTVEpisodeItem:(NSURL *)itemUrl;
-(TVEpisode *)updateTVEpisodeItem:(NSDictionary *)tmdbData forEpisode:(TVEpisode *)record;

@end
