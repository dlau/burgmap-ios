//
//  DataViewController.m
//  Burgundy Wine Map
//
//  Created by Daryl Lau on 6/6/13.
//  Copyright (c) 2013 Daryl Lau. All rights reserved.
//

#import "RootViewController.h"
@implementation RootViewController

@synthesize lblCommuneName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
}

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void) setFromDictionary:(NSDictionary *) dictFromPoint
{
    NSString *communeName = [dictFromPoint valueForKey:@"commune_name"];
    NSString *appellationName = [dictFromPoint valueForKey:@"name"];
    NSString *region = [dictFromPoint valueForKey:@"region"];
    [self.lblCommuneName setText:communeName];
}

@end
