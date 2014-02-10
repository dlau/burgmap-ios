//
//  iPadDetailViewController.h
//  Burgundy Wine Map
//
//  Created by Daryl Lau on 9/9/13.
//  Copyright (c) 2013 Daryl Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mapbox.h"
#import "BMSearchSuggestionControllerViewController.h"

@interface iPadDetailViewController : UIViewController <RMMapViewDelegate, UISearchBarDelegate,UIPopoverControllerDelegate, SearchSuggestDelegate> {
}

@property IBOutlet UISearchBar *searchBar;
@property IBOutlet UIToolbar *toolBar;
@property IBOutlet UISegmentedControl *bgLayerSegmentedControl;
@property IBOutlet UIButton *btn_JumpLocation;

- (IBAction)toggleBaseLayerType:(id)sender;
- (IBAction)jumpLocation:(id) sender;

@end
