//
//  TDTiledMap.m
//  CoopTD
//
//  Created by Remy Bardou on 10/20/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "BMTiledMap.h"
#import "BMSpawn.h"

NSString * const kTiledMapObjectType_Spawn = @"SpawnPoint";

NSString * const kTiledMapLayerName_Main = @"Map";
NSString * const kTiledMapLayerName_Objects = @"MetaObjects";
NSString * const kTiledMapLayerName_Meta = @"MetaLayer";

NSString * const kTiledMapTilePropertyName_Walkable = @"Walkable";

@implementation BMTiledMap

- (id) initWithMapNamed:(NSString *)mapName {
    self = [super init];
    
    if (self) {
        self.fileName = mapName;
        if (![self.fileName hasSuffix:@".tmx"])
            self.fileName = [self.fileName stringByAppendingPathExtension:@"tmx"];
        
        self.mapName = mapName;
        self.tiledMap = [JSTileMap mapNamed:self.fileName];
        self.goalPoints = [[NSMutableArray alloc] init];
        self.spawnPoints = [[NSMutableArray alloc] init];
        
        if (self.tiledMap) {
            self.mainLayer = [self.tiledMap layerNamed:kTiledMapLayerName_Main];
            self.metaLayer = [self.tiledMap layerNamed:kTiledMapLayerName_Meta];
            
            // Figure out meta informations (spawn points, destination point coordinates, etc...)
            self.objectsGroup = [self.tiledMap groupNamed:kTiledMapLayerName_Objects];
            if (self.objectsGroup) {
                for (NSDictionary *object in self.objectsGroup.objects) {
                    if ([object[@"type"] isEqualToString:kTiledMapObjectType_Spawn]) {
                        [self.spawnPoints addObject:[[BMSpawn alloc] initWithDictionary:object]];
                        [self.tiledMap addChild:self.spawnPoints.lastObject];
                    }
                }
            }

            [self addChild:self.tiledMap];
            
#if DEBUG
      
            NSLog(@"======== DEBUG =========");
            NSLog(@"Map loaded: %@", self.fileName);
            NSLog(@"Map size (pixels): %f x %f", self.calculateAccumulatedFrame.size.width, self.calculateAccumulatedFrame.size.height);
            NSLog(@"Tile size: %f x %f", self.tiledMap.tileSize.width, self.tiledMap.tileSize.height);
            NSLog(@"Spawn points: %d", self.spawnPoints.count);
            NSLog(@"Goal points: %d", self.goalPoints.count);
            NSLog(@"========================");
#endif
        }
    }
    
    return self;
}

#pragma mark - Position conversion

- (CGPoint) tileCoordinatesForPosition:(CGPoint)position {
    if (self.mainLayer) {
        return [self.mainLayer coordForPoint:position];
    }
    
    return CGPointZero;
}

- (CGPoint) tilePositionForCoordinate:(CGPoint)position {
    if (self.mainLayer) {
        return [self.mainLayer pointForCoord:position];
    }
    
    return CGPointZero;
}

- (void) convertCoordinatesArrayToPositionsArray:(NSArray *)coords {
    for (PathNode *n in coords) {
        n.position = [self tilePositionForCoordinate:n.position];
    }
}

@end
