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


@interface DetailViewController : UIViewController <MGSplitViewControllerDelegate, RMMapViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
	IBOutlet MGSplitViewController *splitController;
    RootViewController *rootViewController;

    id detailItem;
    
}
@property (nonatomic, strong) id detailItem;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;

@property IBOutlet UISearchBar *searchBar;
@property IBOutlet UIToolbar *toolBar;
@property IBOutlet UISegmentedControl *bgLayerSegmentedControl;

- (IBAction)toggleBaseLayerType:(id)sender;


@end
