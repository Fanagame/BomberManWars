//
//  BMCharacter.h
//  BomberManWar
//
//  Created by Rémy Bardou on 15/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMMapObject.h"

typedef enum BMPlayerState : NSUInteger { kPlayerStateStandby, kPlayerStateDying, kPlayerStateRespawning, kPlayerStateMoving } BMPlayerState;

@class BMSpawn, BMPlayer;

@interface BMCharacter : BMMapObject

@property (nonatomic, assign) BMPlayerState		state;
@property (nonatomic, assign) BMDirection       currentDirection;

@property (nonatomic, strong) NSMutableArray	*currentBombs;
@property (nonatomic, assign) NSUInteger		maxDroppedBombs;

@property (nonatomic, weak) BMPlayer            *player;

//- (void) spawnAnimated:(BOOL)animated;
//- (void) spawn:(BMSpawn *)spawn;
//- (void) spawn:(BMSpawn *)spawn animated:(BOOL)animated;
//- (void) die;
//- (void) dropBomb;
//- (void) shootBomb;
//- (void) grabBonus;
- (void) move:(BMDirection)direction;

@end
