//
//  iPhoneDetailViewController.m
//  Burgundy Wine Map
//
//  Created by Daryl Lau on 9/8/13.
//  Copyright (c) 2013 Daryl Lau. All rights reserved.
//

#import "iPadDetailViewController.h"
#import "NSData+Base64.h"
#import "Mapbox.h"
#import "RMInteractiveSource.h"
#import "BMMapManager.h"
#import "BMSearchSuggestionControllerViewController.h"
#import "NSString+FontAwesome.h"


@interface iPadDetailViewController ()
    -(CGRect) fixDimensions;
@property (nonatomic) UIPopoverController *recentSearchesPopoverController;
@property (nonatomic) BMSearchSuggestionControllerViewController *searchSuggestController;

@property (nonatomic) NSArray *m_SearchResults;
@property (nonatomic) UISearchDisplayController *m_SearchController;
@property (nonatomic) BOOL m_bShouldShowMaster;
@property (nonatomic) RMMapView *m_MapView;

@end

@implementation iPadDetailViewController


@synthesize searchBar,toolBar,bgLayerSegmentedControl,m_SearchResults,m_SearchController,m_MapView,btn_JumpLocation;

#pragma mark - Search results controller delegate method

- (void)searchSuggestController:(BMSearchSuggestionControllerViewController *)controller didSelectName:(NSString *)name displayName: (NSString*) displayName  lat:(double) lat lng:(double) lng
{
    
    /*
     The user selected a row in the recent searches list (UITableView).
     Set the text in the search bar to the search string, and conduct the search.
     */

    // Conduct the search. In this case, simply report the search term used.
    [self.recentSearchesPopoverController dismissPopoverAnimated:YES];
    self.recentSearchesPopoverController = nil;
    [self.searchBar resignFirstResponder];
    
    CLLocationCoordinate2D selectionCoords = CLLocationCoordinate2DMake(lat, lng);
    [self.m_MapView setCenterCoordinate:selectionCoords  animated:NO];
    
    [self.m_MapView removeAllAnnotations];
    [self addMarkerWithTitle:name andCoordinate:&selectionCoords];

}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



-(CGRect) fixDimensions{
    float statusBarOffset = 20.0;
    
  //  CGRect toolbarBounds = CGRectMake(0.0, statusBarOffset, CGRectGetWidth(self.view.bounds),CGRectGetHeight(toolBar.bounds));
 //   [toolBar setFrame: toolbarBounds];
    
 //   CGRect searchBarBounds = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds)*.95 - CGRectGetWidth(bgLayerSegmentedControl.bounds),CGRectGetHeight(searchBar.bounds));
//    [searchBar setFrame: searchBarBounds];
    
    CGRect slice;
    CGRect remainder;
    CGRectDivide(self.view.bounds, &slice, &remainder, statusBarOffset + CGRectGetHeight(toolBar.bounds), CGRectMinYEdge);
    
    if(m_MapView){
        [m_MapView setFrame:remainder];
    }
    return remainder;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.btn_JumpLocation.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
    [self.btn_JumpLocation setTitle:[NSString fontAwesomeIconStringForEnum:FAIconLocationArrow] forState:UIControlStateNormal];
    [self.btn_JumpLocation setTitle:[NSString fontAwesomeIconStringForEnum:FAIconLocationArrow] forState:UIControlStateSelected];
    [self.btn_JumpLocation setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    CGRect remainder = [self fixDimensions];
    
    self.m_MapView = [[BMMapManager getInstance]createMapViewWithBaseLayer:eBLS_Streets withFrame:remainder];
    self.m_MapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.m_MapView.zoom = 11;
    self.m_MapView.maxZoom = 18;
    self.m_MapView.delegate = self;
    self.m_MapView.centerCoordinate = CLLocationCoordinate2DMake(47.100045,4.852867);
    self.m_MapView.showLogoBug = NO;
    self.m_MapView.adjustTilesForRetinaDisplay = YES;
    self.m_MapView.showsUserLocation = YES;
    
    [self.view addSubview:m_MapView];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Ensure the complete list of recents is shown on first display.
    [super viewWillAppear:animated];
    [self fixDimensions];
    
}

#pragma mark -

- (void)singleTapOnMap:(RMMapView *)mapView at:(CGPoint)point
{
    RMMapboxSource *source = (RMMapboxSource *)mapView.tileSource;
    
    if ([source conformsToProtocol:@protocol(RMInteractiveSource)] && [source supportsInteractivity])
    {
        NSDictionary *dictInteraction = [source interactivityForPoint:point inMapView: mapView ];
        if(!dictInteraction ||
           [dictInteraction count] == 0 ||
           ![dictInteraction objectForKey:@"name"] ||
           ![dictInteraction objectForKey:@"commune_name"])
        {
            return;
        }
        NSString *markerTitle =
        [[NSString alloc] initWithFormat:@"%@ - %@",
         [dictInteraction objectForKey:@"commune_name"],
         [dictInteraction objectForKey:@"name"]
         ];
        CLLocationCoordinate2D coordinate = [mapView pixelToCoordinate:point];
        [mapView removeAllAnnotations];
        [self addMarkerWithTitle:markerTitle andCoordinate:&coordinate];
    }
}



#pragma mark - Mapbox Marker
-(void)addMarkerWithTitle:(NSString*) title andCoordinate:(CLLocationCoordinate2D*) coordinate
{
    RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.m_MapView coordinate:*coordinate andTitle:title];
    [self.m_MapView addAnnotation:annotation];
    if(self.m_MapView.zoom != 15)
    {
        [self.m_MapView setZoom:15.0 animated:NO];
    }
    [self.m_MapView selectAnnotation:annotation animated:NO];
    [self.m_MapView setCenterCoordinate:*coordinate animated:YES];
}

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation)
        return nil;
    
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"blank-40x40.png"]];
    
    marker.canShowCallout = YES;
    
    marker.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map-marker.png"]];
    
    // marker.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    
    return marker;
}


- (void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    NSLog(@"You tapped the callout button!");
}

#pragma mark - Search h

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar {
    
    // Create the popover if it is not already open.
    if (self.recentSearchesPopoverController == nil) {
        
        /*
         Use the storyboard to instantiate a navigation controller that contains a recent searches controller.
         */
        UINavigationController *navigationController = [[self storyboard] instantiateViewControllerWithIdentifier:@"PopoverNavigationController"];
        
        self.searchSuggestController = (BMSearchSuggestionControllerViewController *)[navigationController topViewController];
        self.searchSuggestController.delegate = self;
        
        /*
         Create the popover controller to contain the navigation controller.
         */
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        popover.delegate = self;
        
        /*
         Ensure the popover is not dismissed if the user taps in the search bar by adding the search bar to the popover's list of pass-through views.
         */
        popover.passthroughViews = @[self.searchBar];
        
        self.recentSearchesPopoverController = popover;
    }
    
    // Display the popover.
    [self.recentSearchesPopoverController presentPopoverFromRect:[self.searchBar bounds] inView:self.searchBar permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}




- (BOOL) searchDisplayController:(UISearchDisplayController*)controller
shouldReloadTableForSearchString:(NSString*)searchString
{
    // perform search and update self.contents (on main thread)
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(!self.recentSearchesPopoverController.popoverVisible){
        [self.recentSearchesPopoverController presentPopoverFromRect:[self.searchBar bounds] inView:self.searchBar permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];        
    }
    [self.searchSuggestController filterResultsUsingString:searchText];
}

#pragma mark - UISearchDisplayController delegate methods

- (IBAction)toggleBaseLayerType:(id)sender
{
    [[BMMapManager getInstance]
     setBaseLayer:self.bgLayerSegmentedControl.selectedSegmentIndex
     forMapView:self.m_MapView];
}

- (IBAction)jumpLocation:(id) sender
{
    self.m_MapView.showsUserLocation = self.m_MapView.showsUserLocation ? NO : YES;
    [self.btn_JumpLocation setTitleColor:self.m_MapView.showsUserLocation ? [UIColor blueColor] : [UIColor grayColor] forState:UIControlStateNormal];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self fixDimensions];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
