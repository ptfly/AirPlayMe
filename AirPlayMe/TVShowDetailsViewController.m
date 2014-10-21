//
//  TVShowDetailsViewController.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 21.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "TVShowDetailsViewController.h"
#import "Config.h"

@interface TVShowDetailsViewController ()

@property (weak) IBOutlet NSImageView *posterImageView;
@property (weak) IBOutlet NSImageView *backdropImageView;
@property (weak) IBOutlet NSTextField *showTitleLabel;
@property (weak) IBOutlet NSTextField *showDescriptionLabel;

@property (weak) IBOutlet NSLayoutConstraint *titleHeight;
@property (weak) IBOutlet NSLayoutConstraint *descriptionHeight;
@end

@implementation TVShowDetailsViewController
@synthesize show;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowBlurRadius:3.0];
    [shadow setShadowColor:SHADOW_COLOR];
    [shadow setShadowOffset:CGSizeMake(0, 1)];
    
    [self.showTitleLabel setShadow:shadow];
    [self.showDescriptionLabel setShadow:shadow];
    
    NSString *name = [Utils isNilOrEmpty:show.original_name] == NO ? show.original_name : show.name;
    NSString *overview = [Utils isNilOrEmpty:show.overview] == NO ? show.overview : @"N/A";
    
    self.showTitleLabel.stringValue = name;
    self.showDescriptionLabel.stringValue = overview;
    
    self.posterImageView.image = [[NSImage alloc] initWithData:show.poster];
    self.backdropImageView.image = [[NSImage alloc] initWithData:show.backdrop];
    self.backdropImageView.alphaValue = 0.3;
}

-(void)viewWillLayout
{
    [super viewWillLayout];
    
    NSTextField *t1 = self.showTitleLabel;
    NSTextField *t2 = self.showDescriptionLabel;
    self.titleHeight.constant = 5 + [Utils heightForString:t1.stringValue font:t1.font containerWidth:t1.bounds.size.width];
    self.descriptionHeight.constant = 5 + [Utils heightForString:t2.stringValue font:t2.font containerWidth:t2.bounds.size.width];
}

-(IBAction)playShow:(id)sender
{
//    NSURL *url = [NSURL URLWithString:self.show.path];
//    [[NSWorkspace sharedWorkspace] openFile:url.path withApplication:@"Beamer"];
}

-(IBAction)close:(id)sender
{
    
}
@end