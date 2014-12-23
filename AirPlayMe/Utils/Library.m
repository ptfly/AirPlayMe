//
//  Library.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 21.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "Library.h"
#import "AppDelegate.h"

static int movieYearChecker     = 1950;
static NSString *releaseTypes   = @"(\\(|\\)|brrip|xvid|flac|bluerip|webrip|ac3|blueray|bluray|divx|pdtv|bdrip|uncut|hdrip|sample|720p|1080p|1080i|x264|x265|dvdrip|dvd|h264|dts-hd|dts|ma5.1|5.1|avc|unrated|remux)";
static NSString *releaseGroups  = @"-NESMEURED|-KILLERS|-HDMaNiAcS|-war|aac-cpg|-VietHD|-WARHD|-PFa|-SPARKS|-DIMENSION|-PGM|-AMIABLE|SiMPLE|-GECKOS|-HiFi|-ChaoS|-VietHD|-iFT|-WiKi|-HDAccess|-LEGi0N";

@interface Library ()

@property (strong, nonatomic) NSDictionary *tmdbConfig;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation Library

@synthesize context, tmdbConfig;

+(id)sharedInstance
{
    static Library *sharedTmdbInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
    {
        sharedTmdbInstance = [[self alloc] init];

        AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
        NSPersistentStoreCoordinator *coordinator = [appDelegate persistentStoreCoordinator];

        sharedTmdbInstance.context = [[NSManagedObjectContext alloc] init];
        [sharedTmdbInstance.context setPersistentStoreCoordinator:coordinator];
    });
    
    return sharedTmdbInstance;
}

-(void)notifyScanComplete:(NSString *)type
{
    [self.context save:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationScanComplete object:type];
    });
}

#pragma mark - Scanner

-(void)scanForDeleted:(NSString *)entityName
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    [request setPropertiesToFetch:@[@"path"]];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:request error:&error];
    
    if(!error)
    {
        [result enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop)
        {
            if([entityName isEqualToString:@"Movie"])
            {
                Movie *movie = (Movie *)object;
                NSURL *url = [NSURL URLWithString:movie.path];
                if([[NSFileManager defaultManager] fileExistsAtPath:url.path] == NO){
                    [self.context deleteObject:movie];
                }
            }
            else if([entityName isEqualToString:@"TVEpisode"])
            {
                TVEpisode *episode = (TVEpisode *)object;
                NSURL *url = [NSURL URLWithString:episode.path];
                if([[NSFileManager defaultManager] fileExistsAtPath:url.path] == NO){
                    [self.context deleteObject:episode];
                }
            }
        }];
    }
    else {
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    
    // Check for empty Shows
    error = nil;
    NSFetchRequest *showsRequest = [[NSFetchRequest alloc] initWithEntityName:@"TVShow"];
    [showsRequest setPredicate:[NSPredicate predicateWithFormat:@"episodes.@count = 0"]];
    NSArray *shows = [self.context executeFetchRequest:showsRequest error:&error];
    
    if(!error && shows.count > 0){
        [shows enumerateObjectsUsingBlock:^(TVShow *show, NSUInteger idx, BOOL *stop){
            [self.context deleteObject:show];
        }];
    }
}

-(void)scanMoviesLibrary
{
    if(!self.tmdbConfig)
    {
        [self getTMDBConfig:^(BOOL success)
        {
            if(success){
                [self scanMoviesLibrary];
            }
            else {
                [self notifyScanComplete:@"Movies"];
            }
        }];
        
        return;
    }
    
    NSURL *destination;
    
    NSString *path  = [[NSUserDefaults standardUserDefaults] objectForKey:kMoviesLibraryPathKey];
    
    if([Utils isNilOrEmpty:path]){
        [Utils showError:@"Please set library path first!"];
        return;
    }
    else {
        destination = [NSURL URLWithString:path];
    }
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    NSDirectoryEnumerator *dirEnumerator = [fm enumeratorAtURL:destination
                                    includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                       options:NSDirectoryEnumerationSkipsHiddenFiles
                                                  errorHandler:^BOOL(NSURL *url, NSError *error){
                                                      if(error){
                                                          [Utils showError:error.localizedDescription];
                                                          return NO;
                                                      }
                                                      return YES;
                                                  }];
    
    for(NSURL *theURL in dirEnumerator)
    {
        NSNumber *isDirectory;
        [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        
        if([isDirectory boolValue] == NO)
        {
            CFStringRef fileExtension = (__bridge CFStringRef) [theURL.absoluteString pathExtension];
            CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
            
            if(UTTypeConformsTo(fileUTI, kUTTypeMovie))
            {
                NSString *file = [[theURL absoluteString] lastPathComponent];
                NSString *dir = [[theURL absoluteString] stringByDeletingLastPathComponent];

                if([dir isMatch:[Rx rx:@"sample" ignoreCase:YES]] == NO && [file isMatch:[Rx rx:@"sample" ignoreCase:YES]] == NO && [self movieItemExists:theURL] == NO){
                    [self addMovieItem:theURL];
                }
            }
            
            CFRelease(fileUTI);
        }
    }
    
    [self updateMovieItems];
}

-(void)scanTVShowsLibrary
{
    if(!self.tmdbConfig)
    {
        [self getTMDBConfig:^(BOOL success)
         {
             if(success){
                 [self scanTVShowsLibrary];
             }
             else {
                 [self notifyScanComplete:@"TVEpisode"];
             }
         }];
        
        return;
    }
    
    NSURL *destination;
    
    NSString *path  = [[NSUserDefaults standardUserDefaults] objectForKey:kTVShowsLibraryPathKey];
    
    if([Utils isNilOrEmpty:path]){
        [Utils showError:@"Please set library path first!"];
        return;
    }
    else {
        destination = [NSURL URLWithString:path];
    }
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    NSDirectoryEnumerator *dirEnumerator = [fm enumeratorAtURL:destination
                                    includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                       options:NSDirectoryEnumerationSkipsHiddenFiles
                                                  errorHandler:^BOOL(NSURL *url, NSError *error){
                                                      if(error){
                                                          [Utils showError:error.localizedDescription];
                                                          return NO;
                                                      }
                                                      return YES;
                                                  }];
    
    for(NSURL *theURL in dirEnumerator)
    {
        NSNumber *isDirectory;
        [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        
        if([isDirectory boolValue] == NO)
        {
            CFStringRef fileExtension = (__bridge CFStringRef) [theURL.absoluteString pathExtension];
            CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
            
            if(UTTypeConformsTo(fileUTI, kUTTypeMovie))
            {
                NSString *file = [[theURL absoluteString] lastPathComponent];
                NSString *dir = [[theURL absoluteString] stringByDeletingLastPathComponent];
                
                if([dir isMatch:[Rx rx:@"sample" ignoreCase:YES]] == NO && [file isMatch:[Rx rx:@"sample" ignoreCase:YES]] == NO && [self episodeItemExists:theURL] == NO){
                    [self addTVEpisodeItem:theURL];
                }
            }
            
            CFRelease(fileUTI);
        }
    }
    
    [self updateEpisodeItems];
}

-(NSDictionary *)parseMovieName:(NSURL *)url standardParseFailed:(BOOL)parseFailed
{
    NSString *file   = [[url absoluteString] lastPathComponent];
    file = [file stringByRemovingPercentEncoding];
    file = [file stringByReplacingOccurrencesOfString:@"." withString:@" "];
    file = [file stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    Rx *cleanRX = [Rx rx:@"((.*?)[ |.]([\\d+]{4}))" ignoreCase:YES];
    if(parseFailed) cleanRX = [Rx rx:@".*" ignoreCase:YES];
    
    Rx *yearRX = [Rx rx:@"([\\d+]{4})" ignoreCase:YES];
    
    NSLog(@"%@", [file matches:cleanRX]);
    
    file = [[file matches:cleanRX] firstObject];
    
    if([Utils isNilOrEmpty:file]){
        if(parseFailed) return nil;
        return [self parseMovieName:[NSURL URLWithString:[[url absoluteString] stringByDeletingLastPathComponent]] standardParseFailed:YES];
    }
    
    // Year parser
    NSString *year = [[file matches:yearRX] firstObject];
    year = [year stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([Utils isNilOrEmpty:year]) year = @"";
    
    
    // Name parser
    NSString *name = [file stringByReplacingOccurrencesOfString:year withString:@""];
    
//    NSLog(@"NAME BEFORE : %@", name);
    
    name = [name stringByRemovingPercentEncoding];
    name = [name replace:[Rx rx:releaseTypes ignoreCase:YES] with:@""];
    name = [name replace:[Rx rx:releaseGroups ignoreCase:YES] with:@""];
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
//    NSLog(@"NAME AFTER : %@", name);
    
    return @{@"title":name, @"year":year, @"parsed":@(!parseFailed)};
}

-(NSDictionary *)parseEpisodeName:(NSURL *)url standardParseFailed:(BOOL)parseFailed
{
    NSString *file = [[url absoluteString] lastPathComponent];
    file = [file stringByRemovingPercentEncoding];
    file = [file stringByReplacingOccurrencesOfString:@"." withString:@" "];
    file = [file stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    Rx *cleanRX     = [Rx rx:@"(.*?)[ |.]S([\\d+]{1,2})E([\\d+]{1,2})" ignoreCase:YES];
    Rx *seasonRX    = [Rx rx:@"S([\\d+]{1,2})" ignoreCase:YES];
    Rx *episodeRX   = [Rx rx:@"E([\\d+]{1,2})" ignoreCase:YES];
    
    file = [[file matches:cleanRX] firstObject];
    
    if([Utils isNilOrEmpty:file]){
        if(parseFailed) return nil;
        return [self parseEpisodeName:[NSURL URLWithString:[[url absoluteString] stringByDeletingLastPathComponent]] standardParseFailed:YES];
    }
    
    NSString *seasonId = @"";
    
    // Season parser
    NSString *season = [[file matches:seasonRX] firstObject];
    season = [season stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([Utils isNilOrEmpty:season]) season = @"";
    seasonId = [seasonId stringByAppendingString:season];
    season = [season replace:[Rx rx:@"^(s0|s)" ignoreCase:YES] with:@""];
    
    // Episode parser
    NSString *episode = [[file matches:episodeRX] firstObject];
    episode = [episode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([Utils isNilOrEmpty:episode]) episode = @"";
    seasonId = [seasonId stringByAppendingString:episode];
    episode = [episode replace:[Rx rx:@"^(e0|e)" ignoreCase:YES] with:@""];
    
    // Name parser
    NSString *name = [file stringByReplacingOccurrencesOfString:seasonId withString:@""];
    name = [name replace:[Rx rx:releaseTypes ignoreCase:YES] with:@""];
    name = [name replace:[Rx rx:releaseGroups ignoreCase:YES] with:@""];
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return @{@"name":name, @"season":season, @"episode":episode, @"parsed":@(!parseFailed)};
}

-(NSDictionary *)searchForLocalImages:(NSString *)path
{
    NSString *dir       = [path stringByDeletingLastPathComponent];
    NSString *poster    = [dir stringByAppendingPathComponent:@"poster.jpg"];
    NSString *backdrop  = [dir stringByAppendingPathComponent:@"backdrop.jpg"];

    NSMutableDictionary *response = [NSMutableDictionary new];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[NSURL URLWithString:poster].path isDirectory:nil]){
        [response setObject:[NSURL URLWithString:poster].path forKey:@"poster"];
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[NSURL URLWithString:backdrop].path isDirectory:nil]){
        [response setObject:[NSURL URLWithString:backdrop].path forKey:@"backdrop"];
    }
    
    return response;
}

#pragma mark - TMDB

-(void)updateMovieItems
{
    NSError *error;
    NSFetchRequest *checkExistance = [[NSFetchRequest alloc] init];
    
    [checkExistance setEntity:[NSEntityDescription entityForName:@"Movie" inManagedObjectContext:self.context]];
    [checkExistance setPredicate:[NSPredicate predicateWithFormat:@"tmdbID == 0"]];
    
    NSArray *records = [self.context executeFetchRequest:checkExistance error:&error];
    
    if(!error && records.count > 0)
    {
        __block int scanned = 0;
        
        [records enumerateObjectsUsingBlock:^(Movie *movie, NSUInteger idx, BOOL *stop)
        {
            [self tmdbSearchMovie:movie.title year:movie.year standardSearch:movie.parsed callback:^(NSDictionary *response, BOOL success)
            {
                if(success)
                {
                    Movie *updated = [self updateMovieItem:response forMovie:movie];
                    
                    if(updated)
                    {
                        [self tmdbGetMovieInfo:updated.tmdbID callback:^(NSDictionary *response, BOOL success)
                        {
                            if(success)
                            {
                                updated.budget   = response[@"budget"];
                                updated.status   = response[@"status"];
                                updated.runtime  = response[@"runtime"];
                                updated.tagline  = response[@"tagline"];
                                updated.overview = response[@"overview"];
                            }
                            
                            scanned++;
                            
                            if(scanned >= records.count){
                                [self notifyScanComplete:@"Movie"];
                            }
                        }];
                    }
                }
                else {
                    
                    // Scan folder for images
                    NSDictionary *images = [self searchForLocalImages:movie.path];
                    
                    // Update record
                    if(images[@"poster"]){
                        movie.poster = [NSData dataWithContentsOfFile:images[@"poster"]];
                    }
                    if(images[@"backdrop"]){
                        movie.backdrop = [NSData dataWithContentsOfFile:images[@"backdrop"]];
                    }
                    
                    // Update count
                    scanned++;
                    
                    if(scanned >= records.count){
                        [self notifyScanComplete:@"Movie"];
                    }
                }
            }];
        }];
    }
    else {
        [self notifyScanComplete:@"Movie"];
    }
}

-(void)updateEpisodeItems
{
    NSError *error;
    NSFetchRequest *checkExistance = [[NSFetchRequest alloc] init];
    
    [checkExistance setEntity:[NSEntityDescription entityForName:@"TVEpisode" inManagedObjectContext:self.context]];
    [checkExistance setPredicate:[NSPredicate predicateWithFormat:@"tmdbID == 0"]];
    
    NSArray *records = [self.context executeFetchRequest:checkExistance error:&error];
    
    if(!error && records.count > 0)
    {
        __block int scanned = 0;
        
        [records enumerateObjectsUsingBlock:^(TVEpisode *episode, NSUInteger idx, BOOL *stop)
         {
             [self tmdbSearchTVShow:episode.name standardSearch:episode.parsed callback:^(NSDictionary *response, BOOL success)
              {
                  if(success)
                  {
                      TVShow *series = [self addTVShowItem:response forEpisode:episode];
                      
                      if(series && [Utils isNilOrEmpty:series.overview])
                      {
                          [self tmdbGetTVShowInfo:series.tmdbID callback:^(NSDictionary *response, BOOL success)
                          {
                              if(success)
                              {
                                  series.overview = response[@"overview"];
                              }
                          }];
                      }
                      
                      [self tmdbGetEpisodeInfo:series.tmdbID season:episode.season episode:episode.episode callback:^(NSDictionary *response, BOOL success)
                      {
                          scanned++;
                          
                          if(scanned >= records.count){
                              [self notifyScanComplete:@"TVEpisode"];
                          }
                          
                          [self updateTVEpisodeItem:response forEpisode:episode];
                      }];
                  }
                  else {
                      scanned++;
                      
                      if(scanned >= records.count){
                          [self notifyScanComplete:@"TVEpisode"];
                      }
                  }
              }];
         }];
    }
    else {
        [self notifyScanComplete:@"TVEpisode"];
    }
}

-(void)getTMDBConfig:(void (^)(BOOL success))callbackBlock
{
    if(self.tmdbConfig != nil){
        callbackBlock(YES);
    }
    
    [Utils makeGetRequest:[NSString stringWithFormat:@"%@/configuration", TMDB_API_URL] parameters:@{@"api_key":TMDB_API_KEY} callback:^(id response, BOOL success){
        if(success){
            self.tmdbConfig = response[@"images"];
        }
        callbackBlock(success);
    }];
}

-(void)tmdbSearchMovie:(NSString *)name year:(NSString *)year standardSearch:(BOOL)standardSearch callback:(void (^)(NSDictionary *response, BOOL success))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    params[@"api_key"]          = TMDB_API_KEY;
    params[@"query"]            = name;
    params[@"search_type"]      = standardSearch ? @"phrase" : @"ngram";
    params[@"include_adult"]    = @"true";
    
    if([Utils isNilOrEmpty:year] == NO && [year integerValue] > movieYearChecker){
        params[@"year"] = year;
    }
    
//    NSLog(@"SEARCH %@", params);
    
    [Utils makeGetRequest:[NSString stringWithFormat:@"%@/search/movie", TMDB_API_URL] parameters:params callback:^(id response, BOOL success)
    {
//        NSLog(@"RESPONSE: %@, %d", response, success);
        
         if(success)
         {
             NSMutableDictionary *data = [[response[@"results"] firstObject] mutableCopy];
             
             if(data)
             {
                 data[@"poster"] = [NSString stringWithFormat:@"%@w500%@", self.tmdbConfig[@"base_url"], data[@"poster_path"]];
                 data[@"backdrop"] = [NSString stringWithFormat:@"%@w1280%@", self.tmdbConfig[@"base_url"], data[@"backdrop_path"]];
                 
                 callbackBlock(data, success);
             }
             else {
                 callbackBlock(data, NO);
             }
         }
         else {
             callbackBlock(nil, success);
         }
     }];
}

-(void)tmdbSearchTVShow:(NSString *)name standardSearch:(BOOL)standardSearch callback:(void (^)(NSDictionary *response, BOOL success))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    params[@"api_key"]          = TMDB_API_KEY;
    params[@"query"]            = name;
    params[@"search_type"]      = standardSearch ? @"phrase" : @"ngram";
    
    [Utils makeGetRequest:[NSString stringWithFormat:@"%@/search/tv", TMDB_API_URL] parameters:params callback:^(id response, BOOL success)
     {
         if(success)
         {
             NSMutableDictionary *data = [[response[@"results"] firstObject] mutableCopy];
             
             if(data)
             {
                 data[@"poster"] = [NSString stringWithFormat:@"%@w500%@", self.tmdbConfig[@"base_url"], data[@"poster_path"]];
                 data[@"backdrop"] = [NSString stringWithFormat:@"%@w1280%@", self.tmdbConfig[@"base_url"], data[@"backdrop_path"]];
                 
                 callbackBlock(data, success);
             }
             else {
                 callbackBlock(data, NO);
             }
         }
         else {
             callbackBlock(nil, success);
         }
     }];
}

-(void)tmdbGetMovieInfo:(NSNumber *)movieId callback:(void (^)(NSDictionary *response, BOOL success))callbackBlock
{

    NSString *url = [NSString stringWithFormat:@"%@/movie/%d", TMDB_API_URL, movieId.intValue];
    
    [Utils makeGetRequest:url parameters:@{@"api_key":TMDB_API_KEY} callback:^(id response, BOOL success)
     {
         if(success)
         {
             NSMutableDictionary *data = [response mutableCopy];
             
             if(data){
                 callbackBlock(data, success);
             }
             else {
                 callbackBlock(data, NO);
             }
         }
         else {
             callbackBlock(nil, success);
         }
     }];
}

-(void)tmdbGetTVShowInfo:(NSNumber *)seriesId callback:(void (^)(NSDictionary *response, BOOL success))callbackBlock
{
    NSString *url = [NSString stringWithFormat:@"%@/tv/%d", TMDB_API_URL, seriesId.intValue];
    
    [Utils makeGetRequest:url parameters:@{@"api_key":TMDB_API_KEY} callback:^(id response, BOOL success)
     {
         if(success)
         {
             NSMutableDictionary *data = [response mutableCopy];
             
             if(data)
             {
                 data[@"poster"] = [NSString stringWithFormat:@"%@w500%@", self.tmdbConfig[@"base_url"], data[@"poster_path"]];
                 data[@"backdrop"] = [NSString stringWithFormat:@"%@w1280%@", self.tmdbConfig[@"base_url"], data[@"backdrop_path"]];
                 
                 callbackBlock(data, success);
             }
             else {
                 callbackBlock(data, NO);
             }
         }
         else {
             callbackBlock(nil, success);
         }
     }];
}

-(void)tmdbGetTVSeasonInfo:(NSNumber *)seriesId season:(NSNumber *)season callback:(void (^)(NSDictionary *response, BOOL success))callbackBlock
{
    NSString *url = [NSString stringWithFormat:@"%@/tv/%d/season/%d", TMDB_API_URL, seriesId.intValue, season.intValue];
    
    [Utils makeGetRequest:url parameters:@{@"api_key":TMDB_API_KEY} callback:^(id response, BOOL success)
     {
         if(success)
         {
             NSMutableDictionary *data = [response mutableCopy];
             
             if(data)
             {
                 data[@"poster"] = [NSString stringWithFormat:@"%@w500%@", self.tmdbConfig[@"base_url"], data[@"postter_path"]];
                 callbackBlock(data, success);
             }
             else {
                 callbackBlock(data, NO);
             }
         }
         else {
             callbackBlock(nil, success);
         }
     }];
}

-(void)tmdbGetEpisodeInfo:(NSNumber *)seriesId season:(NSNumber *)season episode:(NSNumber *)episode callback:(void (^)(NSDictionary *response, BOOL success))callbackBlock
{
    NSString *url = [NSString stringWithFormat:@"%@/tv/%d/season/%d/episode/%d", TMDB_API_URL, seriesId.intValue, season.intValue, episode.intValue];
    
    [Utils makeGetRequest:url parameters:@{@"api_key":TMDB_API_KEY} callback:^(id response, BOOL success)
     {
         if(success)
         {
             NSMutableDictionary *data = [response mutableCopy];
             
             if(data)
             {
                 if([Utils isNilOrEmpty:data[@"still_path"]] == NO){
                     data[@"still"] = [NSString stringWithFormat:@"%@w500%@", self.tmdbConfig[@"base_url"], data[@"still_path"]];
                 }
                 callbackBlock(data, success);
             }
             else {
                 callbackBlock(data, NO);
             }
         }
         else {
             callbackBlock(nil, success);
         }
     }];
}

#pragma mark - CoreData

-(Movie *)movieItemExists:(NSURL *)itemUrl
{
    NSError *error;
    NSFetchRequest *checkExistance = [[NSFetchRequest alloc] init];
    
    [checkExistance setEntity:[NSEntityDescription entityForName:@"Movie" inManagedObjectContext:self.context]];
    [checkExistance setFetchLimit:1];
    [checkExistance setPredicate:[NSPredicate predicateWithFormat:@"path == %@", itemUrl.absoluteString]];
    
    NSArray *records = [self.context executeFetchRequest:checkExistance error:&error];
    
    if(!error && records.count > 0){
        return [records firstObject];
    }
    
    return nil;
}

-(TVShow *)showItemExists:(NSNumber *)tmdbID;
{
    NSError *error;
    NSFetchRequest *checkExistance = [[NSFetchRequest alloc] init];
    
    [checkExistance setEntity:[NSEntityDescription entityForName:@"TVShow" inManagedObjectContext:self.context]];
    [checkExistance setFetchLimit:1];
    [checkExistance setPredicate:[NSPredicate predicateWithFormat:@"tmdbID == %@", tmdbID]];
    
    NSArray *record = [self.context executeFetchRequest:checkExistance error:&error];
    
    if(!error && record.count > 0){
        return [record firstObject];
    }
    
    return NO;
}

-(TVEpisode *)episodeItemExists:(NSURL *)itemUrl
{
    NSError *error;
    NSFetchRequest *checkExistance = [[NSFetchRequest alloc] init];
    
    [checkExistance setEntity:[NSEntityDescription entityForName:@"TVEpisode" inManagedObjectContext:self.context]];
    [checkExistance setFetchLimit:1];
    [checkExistance setPredicate:[NSPredicate predicateWithFormat:@"path == %@", itemUrl.absoluteString]];
    
    NSArray *records = [self.context executeFetchRequest:checkExistance error:&error];
    
    if(!error && records.count > 0){
        return [records firstObject];
    }
    
    return nil;
}

-(void)addMovieItem:(NSURL *)url
{
    NSDictionary *data = [self parseMovieName:url standardParseFailed:NO];
    if(!data)return;
    
    Movie *record   = [NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:self.context];
    record.title    = data[@"title"];
    record.year     = ([data[@"year"] integerValue] > movieYearChecker ? data[@"year"] : @"");
    record.path     = url.absoluteString;
    record.parsed   = [data[@"parsed"] boolValue];
    
    NSError *error;
    [self.context save:&error];
    
    if(error){
        NSLog(@"%@", error.localizedDescription);
    }
}

-(Movie *)updateMovieItem:(NSDictionary *)tmdbData forMovie:(Movie *)record
{
    record.tmdbID = tmdbData[@"id"];
    record.adult = tmdbData[@"adult"];
    record.original_title = tmdbData[@"original_title"];
    record.release_date = [[YLMoment momentWithDateAsString:tmdbData[@"release_date"]] date];
    record.vote_average = tmdbData[@"vote_average"];
    record.vote_count = tmdbData[@"vote_count"];
    record.popularity = tmdbData[@"popularity"];
    record.overview = tmdbData[@"overview"];
    record.poster = [NSData dataWithContentsOfURL:[NSURL URLWithString:tmdbData[@"poster"]]];
    record.poster_path = tmdbData[@"poster_path"];
    record.backdrop = [NSData dataWithContentsOfURL:[NSURL URLWithString:tmdbData[@"backdrop"]]];
    record.backdrop_path = tmdbData[@"backdrop_path"];
    
    NSError *error;
    [self.context save:&error];
    
    if(error){
        NSLog(@"%@", error.localizedDescription);
        return nil;
    }
    
    return record;
}

-(TVShow *)addTVShowItem:(NSDictionary *)tmdbData forEpisode:(TVEpisode *)episode
{
    TVShow *existing = [self showItemExists:tmdbData[@"id"]];
    
    if(existing)
    {
        episode.show = existing;
        
        NSError *error;
        [self.context save:&error];
        
        if(error){
            NSLog(@"%@", error.localizedDescription);
            return nil;
        }
        
        return existing;
    }
    
    // Add new
    TVShow *record = [NSEntityDescription insertNewObjectForEntityForName:@"TVShow" inManagedObjectContext:self.context];
    
    record.tmdbID = tmdbData[@"id"];
    record.name = tmdbData[@"name"];
    record.original_name = tmdbData[@"original_name"];
    record.first_air_date = [[YLMoment momentWithDateAsString:tmdbData[@"first_air_date"]] date];
    record.vote_average = tmdbData[@"vote_average"];
    record.vote_count = tmdbData[@"vote_count"];
    record.popularity = tmdbData[@"popularity"];
    record.overview = tmdbData[@"overview"];

    record.poster = [NSData dataWithContentsOfURL:[NSURL URLWithString:tmdbData[@"poster"]]];
    record.poster_path = tmdbData[@"poster_path"];
    record.backdrop = [NSData dataWithContentsOfURL:[NSURL URLWithString:tmdbData[@"backdrop"]]];
    record.backdrop_path = tmdbData[@"backdrop_path"];
    
    episode.show = record;
    
    NSError *error;
    [self.context save:&error];
    
    if(error){
        NSLog(@"%@", error.localizedDescription);
        return nil;
    }
    
    return record;
}

-(void)addTVEpisodeItem:(NSURL *)url
{
    NSDictionary *data = [self parseEpisodeName:url standardParseFailed:NO];
    if(!data)return;
    
    TVEpisode *record  = [NSEntityDescription insertNewObjectForEntityForName:@"TVEpisode" inManagedObjectContext:self.context];
    record.name     = data[@"name"];
    record.season   = [NSNumber numberWithInt:[data[@"season"] intValue]];
    record.episode  = [NSNumber numberWithInt:[data[@"episode"] intValue]];
    record.path     = [url absoluteString];
    record.parsed   = [data[@"parsed"] boolValue];
    
    NSError *error;
    [self.context save:&error];
    
    if(error){
        NSLog(@"%@", error.localizedDescription);
    }
}

-(TVEpisode *)updateTVEpisodeItem:(NSDictionary *)tmdbData forEpisode:(TVEpisode *)record
{
    record.tmdbID = (tmdbData[@"id"] ? tmdbData[@"id"] : 0);
    record.original_name = [Utils stringValue:tmdbData[@"name"]];
    record.still_path = [Utils stringValue:tmdbData[@"still_path"]];
    record.air_date = [[YLMoment momentWithDateAsString:tmdbData[@"air_date"]] date];
    record.vote_average = (tmdbData[@"vote_average"] ? tmdbData[@"vote_average"] : 0);
    record.vote_count = (tmdbData[@"vote_count"] ? tmdbData[@"vote_count"] : 0);
    record.overview = [Utils stringValue:tmdbData[@"overview"]];
    record.still = (tmdbData[@"still"] ? [NSData dataWithContentsOfURL:[NSURL URLWithString:tmdbData[@"still"]]] : nil);
    
    NSError *error;
    [self.context save:&error];
    
    if(error){
        NSLog(@"%@", error.localizedDescription);
        return nil;
    }
    
    return record;
}

#pragma mark - Misc


@end
