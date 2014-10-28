//
//  iPhoneDetailViewController.m
//  Burgundy Wine Map
//
//  Created by Daryl Lau on 9/8/13.
//  Copyright (c) 2013 Daryl Lau. All rights reserved.
//

#import "iPhoneDetailViewController.h"
#import "NSData+Base64.h"
#import "Mapbox.h"
#import "RMInteractiveSource.h"
#import "BMMapManager.h"
#import "NSString+FontAwesome.h"


@interface iPhoneDetailViewController ()
    -(CGRect) fixDimensions;
@end

@implementation iPhoneDetailViewController
{
    UISearchDisplayController *m_SearchController;
    BOOL m_bShouldShowMaster;
    NSArray *m_SearchResults;
    RMMapView *m_MapView;
}


@synthesize searchBar,toolBar,bgLayerSegmentedControl,btn_JumpLocation,ctr_LayerControl;

-(CGRect)fixDimensions
{
    float offsetStatusBar = 20.0;
    float rightMargin = 5.0;
    float searchBoxWidth = CGRectGetWidth(self.view.bounds) - rightMargin;
    if(!bgLayerSegmentedControl.hidden){
        searchBoxWidth -= CGRectGetWidth(bgLayerSegmentedControl.bounds);
    }
    if(!btn_JumpLocation.hidden){
        searchBoxWidth -= CGRectGetWidth(btn_JumpLocation.bounds);
    }
    CGRect searchBarBounds = CGRectMake(0.0, offsetStatusBar, searchBoxWidth,CGRectGetHeight(searchBar.bounds));
    [searchBar setFrame: searchBarBounds];
    
    float diff = (CGRectGetHeight(searchBar.bounds) - CGRectGetHeight(bgLayerSegmentedControl.bounds)) / 2;
    CGRect bgLayerSegmentedBounds = CGRectMake(CGRectGetWidth(searchBarBounds), diff + offsetStatusBar, CGRectGetWidth(bgLayerSegmentedControl.bounds), CGRectGetHeight(bgLayerSegmentedControl.bounds));
    [bgLayerSegmentedControl setFrame:bgLayerSegmentedBounds];

    CGRect bgLayerJumpBounds = CGRectMake(CGRectGetWidth(searchBarBounds) + CGRectGetWidth(bgLayerSegmentedBounds), diff + offsetStatusBar, CGRectGetWidth(btn_JumpLocation.bounds), CGRectGetHeight(btn_JumpLocation.bounds));
    [btn_JumpLocation setFrame:bgLayerJumpBounds];
    
    CGRect slice;
    CGRect remainder;
    CGRectDivide(self.view.bounds, &slice, &remainder, CGRectGetMidY(searchBarBounds) + offsetStatusBar, CGRectMinYEdge);
    
    if(m_MapView){
        [m_MapView setFrame:remainder];
    }
    return remainder;

}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.btn_JumpLocation.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
    [self.btn_JumpLocation setTitle:[NSString fontAwesomeIconStringForEnum:FAIconLocationArrow] forState:UIControlStateNormal];
    [self.btn_JumpLocation setTitle:[NSString fontAwesomeIconStringForEnum:FAIconLocationArrow] forState:UIControlStateSelected];
    [self.btn_JumpLocation setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    m_MapView = nil;
    m_SearchController = nil;
    m_bShouldShowMaster = NO;
    m_SearchResults = nil;
    
    CGRect remainder = [self fixDimensions];
    
    m_MapView = [[BMMapManager getInstance]createMapViewWithBaseLayer:eBLS_Streets withFrame:remainder];
    m_MapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    m_MapView.zoom = 11;
    m_MapView.maxZoom = 18;
    m_MapView.delegate = self;
    m_MapView.centerCoordinate = CLLocationCoordinate2DMake(47.100045,4.852867);
    m_MapView.showLogoBug = NO;
    m_MapView.adjustTilesForRetinaDisplay = YES;
    m_MapView.showsUserLocation = YES;
    
    [self.view addSubview:m_MapView];
    
}

#pragma mark -

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self fixDimensions];
    
}

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
    RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:m_MapView coordinate:*coordinate andTitle:title];
    [m_MapView addAnnotation:annotation];
    if(m_MapView.zoom != 15)
    {
        [m_MapView setZoom:15.0 animated:NO];
    }
    [m_MapView selectAnnotation:annotation animated:NO];
    [m_MapView setCenterCoordinate:*coordinate animated:YES];
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
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [[BMMapManager getInstance] getSearchResultsForText:searchText
       callback:^(NSArray* results){
           m_SearchResults = results;
       }
     ];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller
  didLoadSearchResultsTableView:(UITableView *)tableView
{
    
    if(controller != nil)
    {
        m_SearchController = controller;
    }
    [tableView registerClass:[UITableViewCell class]
      forCellReuseIdentifier:@"cell"];
    [controller setActive:TRUE];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [m_SearchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"cell"
                                    forIndexPath:indexPath];
    NSDictionary *searchResult = [m_SearchResults objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [searchResult objectForKey:@"displayName"];
    cell.textLabel.font=[UIFont systemFontOfSize:15.0];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rowDict = [m_SearchResults objectAtIndex:indexPath.row];
    double lat = [(NSNumber*)[rowDict objectForKey:@"lat"] doubleValue];
    double lng = [(NSNumber*)[rowDict objectForKey:@"lng"] doubleValue];
    CLLocationCoordinate2D selectionCoords = CLLocationCoordinate2DMake(lat, lng);
    [m_MapView setCenterCoordinate:selectionCoords  animated:NO];
    
    
    if(m_SearchController)
    {
        [m_SearchController setActive:NO animated:YES];
    }
    [m_MapView removeAllAnnotations];
    [self addMarkerWithTitle:[rowDict objectForKey:@"regionName"] andCoordinate:&selectionCoords];
}
#pragma mark - UISearchDisplayController delegate methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    bgLayerSegmentedControl.hidden = YES;
    btn_JumpLocation.hidden = YES;
}
- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    
}
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    bgLayerSegmentedControl.hidden = NO;
    btn_JumpLocation.hidden = NO;
    [self fixDimensions];
}
- (IBAction)toggleBaseLayerType:(id)sender
{
    [[BMMapManager getInstance]
     setBaseLayer:bgLayerSegmentedControl.selectedSegmentIndex
     forMapView:m_MapView];
}
- (IBAction)jumpLocation:(id) sender
{
    m_MapView.showsUserLocation = m_MapView.showsUserLocation ? NO : YES;
    [self.btn_JumpLocation setTitleColor:m_MapView.showsUserLocation ? [UIColor blueColor] : [UIColor grayColor] forState:UIControlStateNormal];
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
