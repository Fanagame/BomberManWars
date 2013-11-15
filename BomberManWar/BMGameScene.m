//
//  BMMyScene.m
//  BomberManWar
//
//  Created by Rémy Bardou on 14/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMGameScene.h"
#import "BMMapObject.h"
#import "BMMapCache.h"
#import "BMTiledMap.h"
#import "BMHudNode.h"

@interface BMGameScene () {
    CGSize _cachedMapSizeForCamera;
    CGSize _cachedActualMapSize;
}

@end

@implementation BMGameScene

- (id) initWithSize:(CGSize)size andMapName:(NSString *)mapName {
    self = [super initWithSize:size];
    
    if (self) {
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.mapName = mapName;
		
        // initialize the main layers
        _world = [[SKNode alloc] init];
        _world.name = @"world";
        _layers = [NSMutableArray arrayWithCapacity:kWorldLayerCount];
        for (int i = 0; i < kWorldLayerCount; i++) {
			SKNode *layer = [[SKNode alloc] init];
            layer.zPosition = i - kWorldLayerCount;
            [_world addChild:layer];
            [(NSMutableArray *)_layers addObject:layer];
        }
        
        [self addChild:_world];
        
        // Initialize player
//        [[TDPlayer localPlayer] setDisplayName:@"Remy"];
//        [[TDPlayer localPlayer] setRemainingLives:200];
        
        // Initialize the world + hud
		[self buildWorld];
        
        // Initialize the camera
        [[BMCamera sharedCamera] setWorld:_world];
        [[BMCamera sharedCamera] setDelegate:self];
        
        // Center the camera on the hero spawn point.
        [[BMCamera sharedCamera] setCameraToDefaultZoomLevel];
//        [[BMCamera sharedCamera] pointCameraToSpawn:self.defaultSpawnPoint];
        
        // Register to important notifications
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerLivesReachedZero:) name:kLocalPlayerLivesReachedZeroNotificationName object:nil];
    }
    
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNode:(SKNode *)node atWorldLayer:(BMWorldLayer)layer {
    SKNode *layerNode = self.layers[layer];
    [layerNode addChild:node];
}

- (void)didMoveToView:(SKView *)view {
    [self buildHUD];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panRecognizer.minimumNumberOfTouches = 1;
    panRecognizer.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tapRecognizer];
}

#pragma mark - World building

- (void) buildWorld {
    // Configure physics for the world.
    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f); // no gravity
    self.physicsWorld.contactDelegate = self;
    
    [self addBackgroundTiles];
    [self addSpawnPoints];
	
    self.world.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.world.calculateAccumulatedFrame];
//    self.world.physicsBody.categoryBitMask = kPhysicsCategory_World;
    self.world.physicsBody.collisionBitMask = 0; // collide with nothing
//    self.world.physicsBody.contactTestBitMask = kPhysicsCategory_Bullet;
}

- (void)addBackgroundTiles {
    self.backgroundMap = [[BMMapCache sharedCache] cachedMapForMapName:self.mapName];
    [self addNode:self.backgroundMap atWorldLayer:BMWorldLayerGround];
}

- (void)addSpawnPoints {
    self.spawnPoints = self.backgroundMap.spawnPoints;
    
    if (self.spawnPoints.count > 0) {
        self.defaultSpawnPoint = self.spawnPoints[0];
    }
}

#pragma mark - HUD and Scores

- (void) buildHUD {
    _hud = [[BMHudNode alloc] init];
    [self addChild:_hud];
    [_hud didMoveToScene];
}

#pragma mark - BMCameraDelegate

- (CGSize) actualMapSizeForCamera:(BMCamera *)camera {
    if (CGSizeEqualToSize(_cachedActualMapSize, CGSizeZero)) {
        _cachedActualMapSize = CGSizeMake(self.backgroundMap.tiledMap.mapSize.width * self.backgroundMap.tiledMap.tileSize.width, self.backgroundMap.tiledMap.mapSize.height * self.backgroundMap.tiledMap.tileSize.height);
    }
    
    return _cachedActualMapSize;
}

- (CGSize) mapSizeForCamera:(BMCamera *)camera {
    if (CGSizeEqualToSize(_cachedMapSizeForCamera, CGSizeZero)) {
        _cachedMapSizeForCamera = self.backgroundMap.tiledMap.calculateAccumulatedFrame.size;
    }
    return _cachedMapSizeForCamera;
}

#pragma mark - Position conversion

- (void) magnetizeMapObject:(BMMapObject *)object {
    CGPoint coord = [self tileCoordinatesForPositionInMap:object.position];
    object.position = [self tilePositionInMapForCoordinate:coord];
}

- (BMMapObject *) mapObjectAtPositionInMap:(CGPoint)position {
    position = [self convertPoint:position fromNode:self.world];
    
    __block BMMapObject *object = nil;
    
    [self.physicsWorld enumerateBodiesAtPoint:position usingBlock:^(SKPhysicsBody *body, BOOL *stop) {
//        if (body.categoryBitMask != kPhysicsCategory_BuildingRange && body.categoryBitMask != kPhysicsCategory_Bullet) {
//            if ([body.node isKindOfClass:[TDMapObject class]]) {
//                object = (TDMapObject *)body.node;
//            } else if ([body.node.parent isKindOfClass:[TDMapObject class]]) {
//                object = (TDMapObject *)body.node.parent;
//            }
//        }
    }];
    
    return object;
}

- (CGPoint) tileCoordinatesForPositionInMap:(CGPoint)position {
    return [self.backgroundMap tileCoordinatesForPosition:position];
}

- (CGPoint) tilePositionInMapForCoordinate:(CGPoint)position {
    return [self.backgroundMap tilePositionForCoordinate:position];
}

- (CGPoint) convertPointFromViewToMapPosition:(CGPoint)point {
    point = [self convertPointFromView:point];
    point = [self convertPoint:point toNode:self.world];
    return point;
}

- (void) convertCoordinatesArrayToPositionsInMapArray:(NSArray *)coords {
    [self.backgroundMap convertCoordinatesArrayToPositionsArray:coords];
}

#pragma mark - Loop Update
- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = kMinTimeInterval;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

- (void)updateWithTimeSinceLastUpdate:(NSTimeInterval)timeSinceLast {
    // Game logic
//    for (TDSpawn *spawnPoint in self.spawnPoints) {
//        [spawnPoint updateWithTimeSinceLastUpdate:timeSinceLast];
//    }
}
- (void)didSimulatePhysics {
	[super didSimulatePhysics];
	
    [[BMCamera sharedCamera] updateCameraTracking];
}

#pragma mark - Event Handling - iOS

- (void) handlePan:(UIPanGestureRecognizer *)pan {
    // get the translation info
    CGPoint trans = [pan translationInView:pan.view];
    
	// move the camera
	[[BMCamera sharedCamera] moveCameraBy:trans];
    
    // "reset" the translation
    [pan setTranslation:CGPointZero inView:pan.view];
}

- (void) handlePinch:(UIPinchGestureRecognizer *)pinch {
    BMCamera *camera = [BMCamera sharedCamera];
    
    static CGFloat startScale = 1;
    if (pinch.state == UIGestureRecognizerStateBegan)
    {
        startScale = camera.cameraZoomLevel;
    }
    CGFloat newScale = startScale * pinch.scale;
    [camera setCameraZoomLevel:newScale];
}

- (void) handleTap:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        CGPoint position = [tap locationInView:tap.view];
        position = [self convertPointFromViewToMapPosition:position];
		
        BMMapObject *tappedItem = [self mapObjectAtPositionInMap:position];
        
//        if ([tappedItem isKindOfClass:[TDBaseBuilding class]]) {
//            // Show popup?
//            NSLog(@"you tapped on a building (placed => %d, constructed => %d)", b.isPlaced, b.isConstructed);
//        } else if ([tappedItem isKindOfClass:[TDUnit class]]) {
//            // Tell towers to attack this unit?
//            NSLog(@"You tapped on unit #%ld", (long)((TDUnit *)tappedItem).uniqueID);
//        } else if (!tappedItem) { // if we just tapped on the world
//
//        }
    }
}

#pragma mark - Explorable world delegate

- (BOOL)isWalkable:(CGPoint)coordinates forExploringObject:(id<ExploringObjectDelegate>)exploringObject {
    BOOL walkable = YES;
    
    if (coordinates.x < 0 || coordinates.x > self.backgroundMap.tiledMap.mapSize.width - 1 || coordinates.y < 0 || coordinates.y > self.backgroundMap.tiledMap.mapSize.height - 1) {
        return NO;
    }
	
//#ifndef kTDGameScene_DISABLE_WALKABLE_CHECK
//    if (self.backgroundMap.mainLayer.layerInfo) {
//        TMXLayerInfo *layerInfo = self.backgroundMap.mainLayer.layerInfo;
//        
//        NSInteger gid = [layerInfo tileGidAtCoord:coordinates];
//        NSDictionary *props = [self.backgroundMap.tiledMap propertiesForGid:gid];
//        
//        if (props) {
//            if ([props[@"Walkable"] isEqualToString:@"YES"]) {
//                walkable = YES;
//            } else if (props[@"Walkable"]) {
//                walkable = NO;
//            }
//        }
//    }
//#endif
    
    return walkable;
}

- (NSUInteger)weightForTileAtPosition:(CGPoint)position {
    return 1;
}

#pragma mark - Physics Delegate
- (void)didBeginContact:(SKPhysicsContact *)contact {
    if ([contact.bodyA.node isKindOfClass:[BMMapObject class]]) {
        BMMapObject *objA = (BMMapObject *)contact.bodyA.node;
        [objA collidedWith:contact.bodyB contact:contact];
    }
    
    if ([contact.bodyB.node isKindOfClass:[BMMapObject class]]) {
        BMMapObject *objB = (BMMapObject *)contact.bodyB.node;
        [objB collidedWith:contact.bodyA contact:contact];
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    if ([contact.bodyA.node isKindOfClass:[BMMapObject class]]) {
        BMMapObject *objA = (BMMapObject *)contact.bodyA.node;
        [objA stoppedCollidingWith:contact.bodyB contact:contact];
    }
    
    if ([contact.bodyB.node isKindOfClass:[BMMapObject class]]) {
        BMMapObject *objB = (BMMapObject *)contact.bodyB.node;
        [objB stoppedCollidingWith:contact.bodyA contact:contact];
    }
}

#pragma mark - Shared Assets

+ (void)loadSceneAssetsForMapName:(NSString *)mapName withCompletionHandler:(BMAssetLoadCompletionHandler)handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // Load the shared assets in the background.
        [self.class loadSceneAssetsForMapName:mapName];
        
        if (!handler) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Call the completion handler back on the main queue.
            handler();
        });
    });
}

+ (void)loadSceneAssetsForMapName:(NSString *)mapName {
    // Preload the map
    [[BMMapCache sharedCache] preloadMapNamed:mapName];
    
    //TODO: Pre-calculate the pathfinding from spawn point
    
    //TODO: load monsters assets
}

+ (void)releaseSceneAssetsForMapName:(NSString *)mapName {
	[[BMMapCache sharedCache] invalidateCacheForMapNamed:mapName];
}

@end
