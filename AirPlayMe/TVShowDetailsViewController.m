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
@property (strong, nonatomic) NSMutableArray *scheme;
@property (strong, nonatomic) TVEpisode *selectedEpisode;

@property (weak) IBOutlet NSTableView *seasonsTableView;
@property (weak) IBOutlet NSTableView *episodesTableView;
@property (weak) IBOutlet BackDropView *episodeDetailsView;

@property (weak) IBOutlet NSTextField *episodeTitle;
@property (weak) IBOutlet NSTextField *episodeOverview;
@property (weak) IBOutlet ShadowTextField *episodeInfoBox1;
@property (weak) IBOutlet ShadowTextField *episodeInfoBox2;
@property (weak) IBOutlet NSScrollView *scrollViewSeasons;
@property (weak) IBOutlet NSScrollView *scrollViewEpisodes;
@property (weak) IBOutlet NSImageView *watchedButton;

@end

@implementation TVShowDetailsViewController
@synthesize show, context, scheme = _scheme;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    self.context = delegate.managedObjectContext;
    
    NSString *title = [Utils isNilOrEmpty:show.original_name] == NO ? show.original_name : show.name;
    NSString *overview = [Utils isNilOrEmpty:show.overview] == NO ? show.overview : @"N/A";
    
    self.showTitleLabel.stringValue = title;
    self.showDescriptionLabel.stringValue = overview;
    self.posterImageView.image = [[NSImage alloc] initWithData:show.poster];
    self.backDropView.image = [[NSImage alloc] initWithData:show.backdrop];
    
    self.infoBox1.stringValue = [NSString stringWithFormat:@"Votes: %d\nRating: %.02f/10", show.vote_count.intValue, show.vote_average.floatValue];
    self.infoBox2.stringValue = [NSString stringWithFormat:@"First Air Date:\n%@", [[YLMoment momentWithDate:show.first_air_date] format:@"dd MMMM YYYY"]];
    self.infoBox3.stringValue = [NSString stringWithFormat:@"Seasons: %ld\nEpisodes: %ld", self.scheme.count, show.episodes.count];
    
    self.ratingIndicator.backgroundColor  = [NSColor clearColor];
    self.ratingIndicator.starImage = [NSImage imageNamed:@"Star-Empty"];
    self.ratingIndicator.starHighlightedImage = [NSImage imageNamed:@"Star-Full"];
    self.ratingIndicator.maxRating = 5;
    self.ratingIndicator.horizontalMargin = 0;
    self.ratingIndicator.rating= show.vote_average.floatValue/2;
    self.ratingIndicator.displayMode=EDStarRatingDisplayAccurate;
    [self.ratingIndicator setNeedsDisplay];
    
    self.scrollViewSeasons.wantsLayer = YES;
    self.scrollViewSeasons.layer.cornerRadius = 5;
    self.scrollViewSeasons.layer.masksToBounds = YES;
    
    [self.seasonsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    
    self.scrollViewEpisodes.wantsLayer = YES;
    self.scrollViewEpisodes.layer.cornerRadius = 5;
    self.scrollViewEpisodes.layer.masksToBounds = YES;
    
    [self.episodesTableView setDoubleAction:@selector(play:)];
    [self.episodesTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.context];
}

-(void)contextDidChange:(NSNotification *)notification
{
//    NSArray *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
}

-(NSMutableArray *)scheme
{
    if(_scheme == nil)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TVEpisode"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"show = %@", show]];
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"season" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"episode" ascending:YES]]];
        
        NSError *error = nil;
        NSArray *results = [context executeFetchRequest: request error: &error];
        
        NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
        self.scheme = [NSMutableArray new];
        
        if(!error && results.count > 0)
        {
            [results enumerateObjectsUsingBlock:^(TVEpisode *episode, NSUInteger idx, BOOL *stop)
             {
                 NSString *key = [NSString stringWithFormat:@"%d", episode.season.intValue];
                 
                 if(![tmp objectForKey:key]){
                     [tmp setObject:[NSMutableArray array] forKey:key];
                 }
                 
                 NSMutableArray *episodes = (NSMutableArray *)[tmp objectForKey:key];
                 [episodes addObject:episode];
             }];
        }
        
        // SORT
        
        NSArray *sortedKeys = [[tmp allKeys] sortedArrayUsingSelector: @selector(compare:)];
        for(NSString *key in sortedKeys){
            [self.scheme addObject:@{@"season": key, @"episodes": [tmp objectForKey:key]}];
            
        }
        tmp = nil;
    }
    
    return _scheme;
}

-(void)play:(id)sender
{
    TVEpisode *episode = self.scheme[self.seasonsTableView.selectedRow][@"episodes"][self.episodesTableView.selectedRow];
    if(episode){
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayItem object:episode.path];
    }
}

-(void)displayEpisodeDetails
{
    if(self.selectedEpisode.still){
        self.episodeDetailsView.image = [[NSImage alloc] initWithData:self.selectedEpisode.still];
    }
    else {
        self.episodeDetailsView.image = nil;
    }
    
    self.episodeTitle.stringValue = [Utils stringValue:self.selectedEpisode.original_name];
    self.episodeOverview.stringValue = [Utils stringValue:self.selectedEpisode.overview];
    self.episodeInfoBox1.stringValue = [NSString stringWithFormat:@"Season: %d\nEpisode: %d", self.selectedEpisode.season.intValue, self.selectedEpisode.episode.intValue];
    self.episodeInfoBox2.stringValue = [NSString stringWithFormat:@"Rating: %d/%.02f\nAir Date: %@", self.selectedEpisode.vote_count.intValue, self.selectedEpisode.vote_average.floatValue, [[YLMoment momentWithDate:self.selectedEpisode.air_date] format:@"d MMMM YYYY"]];
    
    self.watchedButton.image = [NSImage imageNamed:(self.selectedEpisode.watched ? @"Eye-Active" : @"Eye")];
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
    if(!self.selectedEpisode) return;
    
    NSError *error;
    self.selectedEpisode.watched = !self.selectedEpisode.watched;
    
    [self.context save:&error];
    
    if(error){
        [Utils showError:error.localizedDescription];
    }
    else {
        self.watchedButton.image = [NSImage imageNamed:(self.selectedEpisode.watched ? @"Eye-Active" : @"Eye")];
        
        NSTableCellView *selectedCell = [self.episodesTableView viewAtColumn:self.episodesTableView.selectedColumn row:self.episodesTableView.selectedRow makeIfNecessary:NO];
        selectedCell.imageView.image = (self.selectedEpisode.watched ? [NSImage imageNamed:@"Eye"] : nil);
    }
}

#pragma mark - TableViews

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if([tableView.identifier isEqualTo:@"seasonsTableView"]){
        return self.scheme.count;
//        return self.scheme.allKeys.count;
    }
    else if([tableView.identifier isEqualTo:@"episodesTableView"]){
        if(self.seasonsTableView.selectedRow >= 0){
//            return [self.scheme.allValues[self.seasonsTableView.selectedRow] count];
            return [self.scheme[self.seasonsTableView.selectedRow][@"episodes"] count];
        }
    }
    
    return 0;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if([[tableColumn identifier] isEqualToString:@"seasonNameColumn"])
    {
        NSString *count = [NSString stringWithFormat:@" / %ld episodes", [self.scheme[row][@"episodes"] count]];
        NSString *sname = [NSString stringWithFormat:@"Season %@", self.scheme[row][@"season"]];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", sname, count]];
        [string addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, sname.length)];
        [string addAttribute:NSForegroundColorAttributeName value:[NSColor grayColor] range:NSMakeRange(sname.length,count.length)];
        [string addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:10] range:NSMakeRange(sname.length,count.length)];
        
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"seasonNameCell" owner:self];
        cell.textField.attributedStringValue = string;
        return cell;
    }
    else if([[tableColumn identifier] isEqualToString:@"episodeNameColumn"])
    {
        NSArray *episodes = self.scheme[self.seasonsTableView.selectedRow][@"episodes"];
        
        if(episodes[row] == nil)
        {
            NSLog(@"SEASON: %ld EPI: %ld", self.seasonsTableView.selectedRow, row+1);
            return nil;
        }
        
        TVEpisode *episode = episodes[row];
        
        NSString *numbr = [NSString stringWithFormat:@"%02d. ", episode.episode.intValue];
        NSString *sname = [NSString stringWithFormat:@"%@", episode.original_name];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", numbr, sname]];
        [string addAttribute:NSForegroundColorAttributeName value:[NSColor grayColor] range:NSMakeRange(0, numbr.length)];
        [string addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(numbr.length, sname.length)];
        
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"episodeNameCell" owner:self];
        cell.textField.attributedStringValue = string;
        
        if(episode.watched){
            cell.imageView.image = [NSImage imageNamed:@"Eye"];
        }
        else {
            cell.imageView.image = nil;
        }
        
        return cell;
    }
    
    return nil;
}

-(NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    static NSString* const kRowIdentifier = @"RowView";
    
    CustomTableRow *rowView = [tableView makeViewWithIdentifier:kRowIdentifier owner:self];
    
    if (!rowView) {
        rowView = [[CustomTableRow alloc] initWithFrame:NSZeroRect];
        rowView.identifier = kRowIdentifier;
    }
    
    return rowView;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableView = [notification object];
    
    if([tableView.identifier isEqualToString:@"seasonsTableView"]){
        [self.episodesTableView reloadData];
    }
    else if([tableView.identifier isEqualToString:@"episodesTableView"])
    {
        long selectedRow = [[notification object] selectedRow];
        
        NSArray *episodes = self.scheme[self.seasonsTableView.selectedRow][@"episodes"];
        TVEpisode *episode = episodes[selectedRow];
        
        if(episode){
            self.selectedEpisode = episode;
            [self displayEpisodeDetails];
        }
        else {
            NSLog(@"Episode idx %ld not found, total: %ld", selectedRow, episodes.count);
        }
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end