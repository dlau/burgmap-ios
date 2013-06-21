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
//Note: If we migrate from the MapBox SDK, the dependency only needs to be added to the xcode project

@implementation BMMapManager
{
    RMMBTilesSource *m_SourceOfflineStreetsBase;
    RMMBTilesSource *m_SourceCtBDorLayer;
    RMMBTilesSource *m_SourceChablisLayer;

    RMMapBoxSource *m_SourceOnlineTerrainBase;
    RMMapBoxSource *m_SourceOnlineSatelliteBase;
    
    NSArray *m_SourcesStreet;
    NSArray *m_SourcesTerrain;
    NSArray *m_SourcesSatellite;
    
    FMDatabase *m_SearchDb;
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

- (RMCompositeSource*)getCompositeLayer:(BaseLayerSelection)layerType
{
    
    NSArray *arrLayers = nil;
    if(layerType == eBLS_Streets)
    {
        arrLayers = m_SourcesStreet;
    }
    else if(layerType == eBLS_Terrain)
    {
        arrLayers = m_SourcesTerrain;
    }
    else if(layerType == eBLS_Satellite)
    {
        arrLayers = m_SourcesSatellite;
    }
    else
    {
        //err out
    }
    
    return [[RMCompositeSource alloc] initWithTileSources:arrLayers tileCacheKey:nil];
    
}

- (void)setBaseLayer:(BaseLayerSelection)layerType forMapView:(RMMapView*)mapView;
{
    [mapView setTileSource:
     [self getCompositeLayer:layerType]];
}


- (RMMapView*)createMapViewWithBaseLayer:(BaseLayerSelection)layerType withFrame:(CGRect)frame
{
    return [[RMMapView alloc]
            initWithFrame:frame andTilesource:[self getCompositeLayer:layerType]];
}

-(NSArray*) getSearchResultsForText:(NSString*)searchText
{
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
    return [m_SearchResults copy];
}

-(void) initTileObjects
{
    m_SourceOfflineStreetsBase = [[RMMBTilesSource alloc] initWithTileSetResource: MBTILES_BASELAYER_RESOURCE_NAME ofType:@"mbtiles"];
    m_SourceCtBDorLayer = [[RMMBTilesSource alloc] initWithTileSetResource: MBTILES_COTEBEAUNE_COTEDOR_RESOURCE_NAME ofType:@"mbtiles"];
    m_SourceChablisLayer = [[RMMBTilesSource alloc] initWithTileSetResource:MBTILES_CHABLIS_RESOURCE_NAME ofType:@"mbtiles"];
    
    m_SourceOnlineTerrainBase = [[RMMapBoxSource alloc] initWithMapID: MAPBOX_COM_PLAIN_TERRAIN_LAYER_ID];
    m_SourceOnlineSatelliteBase = [[RMMapBoxSource alloc] initWithMapID: MAPBOX_COM_PLAIN_SATELLITE_LAYER_ID];
    
    m_SourcesStreet = [[NSArray alloc] initWithObjects:
                       m_SourceOfflineStreetsBase,
                       m_SourceCtBDorLayer,
                       m_SourceChablisLayer, nil];
    m_SourcesTerrain = [[NSArray alloc] initWithObjects:
                       m_SourceOnlineTerrainBase,
                       m_SourceCtBDorLayer,
                       m_SourceChablisLayer, nil];
    m_SourcesSatellite = [[NSArray alloc] initWithObjects:
                       m_SourceOnlineSatelliteBase,
                       m_SourceCtBDorLayer,
                       m_SourceChablisLayer, nil];
}

-(void) initSearchDb
{
    NSString *searchDbPath = [[NSBundle mainBundle] pathForResource:@"burgmap-ios-search" ofType:@"sqlite"];
    m_SearchDb = [FMDatabase databaseWithPath: searchDbPath];
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
