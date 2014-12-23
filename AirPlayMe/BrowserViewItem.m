//
//  BrowserViewItem.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 19.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "BrowserViewItem.h"
#import "AppDelegate.h"
#import "Library.h"
#import "ShadowView.h"

@interface BrowserViewItem () <NSMenuDelegate>

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (weak) IBOutlet NSImageView *watchedIcon;
@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSLayoutConstraint *yearFieldPosition;
@end

@implementation BrowserViewItem
@synthesize nameField, imageView;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
    
    self.context = appDelegate.managedObjectContext;
    
    self.playButton.hidden = YES;
    self.infoField.stringValue = @"";
    
    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:self.imageView.frame options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil];
    [self.view addTrackingArea:area];
}

-(IBAction)openDetails:(NSGestureRecognizer *)sender
{
    if(sender.state != NSGestureRecognizerStateEnded) return;
    
    if([[[self.representedObject valueForKey:@"entity"] valueForKey:@"name"] isEqualToString:@"TVShow"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOpenTVShowDetails object:self.representedObject];
    }
    else if([[[self.representedObject valueForKey:@"entity"] valueForKey:@"name"] isEqualToString:@"Movie"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOpenMovieDetails object:self.representedObject];
    }
}

-(IBAction)playVideo:(id)sender
{
    if([[[self.representedObject valueForKey:@"entity"] valueForKey:@"name"] isEqualToString:@"Movie"]){
        Movie *movie = (Movie *) self.representedObject;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayItem object:movie.path];
    }
}

-(void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
    
    if([representedObject isKindOfClass:[TVShow class]])
    {
        TVShow *show = (TVShow *)representedObject;
        
        self.watchedIcon.hidden = YES;
        self.imageView.image = [[NSImage alloc] initWithData:show.poster];
        self.nameField.stringValue = show.original_name;
        
        __block long unwatched = 0;
        [show.episodes enumerateObjectsUsingBlock:^(TVEpisode *episode, BOOL *stop){
            if(episode.watched == NO){
                unwatched += 1;
            }
        }];
        
        self.yearField.stringValue = [NSString stringWithFormat:@"%ld episodes, %ld new", show.episodes.count, unwatched];
    }
    else if([representedObject isKindOfClass:[Movie class]])
    {
        Movie *movie = (Movie *)representedObject;
        
        self.nameField.stringValue = movie.title;
        self.yearField.stringValue = movie.year;
        self.watchedIcon.hidden = !movie.watched;
        
        if(movie.watched){
            self.yearFieldPosition.constant = 35;
        }
        
        if(movie.poster){
            self.imageView.image = [[NSImage alloc] initWithData:movie.poster];
        }
        
        if([movie.tmdbID intValue] > 0){
            self.nameField.stringValue = movie.original_title;
            self.yearField.stringValue = [[YLMoment momentWithDate:movie.release_date] format:@"YYYY"];
        }
    }
    
    self.nameField.toolTip = self.nameField.stringValue;
    [self.view needsLayout];
}

-(void)mouseEntered:(NSEvent *)theEvent
{
    if([[[self.representedObject valueForKey:@"entity"] valueForKey:@"name"] isEqualToString:@"Movie"]){
        self.playButton.hidden = NO;
    }
}

-(void)mouseExited:(NSEvent *)theEvent
{
    self.playButton.hidden = YES;
}

-(IBAction)addToPlaylist:(id)sender
{
    Movie *movie = (Movie *) self.representedObject;
    
    [Utils addToPlaylist:movie.path];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlaylistItemAdded object:movie];
}

-(IBAction)setAsWatched:(id)sender
{
    NSError *error;
    Movie *movie = (Movie *) self.representedObject;
    movie.watched = !movie.watched;
    
    self.watchedIcon.hidden = !movie.watched;
    
    if(movie.watched){
        self.yearFieldPosition.constant = 35;
    }
    else {
        self.yearFieldPosition.constant = 12;
    }
    
    [self.context save:&error];
    
    if(error){
        [Utils showError:error.localizedDescription];
    }
}

-(IBAction)showInFinder:(id)sender
{
    Movie *movie = (Movie *) self.representedObject;
    
    NSURL *url = [NSURL URLWithString:movie.path];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[url]];
}

-(IBAction)playLocally:(id)sender
{
    Movie *movie = (Movie *)self.representedObject;
    NSURL *url = [NSURL URLWithString:movie.path];
    
    [[NSWorkspace sharedWorkspace] openFile:url.path];
}

-(IBAction)deleteFromLibrary:(id)sender
{
    [self.context deleteObject:self.representedObject];
    [self.context save:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationScanComplete object:nil];
}

#pragma mark - Episodes Menu

-(void)menuWillOpen:(NSMenu *)menu
{
    if([[[self.representedObject valueForKey:@"entity"] valueForKey:@"name"] isEqualToString:@"Movie"])
    {
        Movie *movie = (Movie *)self.representedObject;
        
        if(movie.watched){
            [[menu itemAtIndex:1] setTitle:@"Set as Unwatched"];
        }
        else {
            [[menu itemAtIndex:1] setTitle:@"Set as Watched"];
        }
        
        [[menu itemAtIndex:0] setHidden:NO];
        [[menu itemAtIndex:1] setHidden:NO];
        [[menu itemAtIndex:2] setHidden:NO];
        [[menu itemAtIndex:3] setHidden:NO];
        [[menu itemAtIndex:4] setHidden:NO];
        [[menu itemAtIndex:5] setHidden:NO];
        [[menu itemAtIndex:6] setHidden:NO];
    }
    else if([[[self.representedObject valueForKey:@"entity"] valueForKey:@"name"] isEqualToString:@"TVShow"]){
        [[menu itemAtIndex:0] setHidden:YES];
        [[menu itemAtIndex:1] setHidden:YES];
        [[menu itemAtIndex:2] setHidden:YES];
        [[menu itemAtIndex:3] setHidden:YES];
        [[menu itemAtIndex:4] setHidden:NO];
        [[menu itemAtIndex:5] setHidden:YES];
        [[menu itemAtIndex:6] setHidden:YES];
    }
}

@end
