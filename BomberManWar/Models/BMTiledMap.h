//
//  TDTiledMap.h
//  CoopTD
//
//  Created by Remy Bardou on 10/20/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "JSTileMap.h"

@interface BMTiledMap : SKNode

@property (nonatomic, strong) NSString *mapName;
@property (nonatomic, strong) NSString *fileName;

@property (nonatomic, strong) JSTileMap *tiledMap;

@property (nonatomic, strong) TMXLayer *mainLayer;
@property (nonatomic, strong) TMXObjectGroup *objectsGroup;
@property (nonatomic, strong) TMXLayer *metaLayer;

@property (nonatomic, strong) NSMutableArray *spawnPoints;
@property (nonatomic, strong) NSMutableArray *goalPoints;

- (id) initWithMapNamed:(NSString *)mapName;
- (CGPoint) tileCoordinatesForPosition:(CGPoint)position;
- (CGPoint) tilePositionForCoordinate:(CGPoint)position;
- (void) convertCoordinatesArrayToPositionsArray:(NSArray *)coords;

@end
