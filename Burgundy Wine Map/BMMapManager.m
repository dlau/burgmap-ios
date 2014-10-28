//
//  BMMapManager.m
//  Burgundy Wine Map
//
//  Created by Daryl Lau on 6/20/13.
//  Copyright (c) 2013 Daryl Lau. All rights reserved.
//

#import "BMMapManager.h"
#import "Mapbox.h"
#import "RMCompositeSource.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import <AFNetworking/AFNetworking.h>
#import "NSString+URLEncoding.h"

//Note: If we migrate from the MapBox SDK, the dependency only needs to be added to the xcode project
@interface BMMapManager()
-(void)cbWithRequest:(NSURLRequest*)request withResponse:(NSHTTPURLResponse*)response withJSON:(id)JSON;
@end

@implementation BMMapManager
{
#ifdef OFFLINE_TILES
    RMMBTilesSource *m_SourceOfflineStreetsBase;
    RMMBTilesSource *m_SourceCtBDorLayer;
    RMMBTilesSource *m_SourceChablisLayer;
#endif
    
    RMMapboxSource *m_SourceOnlineStreetsBase;
    RMMapboxSource *m_SourceOnlineSatelliteBase;
    
    FMDatabase *m_SearchDb;
    
    BOOL m_IsOffline;
    //This contains the last search result
    NSMutableArray *m_SearchResults;
}

+(BMMapManager*) getInstance
{
    static BMMapManager *instance = nil;
    if(!instance)
    {
        instance = [[self alloc] init];
    }
    return instance;
}

- (RMMapboxSource*) getOnlineMapBoxLayer:(BaseLayerSelection)layerType
{
    
    if(layerType == eBLS_Streets)
    {
        return m_SourceOnlineStreetsBase;
    }
    else if(layerType == eBLS_Satellite)
    {
        return m_SourceOnlineSatelliteBase;
    }
    return m_SourceOnlineStreetsBase;
}

- (void)setBaseLayer:(BaseLayerSelection)layerType forMapView:(RMMapView*)mapView;
{
    //Currently only available base layer selections are online
    m_IsOffline = NO;
    [mapView setTileSource:
    [self getOnlineMapBoxLayer:layerType]];
}


- (RMMapView*)createMapViewWithBaseLayer:(BaseLayerSelection)layerType withFrame:(CGRect)frame
{
    //Currently only available base layer selections are online
    m_IsOffline = NO;
    return [[RMMapView alloc]
            initWithFrame:frame andTilesource:[self getOnlineMapBoxLayer:layerType]];
}


-(void)cbWithRequest:(NSURLRequest*)request withResponse:(NSHTTPURLResponse*)response withJSON:(id)JSON
{
    //blank, can debug w/ this
}

-(NSArray*) getSearchResultsForText:(NSString*)searchText callback:(void ( ^ ) ( NSArray* searchResults))callback
{
    if(searchText.length < 3){
        //do nothing
        callback([m_SearchResults copy]);
    }
    else if(!m_IsOffline){
        NSString* url_encoded =[NSString stringWithFormat:@"https://burgmap.com/search/complete/region?term=%@", [searchText urlEncode]];
        NSURL *url = [NSURL URLWithString:url_encoded];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//            [self cbWithRequest:request withResponse:response withJSON:JSON];
            [m_SearchResults removeAllObjects];
            for( id result in JSON){
                NSString* name = [result objectForKey:@"name"];
                NSString* parent_name = [result objectForKey:@"parent_name"];
                NSNumber* lat = [result objectForKey:@"x"];
                NSNumber* lng = [result objectForKey:@"y"];
                NSMutableString* displayName = [[NSMutableString alloc] initWithString:@""];
                if(parent_name && parent_name.length){
                    [displayName appendFormat:@"%@\n",parent_name];
                }
                if(name && name.length){
                    [displayName appendFormat:@"%@",name];
                }
                if(name && lat && lng){
                    NSDictionary *dictRes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                             displayName, @"displayName",
                                             name, @"regionName",
                                             lat , @"lat",
                                             lng, @"lng",
                                             nil];
                    [m_SearchResults addObject:dictRes];
                }
                callback([m_SearchResults copy]);
            }
        } failure:^( NSURLRequest *request , NSURLResponse *response , NSError *error , id JSON ){
            NSLog(@"Failed :%@ %@", response, error);
        }];
        
        [operation start];
        
        return Nil;
    }
    else{
#ifdef OFFLINE_TILES
        //Just to be extra careful
        @synchronized(self)
        {
            if([m_SearchDb open])
            {
                [m_SearchResults removeAllObjects];
                NSString *wildCardTerm =
                [[NSString alloc] initWithFormat:@"%@%%", searchText];
                FMResultSet *qRes = [m_SearchDb executeQuery:@"SELECT * FROM regions WHERE (display_name LIKE ? OR display_name_unac LIKE ?)  AND lat > 0.0 AND lng > 0.0 ORDER BY display_name ASC LIMIT 20" ,wildCardTerm, wildCardTerm ];
                BOOL hasResults = NO;
                if ((hasResults = [qRes next]) == NO)
                {
                    wildCardTerm =
                    [[NSString alloc] initWithFormat:@"%%%@%%", searchText];
                    qRes = [m_SearchDb executeQuery:@"SELECT * FROM regions WHERE (display_name LIKE ? OR display_name_unac LIKE ?)  AND lat > 0.0 AND lng > 0.0 ORDER BY display_name ASC LIMIT 20" ,wildCardTerm, wildCardTerm ];
                    hasResults = [qRes next];
                }
                while(hasResults)
                {
                    NSString *displayName = [qRes stringForColumn:@"display_name"];
                    NSString *displayNameUnac = [qRes stringForColumn:@"display_name_unac"];
                    NSString *regionName = [qRes stringForColumn:@"name"];
                    NSNumber *lat = [NSNumber numberWithDouble:[qRes doubleForColumn:@"lat"]];
                    NSNumber *lng = [NSNumber numberWithDouble:[qRes doubleForColumn:@"lng"]];
                    NSDictionary *dictRes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                             displayName, @"displayName",
                                             displayNameUnac, @"displayNameUnac",
                                             regionName, @"regionName",
                                             lat , @"lat",
                                             lng, @"lng",
                                             nil];
                    [m_SearchResults addObject:dictRes];
                    hasResults = [qRes next];
                }
                if ([m_SearchResults count] == 0)
                {
                    
                }
                [m_SearchDb close];
            }
        }
#endif
    }
    return [m_SearchResults copy];
}

-(void) initTileObjects
{
#ifdef OFFLINE_TILES
    m_SourceOfflineStreetsBase = [[RMMBTilesSource alloc] initWithTileSetResource: MBTILES_BASELAYER_RESOURCE_NAME ofType:@"mbtiles"];
    m_SourceCtBDorLayer = [[RMMBTilesSource alloc] initWithTileSetResource: MBTILES_COTEBEAUNE_COTEDOR_RESOURCE_NAME ofType:@"mbtiles"];
    m_SourceChablisLayer = [[RMMBTilesSource alloc] initWithTileSetResource:MBTILES_CHABLIS_RESOURCE_NAME ofType:@"mbtiles"];
#endif
    m_SourceOnlineStreetsBase = [[RMMapboxSource alloc] initWithMapID: MAPBOX_COM_PLAIN_STREET_LAYER_ID];
    m_SourceOnlineSatelliteBase = [[RMMapboxSource alloc] initWithMapID: MAPBOX_COM_PLAIN_SATELLITE_LAYER_ID];
    
}

-(void) initSearchDb
{
#ifdef OFFLINE_TILES
    NSString *searchDbPath = [[NSBundle mainBundle] pathForResource:@"burgmap-ios-search" ofType:@"sqlite"];
    m_SearchDb = [FMDatabase databaseWithPath: searchDbPath];
#endif
    m_SearchResults = [[NSMutableArray alloc] initWithCapacity:0];
}

-(id) init
{
    self = [super init];
    if(self)
    {
        [self initTileObjects];
        [self initSearchDb];
    }
    return self;
}


@end
