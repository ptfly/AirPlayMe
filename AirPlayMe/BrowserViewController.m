//
//  BrowserViewController.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 17.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "BrowserViewController.h"
#import "AppDelegate.h"
#import "BrowserViewItem.h"
#import "Utils.h"
#import "Library.h"

@interface BrowserViewController () <NSCollectionViewDelegate>

@property (weak, nonatomic) IBOutlet NSTextField *typeLabel;
@property (weak, nonatomic) IBOutlet NSArrayController *arrayController;
@property (weak, nonatomic) IBOutlet NSCollectionView *collectionView;

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSIndexSet *selectedIndexes;
@property (strong, nonatomic) NSArray *sortDescriptors;
@property (strong, nonatomic) TVShow *selectedShow;

@end

@implementation BrowserViewController
@synthesize context;
@synthesize type = _type;
@synthesize sortDescriptors = _sortDescriptors;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
    
    self.context = appDelegate.managedObjectContext;
    self.arrayController.managedObjectContext = self.context;
    self.collectionView.itemPrototype = [BrowserViewItem new];
    
    [self fetchData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoItem:) name:kNotificationPlayItem object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(browseTVShow:) name:kNotificationBrowseTVShow object:nil];
}

-(void)playVideoItem:(NSNotification *)notification
{
    NSString *path = notification.object[@"path"];
    NSLog(@"PLAY: %@", path);
}

-(void)browseTVShow:(NSNotification *)notification
{
    _type = BrowseTVEpisodes;
    self.selectedShow = (TVShow *)notification.object;
    [self fetchData];
}

-(void)fetchData
{
    if(_type == BrowseMovies){
        self.typeLabel.stringValue = @"Movies";
        self.arrayController.entityName = @"Movie";
    }
    else if(_type == BrowseTVShows){
        self.typeLabel.stringValue = @"TV Shows";
        self.arrayController.entityName = @"TVShow";
    }
    else if(_type == BrowseTVEpisodes){
        self.typeLabel.stringValue = [NSString stringWithFormat:@"TV Shows > %@", self.selectedShow.name];
        self.arrayController.entityName = @"TVEpisode";
    }
    
    [self.arrayController fetch:nil];
}

-(NSArray *)sortDescriptors
{
    if(_sortDescriptors == nil)
    {
        NSMutableArray *descriptors = [NSMutableArray new];
        
        if(self.type == BrowseMovies){
            [descriptors addObject:[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES]];
            [descriptors addObject:[[NSSortDescriptor alloc] initWithKey:@"year" ascending:NO]];
        }
        else if(self.type == BrowseTVShows){
            [descriptors addObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
            [descriptors addObject:[[NSSortDescriptor alloc] initWithKey:@"first_air_date" ascending:YES]];
        }
        if(self.type == BrowseTVEpisodes){
            [descriptors addObject:[[NSSortDescriptor alloc] initWithKey:@"season" ascending:YES]];
            [descriptors addObject:[[NSSortDescriptor alloc] initWithKey:@"episode" ascending:YES]];
            [descriptors addObject:[[NSSortDescriptor alloc] initWithKey:@"original_name" ascending:YES]];
        }
        
        _sortDescriptors = descriptors;
    }
    
    return _sortDescriptors;
}

-(IBAction)scanDirectory:(id)sender
{
    if(self.type == BrowseMovies){
        NSThread *thread = [[NSThread alloc] initWithTarget:[Library sharedInstance] selector:@selector(scanMoviesLibrary) object:nil];
        [thread start];
    }
    else if(self.type == BrowseTVShows){
        NSThread *thread = [[NSThread alloc] initWithTarget:[Library sharedInstance] selector:@selector(scanTVShowsLibrary) object:nil];
        [thread start];
    }
}

-(IBAction)goBack:(id)sender
{
    if(self.selectedShow){
        _type = BrowseTVShows;
        self.selectedShow = nil;
        [self fetchData];
    }
}

@end
