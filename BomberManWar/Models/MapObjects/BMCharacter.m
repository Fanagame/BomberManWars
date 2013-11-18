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
        
        hitBoxNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(hitBoxNode.calculateAccumulatedFrame.size.width * self.gameScene.world.xScale, hitBoxNode.calculateAccumulatedFrame.size.height * self.gameScene.world.yScale)];
        hitBoxNode.physicsBody.categoryBitMask = kPhysicsCategory_Character;
        hitBoxNode.physicsBody.collisionBitMask = kPhysicsCategory_Wall;
        hitBoxNode.physicsBody.allowsRotation = NO;
    }
}

#pragma mark - Collisions handling

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

#pragma mark - Public API

- (void) move:(BMDirection)direction {
    SKAction *moveAction = nil;
    
    if (direction != self.currentDirection) {
        self.currentDirection = direction;
        
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
        b.position = self.position;
        [self.gameScene addNode:b atWorldLayer:BMWorldLayerBelowCharacter];
        [b startTicking];
        [self.currentBombs addObject:b];
    }
}

- (void) die {
    if (self.state == kPlayerStateStandby) {
        [self removeAllActions];
        self.state = kPlayerStateDying;
        
        __weak BMCharacter *weakSelf = self;
        [self runAction:self.dyingAction completion:^{
            weakSelf.state = kPlayerStateStandby;
            weakSelf.currentDirection = kDirectionNone;
            [weakSelf runAction:[SKAction setTexture:[weakSelf defaultTexture]]];
        }];
    }
}

- (void) bombDidExplode:(NSNotification *)notification {
    if (notification.object) {
        [self.currentBombs removeObject:notification.object];
    }
}

@end
