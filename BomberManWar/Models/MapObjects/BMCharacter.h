//
//  BMCharacter.h
//  BomberManWar
//
//  Created by Rémy Bardou on 15/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMMapObject.h"

typedef enum BMPlayerState : NSUInteger { kPlayerStateStandby, kPlayerStateDying, kPlayerStateRespawning, kPlayerStateMoving, kPlayerCalculatingPath } BMPlayerState;

@class BMSpawn, BMPlayer, BMMapObject, BMBomb;

@interface BMCharacter : BMMapObject

@property (nonatomic, assign) BMPlayerState		state;
@property (nonatomic, assign) BMDirection       currentDirection;
@property (nonatomic, assign) BOOL              isColorized;

@property (nonatomic, strong) SKSpriteNode      *hitBoxNode;
@property (nonatomic, readonly) SKAction        *leftMoveAction;
@property (nonatomic, readonly) SKAction        *rightMoveAction;
@property (nonatomic, readonly) SKAction        *upMoveAction;
@property (nonatomic, readonly) SKAction        *downMoveAction;

@property (nonatomic, strong) NSMutableArray	*currentBombs;
@property (nonatomic, assign) NSUInteger		maxDroppedBombs;

@property (nonatomic, weak) BMPlayer            *player;

//- (void) spawnAnimated:(BOOL)animated;
//- (void) spawn:(BMSpawn *)spawn;
//- (void) spawn:(BMSpawn *)spawn animated:(BOOL)animated;
- (void) dieFromBomb:(BMBomb *)bomb;
- (void) killFromServerSync;
- (void) dropBomb;
//- (void) shootBomb;
//- (void) grabBonus;
- (void) updateDirection:(BMDirection)direction; // server bound
- (void) moveToPosition:(CGPoint)newPosition;
- (void) moveTo:(BMMapObject *)mapObject;
- (void) move:(BMDirection)direction;

@end
