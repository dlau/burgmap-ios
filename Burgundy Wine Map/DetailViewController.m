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
#import "RMInteractiveSource.h"
#import "BMMapManager.h"


@implementation DetailViewController
{
    UISearchDisplayController *m_SearchController;
    BOOL m_bShouldShowMaster;
    NSArray *m_SearchResults;
    RMMapView *m_MapView;
}

@synthesize detailItem, rootViewController,searchBar,toolBar,bgLayerSegmentedControl;


- (void)viewDidLoad
{
    [super viewDidLoad];
    m_MapView = nil;
    m_SearchController = nil;
    m_bShouldShowMaster = NO;
    m_SearchResults = nil;
    
    [bgLayerSegmentedControl addTarget:self action:@selector(toggleBaseLayerType:) forControlEvents:UIControlEventValueChanged];
    

    //NSString *tileJSONPath = [[NSBundle mainBundle] pathForResource:@"burgmapcom" ofType:@"tilejson"];
    //NSString *tileJSON = [NSString stringWithContentsOfFile:tileJSONPath encoding:NSASCIIStringEncoding error:NULL];
   // RMMapBoxSource *OnlineSource = [[RMMapBoxSource alloc] initWithTileJSON: tileJSON];
    
    CGRect slice;
    CGRect remainder;
    CGRectDivide(self.view.bounds, &slice, &remainder, CGRectGetHeight(toolBar.bounds), CGRectMinYEdge);
    
    
    [toolBar setBounds: slice];
    
    m_MapView = [[BMMapManager getInstance]createMapViewWithBaseLayer:eBLS_Streets withFrame:remainder];
    m_MapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    m_MapView.zoom = 11;
    m_MapView.delegate = self;
    m_MapView.centerCoordinate = CLLocationCoordinate2DMake(47.05321514774161,4.684796142578125);

    [self.view addSubview:m_MapView];
    
}

#pragma mark -

- (void)singleTapOnMap:(RMMapView *)mapView at:(CGPoint)point
{
    [self configureView];
    
    RMMapBoxSource *source = (RMMapBoxSource *)mapView.tileSource;
    
    if ([source conformsToProtocol:@protocol(RMInteractiveSource)] && [source supportsInteractivity])
    {
        NSDictionary *dictInteraction = [source interactivityForPoint:point inMapView: mapView ];
        if(!dictInteraction ||
           [dictInteraction count] == 0 ||
           ![dictInteraction objectForKey:@"name"] ||
           ![dictInteraction objectForKey:@"commune_name"])
        {
            if([splitController isShowingMaster])
            {
                //Hide master if they click on an area that is unrecognized
                [splitController toggleMasterView:nil];
            }
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

#pragma mark - Search Bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    m_SearchResults = [[BMMapManager getInstance] getSearchResultsForText:searchText];
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
    cell.textLabel.font=[UIFont systemFontOfSize:20.0];
    cell.textLabel.numberOfLines = 0;
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



- (IBAction)toggleBaseLayerType:(id)sender
{
    [[BMMapManager getInstance]
        setBaseLayer:bgLayerSegmentedControl.selectedSegmentIndex
            forMapView:m_MapView];
}

#pragma mark - Boiler plate
#pragma mark -
#pragma mark Managing the detail item


- (void)setDetailItem:(id)newDetailItem
{
    if (detailItem != newDetailItem) {
        detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
	
}


- (void)configureView
{
    
    if(!m_bShouldShowMaster && splitController.isShowingMaster)
    {
        [splitController toggleMasterView:nil];
    }
    CGRect slice;
    CGRect remainder;
    CGRectDivide(self.view.bounds, &slice, &remainder, CGRectGetHeight(toolBar.bounds), CGRectMinYEdge);

    [toolBar setBounds: slice];
}


#pragma mark -
#pragma mark Split view support


- (void)splitViewController:(MGSplitViewController*)svc
	 willHideViewController:(UIViewController *)aViewController
		  withBarButtonItem:(UIBarButtonItem*)barButtonItem
{
	//NSLog(@"%@", NSStringFromSelector(_cmd));
}


// Called when the view is shown again in the split view, invalidating the button
- (void)splitViewController:(MGSplitViewController*)svc
	 willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
	//NSLog(@"%@", NSStringFromSelector(_cmd));
}


- (void)splitViewController:(MGSplitViewController*)svc
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

#pragma mark Rotation support


// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    float toolBarHeightLandscape = 33.0;
    float toolBarHeightPortrait = 44.0;
    
    float toolBarHeight = toolBarHeightPortrait;
    if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
       self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        toolBarHeight = toolBarHeightLandscape;
    }
    
    CGRect toolbarBounds = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds),toolBarHeight);
    [toolBar setFrame: toolbarBounds];
    
    CGRect slice;
    CGRect remainder;
    CGRectDivide(self.view.bounds, &slice, &remainder, CGRectGetHeight(toolBar.bounds), CGRectMinYEdge);
    
    [m_MapView setFrame:remainder];

	[self configureView];
    
}
@end
