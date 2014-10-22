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

#import "MovieDetailsViewController.h"
#import "TVShowDetailsViewController.h"

@interface MasterViewController ()

@property (weak) IBOutlet NSView *masterView;
@property (weak) IBOutlet NSView *headerView;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSPopUpButton *scanLibraryButton;

@property (strong, nonatomic) IBOutlet NSViewController *currentViewController;

@end

@implementation MasterViewController
@synthesize currentViewController;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.layer.backgroundColor = WINDOW_COLOR.CGColor;
    
    NSShadow *dropShadow = [[NSShadow alloc] init];
    [dropShadow setShadowColor:SHADOW_COLOR];
    [dropShadow setShadowOffset:NSMakeSize(0, 0)];
    [dropShadow setShadowBlurRadius:10.0];
    
    [self.headerView.superview setWantsLayer: YES];
    [self.headerView.layer setBackgroundColor:WINDOW_COLOR.CGColor];
    [self.headerView setShadow:dropShadow];
    
    [(MainButton*)[self.view viewWithTag:1] setActive];
    [self toggleViewController:[self.view viewWithTag:1]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoItem:) name:kNotificationPlayItem object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openMovieDetails:) name:kNotificationOpenMovieDetails object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openTVShowDetails:) name:kNotificationOpenTVShowDetails object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanCompleted:) name:kNotificationScanComplete object:nil];
}

-(void)playVideoItem:(NSNotification *)notification
{
    NSString *path = notification.object[@"path"];
    NSLog(@"PLAY: %@", path);
}

-(void)openMovieDetails:(NSNotification *)notification
{
    MovieDetailsViewController *dc = [[MovieDetailsViewController alloc] initWithNibName:@"MovieDetailsViewController" bundle:nil];
    [dc setMovie:(Movie *)notification.object];
    
    if(self.currentViewController){
        [self.currentViewController.view removeFromSuperview];
        self.currentViewController = nil;
    }
    
    self.currentViewController = dc;
    [self layoutCurrentViewController];
}

-(void)openTVShowDetails:(NSNotification *)notification
{
    TVShowDetailsViewController *dc = [[TVShowDetailsViewController alloc] initWithNibName:@"TVShowDetailsViewController" bundle:nil];
    [dc setShow:(TVShow *)notification.object];
    
    if(self.currentViewController){
        [self.currentViewController.view removeFromSuperview];
        self.currentViewController = nil;
    }
    
    self.currentViewController = dc;
    [self layoutCurrentViewController];
}

-(IBAction)scanDirectory:(NSPopUpButton *)sender
{
    long selected = sender.selectedTag;
    
    [sender setEnabled:NO];
    [sender selectItemAtIndex:0];
    [sender.selectedItem setState:NSOffState];
    [sender.selectedItem setTitle:@"Updating..."];
    
    if(selected == 1){
        NSThread *thread = [[NSThread alloc] initWithTarget:[Library sharedInstance] selector:@selector(scanMoviesLibrary) object:nil];
        [thread start];
    }
    else if(selected == 2){
        NSThread *thread = [[NSThread alloc] initWithTarget:[Library sharedInstance] selector:@selector(scanTVShowsLibrary) object:nil];
        [thread start];
    }
    else {
        [sender setEnabled:YES];
        [Utils showError:@"Invalid library"];
    }
}

-(void)scanCompleted:(NSNotification *)notification
{
    [self.scanLibraryButton setEnabled:YES];
    [self.scanLibraryButton selectItemAtIndex:0];
    [self.scanLibraryButton.selectedItem setState:NSOffState];
    [self.scanLibraryButton.selectedItem setTitle:@"Update Library"];
}

-(IBAction)toggleViewController:(NSButton *)sender
{
    for(int i=1; i<=3; i++)
    {
        if(i != sender.tag){
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
    
    if(sender.tag == 1)
    {
        BrowserViewController *vc = [self.storyboard instantiateControllerWithIdentifier:@"browserViewController"];
        [vc setType:BrowseMovies];
        self.currentViewController = vc;
    }
    else if(sender.tag == 2)
    {
        BrowserViewController *vc = [self.storyboard instantiateControllerWithIdentifier:@"browserViewController"];
        [vc setType:BrowseTVShows];
        self.currentViewController = vc;
    }
    else if(sender.tag == 3)
    {
        SettingsViewController *vc = [self.storyboard instantiateControllerWithIdentifier:@"settingViewController"];
        self.currentViewController = vc;
    }
    
    [self layoutCurrentViewController];
}

-(void)layoutCurrentViewController
{
    [self.masterView addSubview:self.currentViewController.view];
    [self.currentViewController.view setFrame:self.masterView.bounds];
    [self.currentViewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.currentViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
