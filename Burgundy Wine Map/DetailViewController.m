//
//  MapDetailViewController.m
//  Burgundy Wine Map
//
//  Created by Daryl Lau on 6/9/13.
//  Copyright (c) 2013 Daryl Lau. All rights reserved.
//

#import "DetailViewController.h"
#import "NSData+Base64.h"
#import "Mapbox.h"



@implementation DetailViewController


@synthesize detailItem, popoverController,rootViewController;


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *tileJSONPath = [[NSBundle mainBundle] pathForResource:@"burgmapcom" ofType:@"tilejson"];
    //NSString *tileJSONPath = [[NSBundle mainBundle] pathForResource:@"testmap" ofType:@"tilejson"];
    NSString *tileJSON = [NSString stringWithContentsOfFile:tileJSONPath encoding:NSASCIIStringEncoding error:NULL];
    
    RMMapBoxSource *OnlineSource = [[RMMapBoxSource alloc] initWithTileJSON: tileJSON];
        

    
    RMMapView *MapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:OnlineSource];
    MapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    MapView.zoom = 8;
    MapView.delegate = self;
    [self.view addSubview:MapView];
}

#pragma mark -

- (void)singleTapOnMap:(RMMapView *)mapView at:(CGPoint)point
{
    [mapView removeAllAnnotations];
    
    RMMBTilesSource *source = (RMMBTilesSource *)mapView.tileSource;
    
    if ([source conformsToProtocol:@protocol(RMInteractiveSource)] && [source supportsInteractivity])
    {
        NSDictionary *dictInteraction = [source interactivityForPoint:point inMapView: mapView ];
        if(splitController.isMasterBeforeDetail)
        {
            [splitController toggleMasterBeforeDetail:nil];
        }
        if(![splitController isShowingMaster])
        {
            [splitController toggleMasterView:nil];
        }
        [rootViewController setFromDictionary:dictInteraction];
//        NSString *formattedOutput = [source formattedOutputOfType:RMInteractiveSourceOutputTypeTeaser
                          //                               forPoint:point
                          //                              inMapView:mapView];
        
   /*     if (formattedOutput && [formattedOutput length])
        {
            // parse the country name out of the content
            //
            NSUInteger startOfCountryName = [formattedOutput rangeOfString:@"<strong>"].location + [@"<strong>" length];
            NSUInteger endOfCountryName   = [formattedOutput rangeOfString:@"</strong>"].location;
            
            NSString *countryName = [formattedOutput substringWithRange:NSMakeRange(startOfCountryName, endOfCountryName - startOfCountryName)];
            
            // parse the flag image out of the content
            //
            NSUInteger startOfFlagImage = [formattedOutput rangeOfString:@"base64,"].location + [@"base64," length];
            NSUInteger endOfFlagImage   = [formattedOutput rangeOfString:@"\" style"].location;
            
            UIImage *flagImage = [UIImage imageWithData:[NSData dataFromBase64String:[formattedOutput substringWithRange:NSMakeRange(startOfFlagImage, endOfFlagImage)]]];
            
            RMAnnotation *annotation = [RMAnnotation annotationWithMapView:mapView coordinate:[mapView pixelToCoordinate:point] andTitle:countryName];
            
            annotation.userInfo = flagImage;
            
            [mapView addAnnotation:annotation];
            
            [mapView selectAnnotation:annotation animated:YES];
        }*/
    }
}

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    RMMarker *marker = [[RMMarker alloc] initWithMapBoxMarkerImage:@"embassy"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 32)];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    imageView.image = annotation.userInfo;
    
    marker.leftCalloutAccessoryView = imageView;
    
    marker.canShowCallout = YES;
    
    return marker;
}


#pragma mark -
#pragma mark Managing the detail item


// When setting the detail item, update the view and dismiss the popover controller if it's showing.
- (void)setDetailItem:(id)newDetailItem
{
    if (detailItem != newDetailItem) {
        detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
	
    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }
}


- (void)configureView
{
}


#pragma mark -
#pragma mark Split view support


- (void)splitViewController:(MGSplitViewController*)svc
	 willHideViewController:(UIViewController *)aViewController
		  withBarButtonItem:(UIBarButtonItem*)barButtonItem
	   forPopoverController: (UIPopoverController*)pc
{
	//NSLog(@"%@", NSStringFromSelector(_cmd));
	
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(MGSplitViewController*)svc
	 willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
	//NSLog(@"%@", NSStringFromSelector(_cmd));
	
    self.popoverController = nil;
}


- (void)splitViewController:(MGSplitViewController*)svc
		  popoverController:(UIPopoverController*)pc
  willPresentViewController:(UIViewController *)aViewController
{
	//NSLog(@"%@", NSStringFromSelector(_cmd));
}


- (void)splitViewController:(MGSplitViewController*)svc willChangeSplitOrientationToVertical:(BOOL)isVertical
{
	//NSLog(@"%@", NSStringFromSelector(_cmd));
}


- (void)splitViewController:(MGSplitViewController*)svc willMoveSplitToPosition:(float)position
{
	//NSLog(@"%@", NSStringFromSelector(_cmd));
}


- (float)splitViewController:(MGSplitViewController *)svc constrainSplitPosition:(float)proposedPosition splitViewSize:(CGSize)viewSize
{
	//NSLog(@"%@", NSStringFromSelector(_cmd));
	return proposedPosition;
}


#pragma mark -
#pragma mark Actions


- (IBAction)toggleMasterView:(id)sender
{
	[splitController toggleMasterView:sender];
	[self configureView];
}


- (IBAction)toggleVertical:(id)sender
{
	[splitController toggleSplitOrientation:self];
	[self configureView];
}


- (IBAction)toggleDividerStyle:(id)sender
{
	MGSplitViewDividerStyle newStyle = ((splitController.dividerStyle == MGSplitViewDividerStyleThin) ? MGSplitViewDividerStylePaneSplitter : MGSplitViewDividerStyleThin);
	[splitController setDividerStyle:newStyle animated:YES];
	[self configureView];
}


- (IBAction)toggleMasterBeforeDetail:(id)sender
{
	[splitController toggleMasterBeforeDetail:sender];
	[self configureView];
}


#pragma mark -
#pragma mark Rotation support


// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self configureView];
}

@end
