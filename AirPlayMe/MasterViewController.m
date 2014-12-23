//
//  MasterViewController.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 17.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "MasterViewController.h"
#import "SettingsViewController.h"
#import "BrowserViewController.h"
#import "Config.h"
#import "MainButton.h"
#import "Library.h"
#import "AppDelegate.h"
#import "CustomButton.h"

#import "MovieDetailsViewController.h"
#import "TVShowDetailsViewController.h"

@interface MasterViewController ()

@property (weak) IBOutlet NSView *headerView;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSButton *scanButton;
@property (weak) IBOutlet NSSegmentedControl *filterControl;
@property (weak) IBOutlet CustomButton *playlistButton;

@property (strong, nonatomic) NSViewController *currentViewController;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation MasterViewController
@synthesize currentViewController, scrollView, context;

#pragma mark - Navigation

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
    self.context = appDelegate.managedObjectContext;
    
    self.view.layer.backgroundColor = WINDOW_COLOR.CGColor;
    
    CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
    [lighten setDefaults];
    [lighten setValue:@0.3 forKey:@"inputBrightness"];
    [self.progressIndicator setContentFilters:@[lighten]];
    
    NSShadow *dropShadow = [[NSShadow alloc] init];
    [dropShadow setShadowColor:SHADOW_COLOR];
    [dropShadow setShadowOffset:NSMakeSize(0, 0)];
    [dropShadow setShadowBlurRadius:5.0];
    
    [self.headerView.superview setWantsLayer: YES];
    [self.headerView.layer setBackgroundColor:WINDOW_COLOR.CGColor];
    [self.headerView setShadow:dropShadow];
    
    self.scrollView.backgroundColor = BACKGROUND_COLOR;
    self.scrollView.automaticallyAdjustsContentInsets = NO;
    
    long previous  = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastSectionKey] integerValue];
    long buttonTag = (previous > 0 ? previous : 1);
    
    [self toggleViewController:[self.view viewWithTag:buttonTag]];
    [self renderPlaylistButton:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoItem:) name:kNotificationPlayItem object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playListContent:) name:kNotificationPlayList object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderPlaylistButton:) name:kNotificationPlaylistItemAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openMovieDetails:) name:kNotificationOpenMovieDetails object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openTVShowDetails:) name:kNotificationOpenTVShowDetails object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanCompleted:) name:kNotificationScanComplete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(browseModeChanged:) name:kNotificationApplyBrowseMode object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLibrary:) name:kNotificationUpdateCurrentLibrary object:nil];
}

-(void)browseModeChanged:(NSNotification *)notification
{
    long buttonTag = [notification.object integerValue];
    [self toggleViewController:[self.view viewWithTag:buttonTag]];
}

-(void)updateLibrary:(NSNotification *)notification
{
    BrowseControllerMode mode = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastSectionKey] integerValue];
    
    if(mode == BrowseControllerTVShows){
        [self scanTVShowsLibrary];
    }
    else {
        [self scanMoviesLibrary];
    }
}

-(IBAction)toggleViewController:(NSButton *)sender
{
    BrowseControllerMode mode = (BrowseControllerMode)sender.tag;
    
    [[NSUserDefaults standardUserDefaults] setObject:@(mode) forKey:kLastSectionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    for(int i=1; i<=2; i++)
    {
        if(i != mode){
            [(MainButton*)[self.view viewWithTag:i] setInactive];
        }
        else {
            [(MainButton*)[self.view viewWithTag:i] setActive];
        }
    }
    
    if(self.currentViewController){
        [self.currentViewController.view removeFromSuperview];
        self.currentViewController = nil;
    }
    
    if(mode == BrowseControllerMovies)
    {
        NSInteger selected  = [[[NSUserDefaults standardUserDefaults] objectForKey:kMoviesFilterKey] integerValue];
        
        if(self.filterControl.segmentCount < 3){
            [self.filterControl setSegmentCount:3];
            [self.filterControl setLabel:@"Watched" forSegment:2];
        }
        
        [self.filterControl setHidden:NO];
        [self.filterControl setSelectedSegment:(selected >= 3 ? 0 : selected)];
        
        // Load it
        BrowserViewController *vc = [self.storyboard instantiateControllerWithIdentifier:@"browserViewController"];
        [vc setType:BrowseMovies];
        [vc setFilter:(FilterType) self.filterControl.selectedSegment];
        
        self.currentViewController = vc;
        
    }
    else if(mode == BrowseControllerTVShows)
    {
        NSInteger selected = [[[NSUserDefaults standardUserDefaults] objectForKey:kTVShowsFilterKey] integerValue];
        
        [self.filterControl setHidden:NO];
        [self.filterControl setSegmentCount:2];
        [self.filterControl setSelectedSegment:(selected >= 2 ? 0 : selected)];
        
        // Load it
        BrowserViewController *vc = [self.storyboard instantiateControllerWithIdentifier:@"browserViewController"];
        [vc setType:BrowseTVShows];
        [vc setFilter:(FilterType) self.filterControl.selectedSegment];
        
        self.currentViewController = vc;
    }
    
    [self layoutCurrentViewController];
}

-(void)layoutCurrentViewController
{
    [self.scrollView setHorizontalScrollElasticity:NSScrollElasticityNone];
    [self.scrollView setVerticalScrollElasticity:NSScrollElasticityNone];
    
    [self.scrollView setDocumentView:self.currentViewController.view];
    [self.currentViewController.view setFrameSize:self.scrollView.frame.size];
    
    [self.currentViewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.currentViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
}

#pragma mark - Play Item / List

-(void)playVideoItem:(NSNotification *)notification
{
    NSString *path = notification.object;
    
    if([Utils isNilOrEmpty:path] == NO)
    {
        NSURL *url = [NSURL URLWithString:path];
        
        [[NSWorkspace sharedWorkspace] openFile:url.path withApplication:PLAYER_APP_NAME];
    }
}

-(void)playListContent:(NSNotification *)notification
{
    NSMutableArray *playList = [NSMutableArray new];

    [[Utils getPlayListItems] enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop){
        [playList addObject:[NSURL URLWithString:path]];
    }];
    
    [[NSWorkspace sharedWorkspace] openURLs:playList withAppBundleIdentifier:PLAYER_BUNDLE_ID options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifiers:nil];
}

#pragma mark - Open Details

-(void)openMovieDetails:(NSNotification *)notification
{
    self.filterControl.hidden = YES;
    
    MovieDetailsViewController *dc = [[MovieDetailsViewController alloc] initWithNibName:@"MovieDetailsViewController" bundle:nil];
    [dc setTmdbID:((Movie *)notification.object).tmdbID];
    
    if(self.currentViewController){
        [self.currentViewController.view removeFromSuperview];
        self.currentViewController = nil;
    }
    
    self.currentViewController = dc;
    [self layoutCurrentViewController];
}

-(void)openTVShowDetails:(NSNotification *)notification
{
    self.filterControl.hidden = YES;
    
    TVShowDetailsViewController *dc = [[TVShowDetailsViewController alloc] initWithNibName:@"TVShowDetailsViewController" bundle:nil];
    [dc setShow:(TVShow *)notification.object];
    
    if(self.currentViewController){
        [self.currentViewController.view removeFromSuperview];
        self.currentViewController = nil;
    }
    
    self.currentViewController = dc;
    [self layoutCurrentViewController];
}

#pragma mark - Playlist Management

-(IBAction)showPlaylist:(id)sender
{
    if(self.playlistButton.disabled) return;
    
    NSMutableArray *allItems = [NSMutableArray new];
    NSArray *list = [Utils getPlayListItems];
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Play All" action:@selector(playListContent:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    
    if(list.count > 0)
    {
        NSFetchRequest *r1 = [[NSFetchRequest alloc] initWithEntityName:@"Movie"];
        NSFetchRequest *r2 = [[NSFetchRequest alloc] initWithEntityName:@"TVEpisode"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"path IN %@", list];
        [r1 setPredicate:predicate];
        [r2 setPredicate:predicate];
        
        [r2 setSortDescriptors:@[
                                 [NSSortDescriptor sortDescriptorWithKey:@"show.name" ascending:YES],
                                 [NSSortDescriptor sortDescriptorWithKey:@"season" ascending:YES],
                                 [NSSortDescriptor sortDescriptorWithKey:@"episode" ascending:YES]]];
        
        NSError *e1;
        NSError *e2;
        
        NSArray *movies   = [self.context executeFetchRequest:r1 error:&e1];
        NSArray *episodes = [self.context executeFetchRequest:r2 error:&e2];
        
        if(!e1 && movies.count > 0){
            [allItems addObject:[[NSMenuItem alloc] initWithTitle:@"Movies:" action:nil keyEquivalent:@""]];
            [allItems addObjectsFromArray:movies];
        }
        
        if(!e2 && episodes.count > 0){
            [allItems addObject:[[NSMenuItem alloc] initWithTitle:@"TV Shows:" action:nil keyEquivalent:@""]];
            [allItems addObjectsFromArray:episodes];
        }
    }
    
    [allItems enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop)
    {
        NSString *title;
        
        if([item isKindOfClass:[Movie class]]){
            Movie *movie = (Movie *)item;
            title = [NSString stringWithFormat:@"%@ (%@)", movie.original_title, [[YLMoment momentWithDate:movie.release_date] format:@"YYYY"]];
        }
        else if([item isKindOfClass:[TVEpisode class]]){
            TVEpisode *episode = (TVEpisode *)item;
            title = [NSString stringWithFormat:@"%@ S%02ldE%02ld (%@)", episode.show.original_name, episode.season.integerValue, episode.episode.integerValue, episode.original_name];
        }
        else if([item isKindOfClass:[NSMenuItem class]]){
            [menu addItem:item];
        }
        
        if(title){
            NSMenuItem *mi = [menu addItemWithTitle:title action:@selector(removeFromPlaylist:) keyEquivalent:@""];
            [mi setRepresentedObject:item];
        }
    }];
    
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Clear Playlist" action:@selector(clearPlaylist:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Set as Watched" action:@selector(setAsWatched:) keyEquivalent:@""];
    
    NSRect frame = [(NSButton *)sender frame];
    NSPoint menuOrigin = [[(NSButton *)sender superview] convertPoint:NSMakePoint(frame.origin.x, frame.origin.y+frame.size.height-30) toView:nil];
    
    NSEvent *event =  [NSEvent mouseEventWithType:NSLeftMouseDown
                                         location:menuOrigin
                                    modifierFlags:NSDeviceIndependentModifierFlagsMask
                                        timestamp:0
                                     windowNumber:[[(NSButton *)sender window] windowNumber]
                                          context:[[(NSButton *)sender window] graphicsContext]
                                      eventNumber:0
                                       clickCount:1
                                         pressure:1];
    
    [NSMenu popUpContextMenu:menu withEvent:event forView:(NSButton *)sender];
}

-(IBAction)clearPlaylist:(id)sender
{
    [Utils clearPlaylist];
    [self renderPlaylistButton:nil];
}

-(void)removeFromPlaylist:(NSMenuItem *)sender
{
    NSString *path = [sender.representedObject valueForKey:@"path"];
    [Utils removeFromPlaylist:path];
    
    [self renderPlaylistButton:nil];
}

-(void)renderPlaylistButton:(NSNotification *)notification
{
    self.playlistButton.enabled = NO;
    
    NSArray *list = [Utils getPlayListItems];
    
    if(list.count > 0){
        self.playlistButton.enabled = YES;
    }
    
    self.playlistButton.title = [NSString stringWithFormat:@"Playlist (%ld)", list.count];
}

-(void)setAsWatched:(NSMenuItem *)sender
{
    NSArray *list = [Utils getPlayListItems];
    
    if(list.count > 0)
    {
        NSMutableArray *allItems = [NSMutableArray new];
        
        NSFetchRequest *r1 = [[NSFetchRequest alloc] initWithEntityName:@"Movie"];
        NSFetchRequest *r2 = [[NSFetchRequest alloc] initWithEntityName:@"TVEpisode"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"path IN %@", list];
        [r1 setPredicate:predicate];
        [r2 setPredicate:predicate];
    
        [allItems addObjectsFromArray:[self.context executeFetchRequest:r1 error:nil]];
        [allItems addObjectsFromArray:[self.context executeFetchRequest:r2 error:nil]];
        
        [allItems enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop)
        {
             if([item isKindOfClass:[Movie class]]){
                 Movie *movie = (Movie *)item;
                 movie.watched = YES;
             }
             else if([item isKindOfClass:[TVEpisode class]]){
                 TVEpisode *episode = (TVEpisode *)item;
                 episode.watched = YES;
             }
        }];
        
        [self.context save:nil];
    }
}

#pragma mark - Scanner & Filters

-(IBAction)toggleScannerMenu:(CustomButton *)sender
{
    if(sender.disabled) return;
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Movies" action:@selector(scanMoviesLibrary) keyEquivalent:@""];
    [menu addItemWithTitle:@"TV Shows" action:@selector(scanTVShowsLibrary) keyEquivalent:@""];
    
    NSRect frame = [(NSButton *)sender frame];
    NSPoint menuOrigin = [[(NSButton *)sender superview] convertPoint:NSMakePoint(frame.origin.x, frame.origin.y+frame.size.height-30) toView:nil];
    
    NSEvent *event =  [NSEvent mouseEventWithType:NSLeftMouseDown
                                         location:menuOrigin
                                    modifierFlags:NSDeviceIndependentModifierFlagsMask
                                        timestamp:0
                                     windowNumber:[[(NSButton *)sender window] windowNumber]
                                          context:[[(NSButton *)sender window] graphicsContext]
                                      eventNumber:0
                                       clickCount:1
                                         pressure:1];
    
    [NSMenu popUpContextMenu:menu withEvent:event forView:(NSButton *)sender];
}

-(IBAction)applyFilter:(NSSegmentedControl *)sender
{
    NSNumber *currentFilterType;
    BrowseType currentBrowseType = ((BrowserViewController *)self.currentViewController).type;
    
    if(sender.selectedSegment == 0){
        currentFilterType = @(FilterAll);
    }
    else if(sender.selectedSegment == 1){
        currentFilterType = @(FilterNew);
    }
    else if(sender.selectedSegment == 2){
        currentFilterType = @(FilterWatched);
    }
    
    if(currentBrowseType == BrowseMovies){
        [[NSUserDefaults standardUserDefaults] setObject:currentFilterType forKey:kMoviesFilterKey];
    }
    else if (currentBrowseType == BrowseTVShows){
        [[NSUserDefaults standardUserDefaults] setObject:currentFilterType forKey:kTVShowsFilterKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationApplyBrowseFilter object:currentFilterType];
}

-(void)scanMoviesLibrary
{
    [self.scanButton setEnabled:NO];
    [self.scanButton setTitle:@"Updating Movies..."];
    
    [self.progressIndicator startAnimation:self];
    
    dispatch_queue_t queue = dispatch_queue_create("com.ptfly.airplayme.scan.movies", NULL);
    dispatch_async(queue, ^{
        [[Library sharedInstance] scanForDeleted:@"Movie"];
        [[Library sharedInstance] scanMoviesLibrary];
    });
}

-(void)scanTVShowsLibrary
{
    [self.scanButton setEnabled:NO];
    [self.scanButton setTitle:@"Updating TV Shows..."];
    [self.progressIndicator startAnimation:self];
    
    dispatch_queue_t queue = dispatch_queue_create("com.ptfly.airplayme.scan.tvshows", NULL);
    dispatch_async(queue, ^{
        [[Library sharedInstance] scanForDeleted:@"TVEpisode"];
        [[Library sharedInstance] scanTVShowsLibrary];
    });
}

-(void)scanCompleted:(NSNotification *)notification
{
    [self.scanButton setEnabled:YES];
    [self.scanButton setTitle:@"Update Library"];
    [self.progressIndicator stopAnimation:self];
}

#pragma mark - Other

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
