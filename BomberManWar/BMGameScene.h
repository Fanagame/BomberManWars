//
//  BMMyScene.h
//  BomberManWar
//

//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BMEnums.h"
#import "PathFinder.h"
#import "BMCamera.h"

#define kMinTimeInterval (1 / 60)

/* Completion handler for callback after loading assets asynchronously. */
typedef void (^BMAssetLoadCompletionHandler)(void);

@class BMTiledMap, BMHudNode, BMSpawn;

@interface BMGameScene : SKScene<SKPhysicsContactDelegate, ExplorableWorldDelegate, BMCameraDelegate>

@property (nonatomic, weak)   UIViewController *parentViewController;
@property (nonatomic, strong) NSString *mapName;
@property (nonatomic, strong) SKNode *world;
@property (nonatomic, strong) NSMutableArray *layers;
@property (nonatomic, strong) BMTiledMap *backgroundMap;
@property (nonatomic, strong) BMHudNode *hud;

@property (nonatomic, assign) CFTimeInterval lastUpdateTimeInterval;
@property (nonatomic, strong) BMSpawn *defaultSpawnPoint;
@property (nonatomic, strong) NSMutableArray *spawnPoints;
@property (nonatomic, strong) NSMutableArray *players;

// Loading/Unloading
+ (void)loadSceneAssetsForMapName:(NSString *)mapName withCompletionHandler:(BMAssetLoadCompletionHandler)callback;
+ (void)loadSceneAssetsForMapName:(NSString *)mapName;
+ (void)releaseSceneAssetsForMapName:(NSString *)mapName;

- (id) initWithSize:(CGSize)size andMapName:(NSString *)mapName;
- (void)updateWithTimeSinceLastUpdate:(NSTimeInterval)timeSinceLast;

/* All sprites in the scene should be added through this method to ensure they are placed in the correct world layer. */
- (void)addNode:(SKNode *)node atWorldLayer:(BMWorldLayer)layer;

// Methods to handle tiled map interaction
- (CGPoint) tileCoordinatesForPositionInMap:(CGPoint)position;
- (CGPoint) tilePositionInMapForCoordinate:(CGPoint)position;
- (void) convertCoordinatesArrayToPositionsInMapArray:(NSArray *)coords;


//
// Other methods for the game itself
//
- (NSUInteger) playersWithCharacterOnMapCount;
- (NSArray *) playersWithoutCharactersOnMap;

@end
