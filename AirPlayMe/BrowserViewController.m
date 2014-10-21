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

@interface BrowserViewController () <NSCollectionViewDelegate>

@property (weak, nonatomic) IBOutlet NSTextField *typeLabel;
@property (weak, nonatomic) IBOutlet NSArrayController *arrayController;
@property (weak, nonatomic) IBOutlet NSCollectionView *collectionView;

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSIndexSet *selectedIndexes;
@property (strong, nonatomic) NSArray *sortDescriptors;

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
    
    if(_type == BrowseMovies){
        self.arrayController.entityName = @"Movie";
    }
    else if(_type == BrowseTVShows){
        self.arrayController.entityName = @"TVShow";
    }
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

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
