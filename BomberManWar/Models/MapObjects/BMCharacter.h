//
//  BMCharacter.h
//  BomberManWar
//
//  Created by Rémy Bardou on 15/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMMapObject.h"

typedef enum BMPlayerState : NSUInteger { kPlayerStateStandby, kPlayerStateDying, kPlayerStateRespawning, kPlayerStateMoving } BMPlayerState;

@class BMSpawn;

@interface BMCharacter : BMMapObject

@property (nonatomic, assign) BMPlayerState		state;

@property (nonatomic, strong) NSMutableArray	*currentBombs;
@property (nonatomic, assign) NSUInteger		maxDroppedBombs;

- (void) spawnAnimated:(BOOL)animated;
- (void) spawn:(BMSpawn *)spawn;
- (void) spawn:(BMSpawn *)spawn animated:(BOOL)animated;
- (void) die;
- (void) dropBomb;
- (void) shootBomb;
- (void) grabBonus;
//- (void) move:(BMDirection)direction; // direction comes from the joystick object

@end
