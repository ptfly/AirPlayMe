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

@interface MovieDetailsViewController ()

@property (weak) IBOutlet EDStarRating *ratingIndicator;
@property (weak) IBOutlet NSImageView *posterImageView;
@property (weak) IBOutlet NSImageView *backdropImageView;
@property (weak) IBOutlet NSTextField *movieTitleLabel;
@property (weak) IBOutlet NSTextField *movieDescriptionLabel;
@property (weak) IBOutlet NSTextField *tagLine;
@property (strong) IBOutlet BackDropView *backDropView;

@property (weak) IBOutlet NSLayoutConstraint *titleHeight;
@property (weak) IBOutlet NSLayoutConstraint *descriptionHeight;
@property (weak) IBOutlet NSLayoutConstraint *tagLineHeight;
@property (weak) IBOutlet NSLayoutConstraint *tagLineTopSpace;

@property (weak) IBOutlet NSTextField *infoBox1;
@property (weak) IBOutlet NSTextField *infoBox2;
@property (weak) IBOutlet NSTextField *infoBox3;
@property (weak) IBOutlet NSTextField *infoBox4;
@end

@implementation MovieDetailsViewController
@synthesize movie;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *title = [Utils isNilOrEmpty:movie.original_title] == NO ? movie.original_title : movie.title;
    NSString *overview = [Utils isNilOrEmpty:movie.overview] == NO ? movie.overview : @"N/A";
    
    self.movieTitleLabel.stringValue = title;
    self.movieDescriptionLabel.stringValue = overview;
    self.posterImageView.image = [[NSImage alloc] initWithData:movie.poster];
    self.backDropView.image = [[NSImage alloc] initWithData:movie.backdrop];
//    self.backDropView.alphaValue = 0.3;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setCurrencySymbol:@""];
    
    self.tagLine.stringValue  = movie.tagline;
    
    if([Utils isNilOrEmpty:movie.tagline]){
        self.tagLineHeight.constant = 0;
        self.tagLineTopSpace.constant = 0;
    }
    
    self.infoBox1.stringValue = [NSString stringWithFormat:@"Votes: %d\nRating: %.02f/10", movie.vote_count.intValue, movie.vote_average.floatValue];
    self.infoBox2.stringValue = [NSString stringWithFormat:@"Status: %@\nReleased: %@", movie.status, [[YLMoment momentWithDate:movie.release_date] format:@"dd MMMM YYYY"]];
    self.infoBox3.stringValue = [NSString stringWithFormat:@"Runtime: %@\nPopularity: %.02f", [self timeFormatted:movie.runtime.intValue*60], movie.popularity.floatValue];
    self.infoBox4.stringValue = [NSString stringWithFormat:@"Adult: %@\nBudget: %@", (movie.adult.boolValue == YES ? @"Yes" : @"No"), (movie.budget.intValue == 0 ? @"N/A" : [numberFormatter stringFromNumber:movie.budget])];
    
    self.ratingIndicator.backgroundColor  = [NSColor clearColor];
    self.ratingIndicator.starImage = [NSImage imageNamed:@"Star-Empty"];
    self.ratingIndicator.starHighlightedImage = [NSImage imageNamed:@"Star-Full"];
    self.ratingIndicator.maxRating = 5;
    self.ratingIndicator.horizontalMargin = 0;
    self.ratingIndicator.rating= movie.vote_average.floatValue/2;
    self.ratingIndicator.displayMode=EDStarRatingDisplayAccurate;
    [self.ratingIndicator setNeedsDisplay];
}

-(NSString *)timeFormatted:(int)totalSeconds
{
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%dh %02dm",hours, minutes];
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

@end
