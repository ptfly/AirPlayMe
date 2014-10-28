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
#import "Config.h"
#import "Movie.h"

@interface BrowserViewController () <NSCollectionViewDelegate>

@property (weak, nonatomic) IBOutlet NSTextField *typeLabel;
@property (weak, nonatomic) IBOutlet NSArrayController *arrayController;
@property (weak, nonatomic) IBOutlet NSCollectionView *collectionView;

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSArray *sortDescriptors;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSFetchRequest *request;

@end

@implementation BrowserViewController
@synthesize context, items, filter;
@synthesize type = _type;
@synthesize sortDescriptors = _sortDescriptors;
@synthesize request = _request;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
    
    self.context = appDelegate.managedObjectContext;
    
    self.collectionView.itemPrototype = [BrowserViewItem new];
    self.collectionView.content = self.arrayController.content;
    
    [self loadItems:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyFilter:) name:kNotificationApplyBrowseFilter object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadItems:) name:kNotificationScanComplete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.context];
}

-(void)applyFilter:(NSNotification *)notification
{
    self.filter = (FilterType)[notification.object unsignedIntegerValue];
    [self loadItems:notification];
}

-(void)loadItems:(NSNotification *)notification
{    
    NSError *error;
    self.items = [self.context executeFetchRequest:self.request error:&error];
    
    if(error){
        NSLog(@"%@", error.localizedDescription);
    }
    else {
        if(notification){
            self.collectionView.content = self.arrayController.content;
        }
    }
}

-(void)viewWillAppear
{
    [super viewWillAppear];
    [self.collectionView setContent:self.arrayController.content];
}

-(NSFetchRequest *)request
{
    if(_request == nil)
    {
        if(_type == BrowseMovies){
            _request = [[NSFetchRequest alloc] initWithEntityName:@"Movie"];
        }
        else if(_type == BrowseTVShows){
            _request = [[NSFetchRequest alloc] initWithEntityName:@"TVShow"];
        }
        
        [_request setSortDescriptors:self.sortDescriptors];
        [_request setReturnsObjectsAsFaults:NO];
    }
    
    if(self.filter != FilterAll && _type == BrowseMovies)
    {
        if(self.filter == FilterNew){
            [_request setPredicate:[NSPredicate predicateWithFormat:@"watched = NO"]];
        }
        else if(self.filter == FilterWatched){
            [_request setPredicate:[NSPredicate predicateWithFormat:@"watched = YES"]];
        }
    }
    else {
        [_request setPredicate:nil];
    }
    
    return _request;
}

-(NSArray *)sortDescriptors
{
    if(_sortDescriptors == nil)
    {
        NSMutableArray *descriptors = [NSMutableArray new];
        
        if(self.type == BrowseMovies){
            [descriptors addObject:[[NSSortDescriptor alloc] initWithKey:@"original_title" ascending:YES]];
            [descriptors addObject:[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES]];
            [descriptors addObject:[[NSSortDescriptor alloc] initWithKey:@"year" ascending:NO]];
        }
        else if(self.type == BrowseTVShows){
            [descriptors addObject:[[NSSortDescriptor alloc] initWithKey:@"original_name" ascending:YES]];
            [descriptors addObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
            [descriptors addObject:[[NSSortDescriptor alloc] initWithKey:@"first_air_date" ascending:YES]];
        }
        
        _sortDescriptors = descriptors;
    }
    
    return _sortDescriptors;
}

-(void)contextDidChange:(NSNotification *)notification
{
//    NSArray *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
//    NSArray *deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
//    NSArray *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
