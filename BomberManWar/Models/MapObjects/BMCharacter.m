//
//  BMCharacter.m
//  BomberManWar
//
//  Created by Rémy Bardou on 15/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMCharacter.h"
#import "BMConstants.h"
#import "BMPlayer.h"
#import "BMBomb.h"
#import "BMCharacterAI.h"
#import "BMPathFinder.h"

NSInteger const kCharacterMovingSpeed = 100;
CFTimeInterval const kCharacterMovingDuration = 0.5;

@interface BMCharacter () {
    NSMutableArray *_walkingDownFrames;
    NSMutableArray *_walkingLeftFrames;
    NSMutableArray *_walkingUpFrames;
    NSMutableArray *_walkingRightFrames;
    NSMutableArray *_dyingFrames;
}

@property (nonatomic, strong) SKAction *leftMoveAction;
@property (nonatomic, strong) SKAction *rightMoveAction;
@property (nonatomic, strong) SKAction *upMoveAction;
@property (nonatomic, strong) SKAction *downMoveAction;
@property (nonatomic, strong) SKAction *dyingAction;

@end

@implementation BMCharacter

- (id) init {
	self = [super init];
	
	if (self) {
        self.currentBombs = [[NSMutableArray alloc] init];
        
        //
        // LOADING DYNAMIC DATA
        //
        
        self.maxDroppedBombs = 3;
        
        //
        // END LOADING DYNAMIC DATA
        //
        
        [self loadAnimations];
        
        [self updateDefaultSprite];
        self.size = [self defaultTexture].size;
        
		self.currentDirection = kDirectionNone;
//        self.hitBoxNode = [[SKSpriteNode alloc] initWithColor:[UIColor greenColor] size:CGSizeMake(self.size.width, self.size.height * 0.5)];
//        self.hitBoxNode.position = CGPointMake(0, -self.size.height * 0.25);
//        self.hitBoxNode.alpha = 0.5;
//        [self addChild:self.hitBoxNode];
        
        [self updatePhysics];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePhysics) name:kCameraZoomChangedNotificationName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bombDidExplode:) name:kBombExplodedNotificationName object:nil];
	}
	
	return self;
}

- (void) setPlayer:(BMPlayer *)player {
    _player = player;
    player.character = self;
    
    if (player.isAI) {
        self.intelligence = [[BMCharacterAI alloc] initWithCharacter:self andTarget:nil];
    }
}

- (void) setIsColorized:(BOOL)isColorized {
    if (_isColorized != isColorized) {
        _isColorized = isColorized;
        
        if (_isColorized) {
            self.color = [UIColor purpleColor];
            self.colorBlendFactor = 0.55;
        } else {
            self.color = [UIColor clearColor];
            self.colorBlendFactor = 0.0;
        }
    }
}

- (void) loadAnimations {
    _walkingDownFrames = [[NSMutableArray alloc] init];
    _walkingLeftFrames = [[NSMutableArray alloc] init];
    _walkingUpFrames   = [[NSMutableArray alloc] init];
    _walkingRightFrames = [[NSMutableArray alloc] init];
    _dyingFrames = [[NSMutableArray alloc] init];
    
    SKTextureAtlas *walkingAtlas = [SKTextureAtlas atlasNamed:@"HeroWalk"];
    for (int i = 1; i <= 7; i++) {
        SKTexture *t = nil;
        
        if (i <= 4) {
            t = [walkingAtlas textureNamed:[NSString stringWithFormat:@"hero_walk_down_%03d", i]];
            if (t)
                [_walkingDownFrames addObject:t];
            
            t = [walkingAtlas textureNamed:[NSString stringWithFormat:@"hero_walk_up_%03d", i]];
            if (t)
                [_walkingUpFrames addObject:t];
            
            t = [walkingAtlas textureNamed:[NSString stringWithFormat:@"hero_walk_left_%03d", i]];
            if (t)
                [_walkingLeftFrames addObject:t];
            
            t = [walkingAtlas textureNamed:[NSString stringWithFormat:@"hero_walk_right_%03d", i]];
            if (t)
                [_walkingRightFrames addObject:t];
        }
        
        t = [walkingAtlas textureNamed:[NSString stringWithFormat:@"hero_die_%03d", i]];
        if (t)
            [_dyingFrames addObject:t];
    }
}

- (void) updateDefaultSprite {
    [self runAction:[SKAction setTexture:[self defaultTexture]]];
    
    // maybe update physics
}

- (void) updatePhysics {
    if (self.gameScene.world) {
        SKNode *hitBoxNode = self;
        
        hitBoxNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hitBoxNode.physicsSize];
        hitBoxNode.physicsBody.categoryBitMask = kPhysicsCategory_Character;
        hitBoxNode.physicsBody.collisionBitMask = kPhysicsCategory_Wall;
#ifdef CHAR_LOCAL_PLAYER_IS_INVINCIBLE
        if (self.player != [BMPlayer localPlayer]) {
#endif
            hitBoxNode.physicsBody.contactTestBitMask = kPhysicsCategory_Deflagration;
#ifdef CHAR_LOCAL_PLAYER_IS_INVINCIBLE
        }
#endif
        hitBoxNode.physicsBody.allowsRotation = NO;
    }
}

#pragma mark - Collisions handling

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    if (!self.gameScene.isClient) {
        [super updateWithTimeSinceLastUpdate:interval];
    }
}

- (void) collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    [super collidedWith:body contact:contact];
    
    [self die];
}

- (void) stoppedCollidingWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {
    [super stoppedCollidingWith:body contact:contact];
}


#pragma mark - Cached actions

- (SKAction *) leftMoveAction {
    if (!_leftMoveAction) {
        _leftMoveAction = [SKAction group:@[[SKAction repeatActionForever:[SKAction moveByX:-kCharacterMovingSpeed y:0 duration:kCharacterMovingDuration]], [SKAction repeatActionForever:[SKAction animateWithTextures:_walkingLeftFrames timePerFrame:0.15]]]];
    }
    return _leftMoveAction;
}

- (SKAction *) rightMoveAction {
    if (!_rightMoveAction) {
        _rightMoveAction = [SKAction group:@[[SKAction repeatActionForever:[SKAction moveByX:kCharacterMovingSpeed y:0 duration:kCharacterMovingDuration]], [SKAction repeatActionForever:[SKAction animateWithTextures:_walkingRightFrames timePerFrame:0.15]]]];
    }
    return _rightMoveAction;
}

- (SKAction *) upMoveAction {
    if (!_upMoveAction) {
        _upMoveAction = [SKAction group:@[[SKAction repeatActionForever:[SKAction moveByX:0 y:kCharacterMovingSpeed duration:kCharacterMovingDuration]], [SKAction repeatActionForever:[SKAction animateWithTextures:_walkingUpFrames timePerFrame:0.15]]]];
    }
    return _upMoveAction;
}

- (SKAction *) downMoveAction {
    if (!_downMoveAction) {
        _downMoveAction = [SKAction group:@[[SKAction repeatActionForever:[SKAction moveByX:0 y:-kCharacterMovingSpeed duration:kCharacterMovingDuration]], [SKAction repeatActionForever:[SKAction animateWithTextures:_walkingDownFrames timePerFrame:0.15]]]];
    }
    return _downMoveAction;
}

- (SKAction *) dyingAction {
    if (!_dyingAction) {
        _dyingAction = [SKAction animateWithTextures:_dyingFrames timePerFrame:0.1];
    }
    return _dyingAction;
}

- (SKTexture *) defaultTexture {
    if (_walkingDownFrames.count > 0)
        return _walkingDownFrames[0];
    return nil;
}

- (CGPoint) bombPositionForBomb:(BMBomb *)bomb {
    CGPoint pos = self.position;
    
#ifdef CHAR_PLACE_BOMB_BEHIND
    switch (self.currentDirection) {
        case kDirectionUp:
            pos = CGPointMake(self.position.x, self.position.y - (self.size.height * self.anchorPoint.y) - (bomb.size.height * bomb.anchorPoint.y));
            break;
        case kDirectionLeft:
            pos = CGPointMake(self.position.x + (self.size.width * self.anchorPoint.x) + (bomb.size.width * bomb.anchorPoint.x), self.position.y);
            break;
        case kDirectionRight:
            pos = CGPointMake(self.position.x - (self.size.width * self.anchorPoint.x) - (bomb.size.width * bomb.anchorPoint.x), self.position.y);
            break;
        default:
            pos = CGPointMake(self.position.x, self.position.y + (self.size.height * self.anchorPoint.y) + (bomb.size.height * bomb.anchorPoint.y));
            break;
    }
#endif
    
    return pos;
}

#pragma mark - Public API

- (void) moveTo:(BMMapObject *)mapObject {
    if (self.state != kPlayerCalculatingPath) {
        self.state = kPlayerCalculatingPath;
        
        CGPoint selfCoord = [self.gameScene tileCoordinatesForPositionInMap:self.position];
        CGPoint destCoord = [self.gameScene tileCoordinatesForPositionInMap:mapObject.position];
        
        [[BMPathFinder sharedPathCache] pathInExplorableWorld:self.gameScene fromA:selfCoord toB:destCoord usingDiagonal:NO onSuccess:^(BMPath *path) {
            __weak BMCharacter *weakSelf = self;
            weakSelf.state = kPlayerStateStandby;

            if (path.positionsPathArray.count > 0) {
                NSMutableArray *moveActions = [[NSMutableArray alloc] init];
                for (PathNode *node in path.positionsPathArray) {
                    SKAction *action = [SKAction moveTo:node.position duration:0.5];
                    [moveActions addObject:action];
                }
                
                weakSelf.state = kPlayerStateMoving;
                [self runAction:[SKAction sequence:moveActions] completion:^{
                    weakSelf.intelligence.target = nil;
                    weakSelf.state = kPlayerStateStandby;
                }];
            } else {
                self.intelligence.target = nil;
            }
        }];
    }
}

- (void) moveToPosition:(CGPoint)newPosition {
    [self removeAllActions];
    [self runAction:[SKAction moveTo:newPosition duration:0.10]];
}

- (void) move:(BMDirection)direction {
    SKAction *moveAction = nil;
    
    if (direction != self.currentDirection) {
        self.currentDirection = direction;
        
        if (direction == kDirectionNone) {
            [self removeAllActions];
            return;
        }
        
        if (self.state == kPlayerStateStandby) {
            if (direction == kDirectionRight) {
                moveAction = self.rightMoveAction;
            } else if (direction == kDirectionLeft) {
                moveAction = self.leftMoveAction;
            } else if (direction == kDirectionUp) {
                moveAction = self.upMoveAction;
            } else if (direction == kDirectionDown) {
                moveAction = self.downMoveAction;
            }
            
            if (moveAction) {
                [self removeAllActions];
                [self runAction:moveAction];
            } else if (direction == kDirectionNone) {
                [self removeAllActions];
                [self updateDefaultSprite];
            }
        }
    }
}

- (void) dropBomb {
    if (self.state == kPlayerStateStandby || self.state == kPlayerStateMoving) {
        if (self.currentBombs.count >= self.maxDroppedBombs)
            return;
        
        BMBomb *b = [[BMBomb alloc] init];
        b.owner = self;
        b.position = [self bombPositionForBomb:b];
        [self.gameScene addNode:b atWorldLayer:BMWorldLayerBelowCharacter];
        [b updatePhysics];
        [b startTicking];
        [self.currentBombs addObject:b];
        
        if (self.gameScene.multiplayerEnabled)
            [self.gameScene sendPlantedBomb:b];
    }
}

- (void) die {
    if (self.state != kPlayerStateDying && self.state != kPlayerStateRespawning) {
        [self removeAllActions];
        self.state = kPlayerStateDying;
        
        __weak BMCharacter *weakSelf = self;
        [self runAction:self.dyingAction completion:^{
            weakSelf.state = kPlayerStateStandby;
            weakSelf.currentDirection = kDirectionNone;
            [weakSelf runAction:[SKAction setTexture:[weakSelf defaultTexture]]];
            weakSelf.intelligence.target = nil;
            
            [weakSelf.gameScene sync];
        }];
    }
}

- (void) bombDidExplode:(NSNotification *)notification {
    if (notification.object) {
        [self.currentBombs removeObject:notification.object];
    }
}

@end
