//
//  BMMapManager.h
//  Burgundy Wine Map
//
//  Created by Daryl Lau on 6/20/13.
//  Copyright (c) 2013 Daryl Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mapbox.h"

static NSString * const MAPBOX_COM_PLAIN_TERRAIN_LAYER_ID = @"phatdood9.map-eclrvtg7";
static NSString * const MAPBOX_COM_PLAIN_SATELLITE_LAYER_ID = @"phatdood9.map-uv41arrl";

static NSString * const MBTILES_BASELAYER_RESOURCE_NAME = @"FraLargeBg";
static NSString * const MBTILES_COTEBEAUNE_COTEDOR_RESOURCE_NAME = @"BurgCtBDorCurrent";
static NSString * const MBTILES_CHABLIS_RESOURCE_NAME = @"BurgChablisCurrent";

typedef int BaseLayerSelection;
enum eBaseLayerSelection
{
    eBLS_Streets = 0,
    eBLS_Terrain = 1,
    eBLS_Satellite = 2
};


@interface BMMapManager : NSObject

- (void)setBaseLayer:(BaseLayerSelection)layerType forMapView:mapView;
- (RMMapView*)createMapViewWithBaseLayer:(BaseLayerSelection)layerType withFrame:(CGRect)frame;

-(NSArray*) getSearchResultsForText:(NSString*)searchText;


+(BMMapManager*) getInstance;

@end
