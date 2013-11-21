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
#import "BMSpawn.h"
#import "BMPlayer.h"
#import "BMJoystick.h"
#import "BMCharacter.h"
#import "BMConstants.h"
#import "BMWall.h"
#import "BMConstants.h"
#import "BMMultiplayerManager.h"
#import "BMBomb.h"
#import "BMCharacter.h"

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
		
        // Register to important notifications
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerLivesReachedZero:) name:kLocalPlayerLivesReachedZeroNotificationName object:nil];
        
        // Setup the network data manager and start sending packets
        [self startupNetwork];
    }
    
    return self;
}

- (void) dealloc {
    [BMPlayer localPlayer].character = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNode:(SKNode *)node atWorldLayer:(BMWorldLayer)layer {
    SKNode *layerNode = self.layers[layer];
    [layerNode addChild:node];
}

- (void)didMoveToView:(SKView *)view {
    [self setupWorldLayers];
    [self setupPlayers];
    
    // Initialize the world + hud
    [self buildWorld];
    [self buildHUD];
    
    // Initialize the camera
    [[BMCamera sharedCamera] setWorld:_world];
    [[BMCamera sharedCamera] setDelegate:self];
    
    // Center the camera on the hero spawn point.
    [[BMCamera sharedCamera] setCameraToDefaultZoomLevel];
    
    [self setupGestureRecognizers];
}

#pragma mark - Network stuff

- (void) startupNetwork {
    self.retryTimeInterval = 1;
    self.timeIntervalPositionUpdate = 0.05;
    
    self.opponentsKnowingWereReady = [[NSMutableDictionary alloc] init];
    self.opponentsReady = [[NSMutableDictionary alloc] init];
    
    [[BMGameCenterManager currentSession] setDataDelegate:self];
}

- (void) sendGameIsReady {
    // The game won't start until we have received a 'game is ready' from everyone
    
    // Do not send the game is ready packet once
    if (!self.opponentsKnowWereReady) {
        if (!self.lastTryDate || (self.lastTryDate && -[self.lastTryDate timeIntervalSinceNow] >= self.retryTimeInterval)) {
            self.lastTryDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
            [self sendPacket:kPacketTypeGameReadyAnnouncement withBlob:nil toPlayerIds:[self playerIdsNotKnowingWereReady]];
        }
    }
}

- (void) killCharacter:(BMCharacter *)character {
    if (self.multiplayerEnabled) {
        NSMutableDictionary *blob = [[NSMutableDictionary alloc] init];
        blob[@"character_owner_id"] = character.player.gameCenterId;
        blob[@"character_position"] = [NSValue valueWithCGPoint:character.position];
        
        [self sendPacket:kPacketTypeCharacterDied withBlob:blob fastMode:NO toPlayerIds:nil];
    }
}

- (void) updatePlayersPosition {
    // when was the last update?
    if (-[self.lastTryDate timeIntervalSinceNow] > self.timeIntervalPositionUpdate && [[BMPlayer localPlayer] hasPendingUpdates]) {
       
        // Now send the packet
        [self sendPacket:kPacketTypeUpdatePosition withBlob:[[BMPlayer localPlayer] dictionaryRepresentation] fastMode:YES];
        
        self.lastTryDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    }
}

- (void) sendPlantedBomb:(BMBomb *)bomb {
    // build a blob
    NSDictionary *blob = [bomb dictionaryRepresentation];
    
    // now send the packet
    [self sendPacket:kPacketTypeBombPlanted withBlob:blob fastMode:NO];
}

- (void) sendPacket:(BMPacketType)packetType withBlob:(NSDictionary *)blob {
    [self sendPacket:packetType withBlob:blob toPlayerIds:nil];
}

- (void) sendPacket:(BMPacketType)packetType withBlob:(NSDictionary *)blob toPlayerIds:(NSArray *)playerIds {
    [self sendPacket:packetType withBlob:blob fastMode:NO];
}

- (void) sendPacket:(BMPacketType)packetType withBlob:(NSDictionary *)blob fastMode:(BOOL)fastMode {
    [self sendPacket:packetType withBlob:blob fastMode:fastMode toPlayerIds:nil];
}

- (void) sendPacket:(BMPacketType)packetType withBlob:(NSDictionary *)blob fastMode:(BOOL)fastMode toPlayerIds:(NSArray *)playerIds {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BMGameCenterManager *gc = [BMGameCenterManager currentSession];
        
        NSData *hello = [[BMMultiplayerPacket packetWithType:packetType andBlob:blob] dataRepresentation];
        NSError *error = nil;
        
        if (playerIds.count > 0) {
            if (![gc.match sendData:hello toPlayers:playerIds withDataMode:(fastMode ? GKMatchSendDataUnreliable : GKMatchSendDataReliable) error:&error]) {
                if (error) {
                    NSLog(@"ERROR: %@", error);
                }
            }
        }
        
        if (![gc.match sendDataToAllPlayers:hello withDataMode:(fastMode ? GKMatchSendDataUnreliable : GKMatchSendDataReliable) error:&error]) {
            if (error) {
                NSLog(@"ERROR: %@", error);
            }
        }
    });
}

- (void) sync {
    if (self.multiplayerEnabled) {
        // Let's send the hero list and their position
        NSMutableDictionary *blob = [[NSMutableDictionary alloc] init];
        NSMutableArray *playersBlob = [[NSMutableArray alloc] init];
        
        for (BMPlayer *p in self.players) {
            NSDictionary *hostPlayerInfo = [p dictionaryRepresentation];
            [playersBlob addObject:hostPlayerInfo];
        }
        blob[@"players"] = playersBlob;
        
        
        // Now send the packet
        [self sendPacket:kPacketTypeSync withBlob:blob];
    }
}

- (void) match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    
    // handle game updates
    
    BMMultiplayerPacket *packet = [BMMultiplayerPacket packetWithData:data];
    NSString *deviceName = [UIDevice currentDevice].name;
    
    if (packet.packetType == kPacketTypeGameReadyAnnouncement) {
//        if (self.opponentsReady[playerID] && ![self.opponentsReady[playerID] boolValue]) {
            NSLog(@"Received kPacketTypeGameReadyAnnouncement on %@ for %@", deviceName, playerID);
            self.opponentsReady[playerID] = [NSNumber numberWithBool:YES];
            [self sendPacket:kPacketTypeGameReadyAcknowledgment withBlob:nil toPlayerIds:@[playerID]];
//        } else {
//            NSLog(@"Ignoring kPacketTypeGameReadyAnnouncement replay on %@ from %@", deviceName, playerID);
//        }
    } else if (packet.packetType == kPacketTypeGameReadyAcknowledgment) {
//        if (self.opponentsKnowingWereReady[playerID] && ![self.opponentsKnowingWereReady[playerID] boolValue]) {
            NSLog(@"Received kPacketTypeGameReadyAcknowledgment on %@ for %@", deviceName, playerID);
            self.opponentsKnowingWereReady[playerID] = [NSNumber numberWithBool:YES];
            
            // The server syncs to the send client the initial data
            if (!self.isClient)
                [self sync];
//        } else {
//            NSLog(@"Ignoring kPacketTypeGameReadyAcknowledgment replay on %@ from %@", deviceName, playerID);
//        }
    } else if (packet.packetType == kPacketTypeSync) {
        NSLog(@"Received kPacketTypeSync on %@ from %@", deviceName, playerID);
        [self handlePacketBlob:packet.blob];
        self.firstSyncIsDone = YES;
    } else if (packet.packetType == kPacketTypeUpdatePosition) {
        [self handleUpdatePosition:packet.blob];
    } else if (packet.packetType == kPacketTypeBombPlanted) {
        NSLog(@"Received kPacketTypeBombPlanted on %@ from %@", deviceName, playerID);
        [self handleBombPlanted:packet.blob];
    } else if (packet.packetType == kPacketTypeCharacterDied) {
        NSLog(@"Received kPacketTypeCharacterDied on %@ from %@", deviceName, playerID);
        [self handleCharacterDied:packet.blob];
    }
    else {
        NSLog(@"Unknown packet received on %@ from %@: %d", deviceName, playerID, packet.packetType);
    }
}

- (void) handleCharacterDied:(NSDictionary *)blob {
    BMPlayer *player = [self playerForGameCenterId:blob[@"character_owner_id"]];
    [player.character moveToPosition:[blob[@"character_position"] CGPointValue]];
    [player.character killFromServerSync];
}

- (void) handleBombPlanted:(NSDictionary *)blob {
    BMBomb *b = [[BMBomb alloc] init];
    [b updateFromDictionary:blob];
    
    // Now we need to attach it to the right player AND add the node to the world
    BMPlayer *owner = [self playerForGameCenterId:blob[@"bomb_owner_id"]];
    [self addNode:b atWorldLayer:BMWorldLayerBelowCharacter];
    [b updatePhysics];
    b.owner = owner.character;
    [b.owner.currentBombs addObject:b];
    
}

- (void) handleUpdatePosition:(NSDictionary *)playerBlob {
    if ([playerBlob isKindOfClass:[NSDictionary class]]) {
        BMPlayer *player = [self playerForGameCenterId:playerBlob[@"gameCenterId"]];
        
        if (!player) {
            NSLog(@"Not player found locally for game center id: %@", playerBlob[@"gameCenterId"]);
        }
        [player updateWithBlob:playerBlob];
    }
}

- (void) handlePacketBlob:(NSDictionary *)blob {
    if (blob) {
        if ([blob[@"players"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *playerBlob in blob[@"players"]) {
                BMPlayer *player = [self playerForGameCenterId:playerBlob[@"gameCenterId"]];
                
                if (!player) {
                    NSLog(@"Not player found locally for game center id: %@", playerBlob[@"gameCenterId"]);
                }
                [player updateWithBlob:playerBlob];
            }
            [self.hud updateScores];
        } else {
            NSLog(@"players key is not an array");
        }
    } else {
        NSLog(@"Can't handle empty blob");
    }
}

- (BMPlayer *) playerForGameCenterId:(NSString *)gameCenterId {
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[BMPlayer class]]) {
            BMPlayer *p = (BMPlayer *)evaluatedObject;
            
            if ([p.gameCenterId isEqualToString:gameCenterId]) {
                return YES;
            }
        }
        return NO;
    }];
    
    NSArray *res = [self.players filteredArrayUsingPredicate:filter];
    
    if (res.count > 0) {
        return res[0];
    }
    return nil;
}

- (NSArray *) playerIdsNotReady {
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSNumber *n = self.opponentsReady[evaluatedObject];
        return ![n boolValue];
    }];
    
    return [self.opponentsReady.allKeys filteredArrayUsingPredicate:filter];
}

- (NSArray *) playerIdsNotKnowingWereReady {
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSNumber *n = self.opponentsKnowingWereReady[evaluatedObject];
        return ![n boolValue];
    }];
    
    return [self.opponentsKnowingWereReady.allKeys filteredArrayUsingPredicate:filter];
}

- (BOOL) opponentsAreReady {
    return ([[self playerIdsNotReady] count] == 0);
}

- (BOOL) opponentsKnowWereReady {
    return ([[self playerIdsNotKnowingWereReady] count] == 0);
}

#pragma mark - Setup

- (void) setupWorldLayers {
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
}

- (void) setupPlayers {
    // Initialize player
    self.players = [[NSMutableArray alloc] init];
    BMPlayer *p = [BMPlayer localPlayer];
    [[BMJoystick localPlayerJoystick] setDelegate:p];
    
    if (self.multiplayerEnabled && self.localGameCenterPlayer) {
        p.displayName = self.localGameCenterPlayer.alias;
        p.gameCenterId = self.localGameCenterPlayer.playerID;
        [self.players addObject:p];
        
        for (GKPlayer *gkPlayer in self.gameCenterPlayers) {
            BMPlayer *pl = [[BMPlayer alloc] init];
            pl.displayName = gkPlayer.alias;
            pl.gameCenterId = gkPlayer.playerID;
            self.opponentsReady[pl.gameCenterId] = [NSNumber numberWithBool:NO];
            self.opponentsKnowingWereReady[pl.gameCenterId] = [NSNumber numberWithBool:NO];
            [self.players addObject:pl];
        }
    } else {
        p.displayName = @"Remy (SOLO GAME)";
        [self.players addObject:p];
        
        /*
         * FAKE OTHER PLAYERS
         */
        BMPlayer *p2 = [[BMPlayer alloc] init];
        p2.displayName = @"Player2 (AI)";
        p2.isAI = YES;
        [self.players addObject:p2];
        /*
         * END FAKE OTHER PLAYERS
         */
    }
}

- (void) setupGestureRecognizers {
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
    [self addWalls];
	
//    self.world.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.world.calculateAccumulatedFrame];
//    self.world.physicsBody.categoryBitMask = kPhysicsCategory_World;
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

- (void)addWalls {
    self.walls = self.backgroundMap.walls;
}

#pragma mark - HUD and Scores

- (void) buildHUD {
    _hud = [[BMHudNode alloc] init];
    _hud.players = self.players;
    [self addChild:_hud];
    [_hud didMoveToScene];
    
    // Initialize joystick
    [[BMJoystick localPlayerJoystick] setEnabled:YES];
#ifdef SHOW_JOYSTICK
    [self addChild:[BMJoystick localPlayerJoystick]];
#endif
}

#pragma mark - Player management

- (NSUInteger) playersWithCharacterOnMapCount {
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[BMPlayer class]]) {
            BMPlayer *p = (BMPlayer *)evaluatedObject;
            if (p.character) {
                return YES;
            }
        }
        return NO;
    }];
    
    return [[self.players filteredArrayUsingPredicate:filter] count];
}

- (NSArray *) playersWithoutCharactersOnMap {
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[BMPlayer class]]) {
            BMPlayer *p = (BMPlayer *)evaluatedObject;
            if (!p.character) {
                return YES;
            }
        }
        return NO;
    }];
    
    return [self.players filteredArrayUsingPredicate:filter];
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

- (CGPoint) offsetMapDimension {
    return CGPointMake(0, -60);
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
        object = (BMMapObject *)body.node;
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
    
    // The server doesn't actually start the game until we know that the opponent is ready
//    if (!self.isClient /* && self.opponentIsReady*/) {
        for (BMSpawn *spawnPoint in self.spawnPoints) {
            [spawnPoint updateWithTimeSinceLastUpdate:timeSinceLast];
        }
        
        for (BMPlayer *player in self.players) {
            [player.character updateWithTimeSinceLastUpdate:timeSinceLast];
        }
//    }
}
- (void)didSimulatePhysics {
	[super didSimulatePhysics];
	
    [[BMCamera sharedCamera] updateCameraTracking];
    
    if (self.multiplayerEnabled) {
        [self sendGameIsReady];
        [self updatePlayersPosition];
    }
}

#pragma mark - Event Handling - iOS

- (void) handlePan:(UIPanGestureRecognizer *)pan {
    
    // Controls are ignored until the other player isn't ready
    if (!self.multiplayerEnabled || (self.opponentsAreReady && self.opponentsKnowWereReady && ((self.isClient && self.firstSyncIsDone) || !self.isClient))) {
        if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateFailed || pan.state == UIGestureRecognizerStateCancelled) {
            [BMJoystick localPlayerJoystick].hidden = YES;
        } else {
            // get the translation info
            CGPoint trans = [pan translationInView:pan.view];
            
            // Update the joystick
            [BMJoystick localPlayerJoystick].hidden = NO;
            [[BMJoystick localPlayerJoystick] updateDirectionWithTranslation:trans];
        }
    } else {
        // get the translation info
        CGPoint trans = [pan translationInView:pan.view];
        
        // move the camera
        [[BMCamera sharedCamera] moveCameraBy:trans];
        
        // "reset" the translation
        [pan setTranslation:CGPointZero inView:pan.view];
    }
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
//    if (tap.state == UIGestureRecognizerStateEnded) {
//        CGPoint position = [tap locationInView:tap.view];
//        position = [self convertPointFromViewToMapPosition:position];
		
//        BMMapObject *tappedItem = [self mapObjectAtPositionInMap:position];
        
//        if ([tappedItem isKindOfClass:[TDBaseBuilding class]]) {
//            // Show popup?
//            NSLog(@"you tapped on a building (placed => %d, constructed => %d)", b.isPlaced, b.isConstructed);
//        } else if ([tappedItem isKindOfClass:[TDUnit class]]) {
//            // Tell towers to attack this unit?
//            NSLog(@"You tapped on unit #%ld", (long)((TDUnit *)tappedItem).uniqueID);
//        } else if (!tappedItem) { // if we just tapped on the world
//
//        }
//    }
}

#pragma mark - Explorable world delegate

- (BOOL)isWalkable:(CGPoint)coordinates forExploringObject:(id<ExploringObjectDelegate>)exploringObject {
    BOOL walkable = YES;
    
    if (coordinates.x < 0 || coordinates.x > self.backgroundMap.tiledMap.mapSize.width - 1 || coordinates.y < 0 || coordinates.y > self.backgroundMap.tiledMap.mapSize.height - 1) {
        return NO;
    }
    
    CGPoint pos = [self tilePositionInMapForCoordinate:coordinates];
    CGPoint scenePos = [self convertPoint:pos fromNode:self.world];
    
    SKPhysicsBody *body = [self.physicsWorld bodyAtPoint:scenePos];
    if (body && body.categoryBitMask == kPhysicsCategory_Wall) {
        walkable = NO;
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
