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
#import "BMConstants.h"

@interface BMCharacterAI () {
    NSUInteger lastSpawnReached;
}

@end

@implementation BMCharacterAI

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [super updateWithTimeSinceLastUpdate:interval];
    
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
