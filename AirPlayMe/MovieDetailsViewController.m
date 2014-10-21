//
//  MovieDetailsViewController.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 21.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import "AutoHeightField.h"

@interface MovieDetailsViewController ()

@property (weak) IBOutlet NSImageView *posterImageView;
@property (weak) IBOutlet NSImageView *backdropImageView;
@property (weak) IBOutlet NSTextField *movieTitleLabel;
@property (weak) IBOutlet NSTextField *movieDescriptionLabel;

@property (weak) IBOutlet NSLayoutConstraint *titleHeight;
@property (weak) IBOutlet NSLayoutConstraint *descriptionHeight;
@end

@implementation MovieDetailsViewController
@synthesize movie;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowBlurRadius:3.0];
    [shadow setShadowColor:SHADOW_COLOR];
    [shadow setShadowOffset:CGSizeMake(0, 1)];
    
    [self.movieTitleLabel setShadow:shadow];
    [self.movieDescriptionLabel setShadow:shadow];
    
    NSString *title = [Utils isNilOrEmpty:movie.original_title] == NO ? movie.original_title : movie.title;
    NSString *overview = [Utils isNilOrEmpty:movie.overview] == NO ? movie.overview : @"N/A";
    
    self.movieTitleLabel.stringValue = title;
    self.movieDescriptionLabel.stringValue = overview;

    self.posterImageView.image = [[NSImage alloc] initWithData:movie.poster];
    self.backdropImageView.image = [[NSImage alloc] initWithData:movie.backdrop];
    self.backdropImageView.alphaValue = 0.3;
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
    NSURL *url = [NSURL URLWithString:self.movie.path];
    [[NSWorkspace sharedWorkspace] openFile:url.path withApplication:@"Beamer"];
}

-(IBAction)close:(id)sender
{
    
}


@end
