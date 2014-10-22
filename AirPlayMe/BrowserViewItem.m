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

@interface BrowserViewItem ()
@property (strong, nonatomic) NSManagedObjectContext *context;
@end

@implementation BrowserViewItem
@synthesize nameField, imageView;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
    self.context = appDelegate.managedObjectContext;
}

-(IBAction)singleClick:(id)sender
{
    if([[[self.representedObject valueForKey:@"entity"] valueForKey:@"name"] isEqualToString:@"TVShow"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOpenTVShowDetails object:self.representedObject];
    }
    else if([[[self.representedObject valueForKey:@"entity"] valueForKey:@"name"] isEqualToString:@"Movie"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOpenMovieDetails object:self.representedObject];
    }
}

-(void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
    
    if(!representedObject) return;
    
    if([[[representedObject valueForKey:@"entity"] valueForKey:@"name"] isEqualToString:@"TVShow"])
    {
        TVShow *show = (TVShow *)representedObject;
        
        self.imageView.image = [[NSImage alloc] initWithData:show.poster];
        self.nameField.stringValue = show.original_name;
        self.yearField.stringValue = [[YLMoment momentWithDate:show.first_air_date] format:@"YYYY"];
    }
    else if([[[representedObject valueForKey:@"entity"] valueForKey:@"name"] isEqualToString:@"Movie"])
    {
        Movie *movie = (Movie *)representedObject;
        self.nameField.stringValue = movie.title;
        self.yearField.stringValue = movie.year;
        
        if([movie.tmdbID intValue] > 0){
            self.imageView.image = [[NSImage alloc] initWithData:movie.poster];
            self.nameField.stringValue = movie.original_title;
            self.yearField.stringValue = [[YLMoment momentWithDate:movie.release_date] format:@"YYYY"];
        }
    }
}

-(void)mouseEntered:(NSEvent *)theEvent
{
    NSLog(@"MOUSE IN");
}

-(void)mouseExited:(NSEvent *)theEvent
{
    NSLog(@"MOUSE OUT");
}



@end
