//
//  iPhoneDetailViewController.h
//  Burgundy Wine Map
//
//  Created by Daryl Lau on 9/8/13.
//  Copyright (c) 2013 Daryl Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mapbox.h"

@interface iPhoneDetailViewController : UIViewController<RMMapViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>{
}

@property IBOutlet UISearchBar *searchBar;
@property IBOutlet UIToolbar *toolBar;
@property IBOutlet UISegmentedControl *bgLayerSegmentedControl;
@property IBOutlet UIBarButtonItem *ctr_LayerControl;

- (IBAction)toggleBaseLayerType:(id)sender;


@end
