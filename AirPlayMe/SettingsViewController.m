//
//  SettingsViewController.m
//  AirPlayMe
//
//  Created by Plamen Todorov on 17.10.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "SettingsViewController.h"
#import "Config.h"

@interface SettingsViewController ()

@property (weak) IBOutlet NSTextField *moviesPathLabel;
@property (weak) IBOutlet NSTextField *tvShowsPathLabel;

@end

@implementation SettingsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self configure];
}

-(void)configure
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *movies  = [defaults objectForKey:kMoviesLibraryPathKey];
    NSString *tvshows = [defaults objectForKey:kTVShowsLibraryPathKey];
    
    self.moviesPathLabel.stringValue  = [Utils isNilOrEmpty:movies] ? @"Please set..." : [[NSURL URLWithString:movies] path];
    self.tvShowsPathLabel.stringValue = [Utils isNilOrEmpty:tvshows] ? @"Please set..." : [[NSURL URLWithString:tvshows] path];
}

-(IBAction)selectMoviesPath:(NSButton *)sender
{
    NSOpenPanel *browse = [NSOpenPanel openPanel];
    
    [browse setCanChooseFiles:NO];
    [browse setCanChooseDirectories:YES];
    [browse setPrompt:@"Select"];
    
    if([browse runModal] == NSModalResponseOK)
    {
        NSString *selected = [[[browse URLs] firstObject] absoluteString];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:selected forKey:kMoviesLibraryPathKey];
        [defaults synchronize];
        
        [self configure];
    }
}

-(IBAction)selectTvShowsPath:(NSButton *)sender
{
    NSOpenPanel *browse = [NSOpenPanel openPanel];
    
    [browse setCanChooseFiles:NO];
    [browse setCanChooseDirectories:YES];
    [browse setPrompt:@"Select"];
    
    if([browse runModal] == NSModalResponseOK)
    {
        NSString *selected = [[[browse URLs] firstObject] absoluteString];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:selected forKey:kTVShowsLibraryPathKey];
        [defaults synchronize];
        
        [self configure];
    }
}

@end
