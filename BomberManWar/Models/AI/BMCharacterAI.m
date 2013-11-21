//
//  BMCharacterAI.m
//  BomberManWar
//
//  Created by Remy Bardou on 11/18/13.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMCharacterAI.h"
#import "BMMapObject.h"
#import "BMSpawn.h"
#import "BMCharacter.h"
#import "BMPlayer.h"
#import "BMConstants.h"

@interface BMCharacterAI () {
    NSUInteger lastSpawnReached;
    CGPoint _lastKnownLocation;
    NSDate *_lastDropBombDate;
}

@end

@implementation BMCharacterAI

- (id) initWithCharacter:(BMMapObject *)character andTarget:(BMMapObject *)target {
    self = [super initWithCharacter:character andTarget:target];
    
    if (self) {
        self.moveNow = YES;
    }
    
    return self;
}

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [super updateWithTimeSinceLastUpdate:interval];
    
#ifdef CHAR_AI_ATTACK_PLAYER
    [self trackPlayer];
#else
    [self trackSpawnPoints];
#endif
    }

- (void) trackPlayer {
    BMCharacter *c = (BMCharacter *)self.character;
    
    BMPlayer *player = [BMPlayer localPlayer];
    self.target = player.character;
    
    CGFloat distance = [self distanceBetweenPointA:_lastKnownLocation andPointB:self.target.position];
    
    if (distance > 150 || self.moveNow) {
        self.moveNow = NO;
        _lastKnownLocation = self.target.position;
        // Update the pathfinding
        [c moveTo:self.target];
    }
    
    if (distance < 30 && (!_lastDropBombDate || (_lastDropBombDate && -[_lastDropBombDate timeIntervalSinceNow] > 5))) {
        _lastDropBombDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
        
        [c dropBomb];
    }
}

- (CGFloat) distanceBetweenPointA:(CGPoint)pointA andPointB:(CGPoint)pointB {
    // shortcut
    if (CGPointEqualToPoint(pointA, pointB)) {
        return 0;
    }
    
    CGFloat dx = pointA.x - pointB.x;
    CGFloat dy = pointA.y - pointB.y;
    dx = fabsf(dx);
    dy = fabs(dy);

    CGFloat distance = sqrt(dx * dx + dy * dy);
    
    return distance;
}

- (void) trackSpawnPoints {
    if (!self.target) {
        // look for a target
        BMCharacter *c = (BMCharacter *)self.character;
        
#ifdef CHAR_AI_CHOOSE_SPAWN_SEQUENCE
        lastSpawnReached++;
        if (lastSpawnReached + 1 > self.character.gameScene.spawnPoints.count) {
            lastSpawnReached = 0;
        }
#else
        lastSpawnReached = arc4random() % self.character.gameScene.spawnPoints.count;
#endif
        
        BMSpawn *spawnToReach = self.character.gameScene.spawnPoints[lastSpawnReached];
        
        self.target = spawnToReach;
        
        // Go reach the target!!
        [c moveTo:self.target];
    }
}

@end
