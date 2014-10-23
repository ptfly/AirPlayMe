//
//  TVShowDetailsViewController.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 21.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "TVShowDetailsViewController.h"
#import "Config.h"
#import "EDStarRating.h"
#import "AppDelegate.h"
#import "BackDropView.h"
#import "CustomTableRow.h"
#import "ShadowTextField.h"

@interface TVShowDetailsViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSImageView *posterImageView;
@property (weak) IBOutlet NSTextField *showTitleLabel;
@property (weak) IBOutlet NSTextField *showDescriptionLabel;
@property (weak) IBOutlet EDStarRating *ratingIndicator;
@property (weak) IBOutlet NSTextField *infoBox1;
@property (weak) IBOutlet NSTextField *infoBox2;
@property (weak) IBOutlet NSTextField *infoBox3;
@property (strong) IBOutlet BackDropView *backDropView;

@property (weak) IBOutlet NSLayoutConstraint *titleHeight;
@property (weak) IBOutlet NSLayoutConstraint *descriptionHeight;

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSMutableDictionary *scheme;

@property (strong, nonatomic) NSArray *sortedSeasons;
@property (strong, nonatomic) NSArray *sortedEpisodes;

@property (weak) IBOutlet NSTableView *seasonsTableView;
@property (weak) IBOutlet NSTableView *episodesTableView;
@property (weak) IBOutlet BackDropView *episodeDetailsView;

@property (weak) IBOutlet NSTextField *episodeTitle;
@property (weak) IBOutlet NSTextField *episodeOverview;
@property (weak) IBOutlet ShadowTextField *episodeInfoBox1;
@property (weak) IBOutlet ShadowTextField *episodeInfoBox2;

@end

@implementation TVShowDetailsViewController
@synthesize show, context, scheme;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    self.context = delegate.managedObjectContext;
    self.scheme = [NSMutableDictionary dictionary];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TVEpisode"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"show = %@", show]];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"season" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"episode" ascending:YES]]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest: request error: &error];
    
    if(!error && results.count > 0)
    {
        [results enumerateObjectsUsingBlock:^(TVEpisode *episode, NSUInteger idx, BOOL *stop)
        {
            NSString *key = [NSString stringWithFormat:@"%d", episode.season.intValue];
            
            if(![self.scheme objectForKey:key]){
                [self.scheme setObject:[NSMutableArray array] forKey:key];
            }
            
            NSMutableArray *episodes = (NSMutableArray *)[self.scheme objectForKey:key];
            [episodes addObject:episode];
        }];
    }
    
    NSString *title = [Utils isNilOrEmpty:show.original_name] == NO ? show.original_name : show.name;
    NSString *overview = [Utils isNilOrEmpty:show.overview] == NO ? show.overview : @"N/A";
    
    self.showTitleLabel.stringValue = title;
    self.showDescriptionLabel.stringValue = overview;
    self.posterImageView.image = [[NSImage alloc] initWithData:show.poster];
    self.backDropView.image = [[NSImage alloc] initWithData:show.backdrop];
    
    self.infoBox1.stringValue = [NSString stringWithFormat:@"Votes: %d\nRating: %.02f/10", show.vote_count.intValue, show.vote_average.floatValue];
    self.infoBox2.stringValue = [NSString stringWithFormat:@"First Air Date:\n%@", [[YLMoment momentWithDate:show.first_air_date] format:@"dd MMMM YYYY"]];
    self.infoBox3.stringValue = [NSString stringWithFormat:@"Seasons: %ld\nEpisodes: %ld", self.scheme.allKeys.count, show.episodes.count];
    
    self.ratingIndicator.backgroundColor  = [NSColor clearColor];
    self.ratingIndicator.starImage = [NSImage imageNamed:@"Star-Empty"];
    self.ratingIndicator.starHighlightedImage = [NSImage imageNamed:@"Star-Full"];
    self.ratingIndicator.maxRating = 5;
    self.ratingIndicator.horizontalMargin = 0;
    self.ratingIndicator.rating= show.vote_average.floatValue/2;
    self.ratingIndicator.displayMode=EDStarRatingDisplayAccurate;
    [self.ratingIndicator setNeedsDisplay];
    
    self.seasonsTableView.wantsLayer = YES;
    self.seasonsTableView.layer.cornerRadius = 5;
    self.seasonsTableView.layer.masksToBounds = YES;
    [self.seasonsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    
    self.episodesTableView.wantsLayer = YES;
    self.episodesTableView.layer.cornerRadius = 5;
    self.episodesTableView.layer.masksToBounds = YES;
    [self.episodesTableView setDoubleAction:@selector(play:)];
    [self.episodesTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    
    // SORT
//    NSArray *sortedKeys = [[self.scheme allKeys] sortedArrayUsingSelector: @selector(compare:)];
//    NSMutableArray *sortedValues = [NSMutableArray array];
//    for(NSString *key in sortedKeys){
//        [sortedValues addObject:[self.scheme objectForKey:key]];
//    }
//    NSLog(@"%@", sortedValues);
}

-(void)play:(id)sender
{
    TVEpisode *episode = self.scheme.allValues[self.seasonsTableView.selectedRow][self.episodesTableView.selectedRow];
    if(episode){
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayItem object:episode.path];
    }
}

-(void)displayDetails:(TVEpisode *)episode
{
    if(episode.still){
        self.episodeDetailsView.image = [[NSImage alloc] initWithData:episode.still];
    }
    else {
        self.episodeDetailsView.image = nil;
    }

    self.episodeTitle.stringValue = episode.original_name;
    self.episodeOverview.stringValue = episode.overview;
    self.episodeInfoBox1.stringValue = [NSString stringWithFormat:@"Season: %d\nEpisode: %d", episode.season.intValue, episode.episode.intValue];
    self.episodeInfoBox2.stringValue = [NSString stringWithFormat:@"Rating: %d/%.02f\nAir Date:\n%@", episode.vote_count.intValue, episode.vote_average.floatValue, [[YLMoment momentWithDate:episode.air_date] format:@"dd MMMM YYYY"]];

    [self.episodeDetailsView setNeedsDisplay:YES];
}

-(void)viewWillLayout
{
    [super viewWillLayout];
    
    NSTextField *t1 = self.showTitleLabel;
    NSTextField *t2 = self.showDescriptionLabel;
    self.titleHeight.constant = 5 + [Utils heightForString:t1.stringValue font:t1.font containerWidth:t1.bounds.size.width];
    self.descriptionHeight.constant = 5 + [Utils heightForString:t2.stringValue font:t2.font containerWidth:t2.bounds.size.width];
}

-(IBAction)close:(id)sender
{
    
}

-(IBAction)setAsWatched:(id)sender
{
    
    NSLog(@"%@", sender);
}

#pragma mark - TableViews

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if([tableView.identifier isEqualTo:@"seasonsTableView"]){
        return self.scheme.allKeys.count;
    }
    else if([tableView.identifier isEqualTo:@"episodesTableView"]){
        if(self.seasonsTableView.selectedRow >= 0){
            return [self.scheme.allValues[self.seasonsTableView.selectedRow] count];
        }
    }
    
    return 0;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if([[tableColumn identifier] isEqualToString:@"seasonNameColumn"])
    {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"seasonNameCell" owner:self];
        cell.textField.stringValue = [NSString stringWithFormat:@"Season %@", self.scheme.allKeys[row]];
        return cell;
    }
    else if([[tableColumn identifier] isEqualToString:@"episodeNameColumn"])
    {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"episodeNameCell" owner:self];
        
        TVEpisode *episode = self.scheme.allValues[self.seasonsTableView.selectedRow][row];
        cell.textField.stringValue = [NSString stringWithFormat:@"%d. %@", episode.episode.intValue, episode.original_name];
        cell.imageView.image = [NSImage imageNamed:(episode.watched ? @"Eye-Active" : @"Eye")];
        
//        NSCursor *cursor = [NSCursor pointingHandCursor];
//        [cell.imageView addCursorRect:cell.imageView.bounds cursor:cursor];
//        [cursor setOnMouseEntered:YES];
        
        return cell;
    }
    
    return nil;
}

-(void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
//    rowView.backgroundColor = [NSColor redColor];
}

-(NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    static NSString* const kRowIdentifier = @"RowView";
    
    CustomTableRow *rowView = [tableView makeViewWithIdentifier:kRowIdentifier owner:self];
    
    if (!rowView) {
        rowView = [[CustomTableRow alloc] initWithFrame:NSZeroRect];
        rowView.identifier = kRowIdentifier;
    }
    
    // Can customize properties here. Note that customizing
    // 'backgroundColor' isn't going to work at this point since the table
    // will reset it later. Use 'didAddRow' to customize if desired.
    
    return rowView;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    long selectedRow = [[notification object] selectedRow];
    NSTableView *tableView = [notification object];
    
    if([tableView.identifier isEqualToString:@"seasonsTableView"]){
        [self.episodesTableView reloadData];
    }
    else if([tableView.identifier isEqualToString:@"episodesTableView"]){
        NSArray *episodes = self.scheme.allValues[self.seasonsTableView.selectedRow];
        TVEpisode *episode = episodes[selectedRow];
        [self displayDetails:episode];
    }
}


@end