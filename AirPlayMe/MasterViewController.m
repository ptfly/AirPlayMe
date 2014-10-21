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

@interface MasterViewController ()

@property (weak) IBOutlet NSView *masterView;
@property (weak) IBOutlet NSView *headerView;

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
}

-(IBAction)toggleViewController:(NSButton *)sender
{
    for(int i=1; i<=3; i++)
    {
        if(i != sender.tag){
            [(MainButton*)[self.view viewWithTag:i] setInactive];
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
    
    [self.masterView addSubview:self.currentViewController.view];
    [self.currentViewController.view setFrame:self.masterView.bounds];
    [self.currentViewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.currentViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
}

@end
