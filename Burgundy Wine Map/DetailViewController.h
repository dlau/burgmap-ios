//
//  MapDetailViewController.h
//  Burgundy Wine Map
//
//  Created by Daryl Lau on 6/9/13.
//  Copyright (c) 2013 Daryl Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSplitView/MGSplitViewController.h"
#import "Mapbox.h"
#import "RootViewController.h"

@class RootViewController;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, MGSplitViewControllerDelegate, RMMapViewDelegate> {
	IBOutlet MGSplitViewController *splitController;
    RootViewController *rootViewController;
    
    id detailItem;
    
}


@property (nonatomic, strong) id detailItem;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;

- (IBAction)toggleMasterView:(id)sender;
- (IBAction)toggleVertical:(id)sender;
- (IBAction)toggleDividerStyle:(id)sender;
- (IBAction)toggleMasterBeforeDetail:(id)sender;


@end
