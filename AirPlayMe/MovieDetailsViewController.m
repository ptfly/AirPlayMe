//
//  MovieDetailsViewController.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 21.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import "EDStarRating.h"
#import "BackDropView.h"
#import "AppDelegate.h"

@interface MovieDetailsViewController ()

@property (weak) IBOutlet EDStarRating *ratingIndicator;
@property (weak) IBOutlet NSImageView *posterImageView;
@property (weak) IBOutlet NSImageView *backdropImageView;
@property (weak) IBOutlet NSTextField *movieTitleLabel;
@property (weak) IBOutlet NSTextField *movieDescriptionLabel;
@property (weak) IBOutlet NSTextField *tagLine;

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong) IBOutlet BackDropView *backDropView;

@property (weak) IBOutlet NSLayoutConstraint *titleHeight;
@property (weak) IBOutlet NSLayoutConstraint *descriptionHeight;
@property (weak) IBOutlet NSLayoutConstraint *tagLineHeight;
@property (weak) IBOutlet NSLayoutConstraint *tagLineTopSpace;
@property (weak) IBOutlet NSImageView *watchedIcon;

@property (weak) IBOutlet NSTextField *infoBox1;
@property (weak) IBOutlet NSTextField *infoBox2;
@property (weak) IBOutlet NSTextField *infoBox3;
@property (weak) IBOutlet NSTextField *infoBox4;
@end

@implementation MovieDetailsViewController
@synthesize movie = _movie, tmdbID;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    self.context = delegate.managedObjectContext;
    
    NSString *title = [Utils isNilOrEmpty:self.movie.original_title] == NO ? self.movie.original_title : self.movie.title;
    NSString *overview = [Utils isNilOrEmpty:self.movie.overview] == NO ? self.movie.overview : @"N/A";
    
    self.movieTitleLabel.stringValue = title;
    self.movieDescriptionLabel.stringValue = overview;
    self.posterImageView.image = [[NSImage alloc] initWithData:self.movie.poster];
    self.backDropView.image = [[NSImage alloc] initWithData:self.movie.backdrop];
    self.watchedIcon.image = [NSImage imageNamed:(self.movie.watched ? @"Eye-Active" : @"Eye")];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setCurrencySymbol:@""];
    
    self.tagLine.stringValue  = [Utils stringValue:self.movie.tagline];
    
    if([Utils isNilOrEmpty:self.movie.tagline]){
        self.tagLineHeight.constant = 0;
        self.tagLineTopSpace.constant = 0;
    }
    
    self.infoBox1.stringValue = [NSString stringWithFormat:@"Votes: %d\nRating: %.02f/10", self.movie.vote_count.intValue, self.movie.vote_average.floatValue];
    self.infoBox2.stringValue = [NSString stringWithFormat:@"Status: %@\nReleased: %@", [Utils stringValue:self.movie.status], [[YLMoment momentWithDate:self.movie.release_date] format:@"dd MMMM YYYY"]];
    self.infoBox3.stringValue = [NSString stringWithFormat:@"Runtime: %@\nPopularity: %.02f", [self timeFormatted:self.movie.runtime.intValue*60], self.movie.popularity.floatValue];
    self.infoBox4.stringValue = [NSString stringWithFormat:@"Adult: %@\nBudget: %@", (self.movie.adult.boolValue == YES ? @"Yes" : @"No"), (self.movie.budget.intValue == 0 ? @"N/A" : [numberFormatter stringFromNumber:self.movie.budget])];
    
    self.ratingIndicator.backgroundColor  = [NSColor clearColor];
    self.ratingIndicator.starImage = [NSImage imageNamed:@"Star-Empty"];
    self.ratingIndicator.starHighlightedImage = [NSImage imageNamed:@"Star-Full"];
    self.ratingIndicator.maxRating = 5;
    self.ratingIndicator.horizontalMargin = 0;
    self.ratingIndicator.rating= self.movie.vote_average.floatValue/2;
    self.ratingIndicator.displayMode=EDStarRatingDisplayAccurate;
    [self.ratingIndicator setNeedsDisplay];
}

-(Movie *)movie
{
    if(_movie == nil)
    {
        [self.context reset];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Movie"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"tmdbID = %@", self.tmdbID]];
        [request setFetchLimit:1];
        
        NSError *error;
        NSArray *data = [self.context executeFetchRequest:request error:&error];
        
        if(error){
            [Utils showError:error.localizedDescription];
            _movie = nil;
        }
        else {
            _movie = [data firstObject];
        }
    }
    
    return _movie;
}

-(NSString *)timeFormatted:(int)totalSeconds
{
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%dh %02dm", hours, minutes];
}

-(void)viewWillLayout
{
    [super viewWillLayout];
    
    NSTextField *t1 = self.movieTitleLabel;
    NSTextField *t2 = self.movieDescriptionLabel;
    self.titleHeight.constant = 5 + [Utils heightForString:t1.stringValue font:t1.font containerWidth:t1.bounds.size.width];
    self.descriptionHeight.constant = 5 + [Utils heightForString:t2.stringValue font:t2.font containerWidth:t2.bounds.size.width];
}

-(IBAction)playMovie:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayItem object:self.movie.path];
}

-(IBAction)setAsWatched:(id)sender
{
    NSError *error;
    self.movie.watched = !self.movie.watched;
    
    [self.context save:&error];
    
    if(error){
        [Utils showError:error.localizedDescription];
    }
    else {
        self.watchedIcon.image = [NSImage imageNamed:(self.movie.watched ? @"Eye-Active" : @"Eye")];
    }
}

@end
