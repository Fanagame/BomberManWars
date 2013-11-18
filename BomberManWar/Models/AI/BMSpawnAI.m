//
//  BMSpawnAI.m
//  BomberManWar
//
//  Created by Remy Bardou on 11/15/13.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMSpawnAI.h"
#import "BMSpawn.h"

@implementation BMSpawnAI

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [super updateWithTimeSinceLastUpdate:interval];
    
    if ([self.character isKindOfClass:[BMSpawn class]]) {
        BMSpawn *sp = (BMSpawn *)self.character;
        
        // TEMP
        if (sp.maxCharacterSpawns > [sp.gameScene playersWithCharacterOnMapCount]) {
            NSArray *playersToSpawn = [sp.gameScene playersWithoutCharactersOnMap];
            BMPlayer *nextPlayer = [playersToSpawn lastObject];
            
            if (nextPlayer) {
                [sp spawnCharacterForPlayer:nextPlayer];
            }
        }
    }
}

@end
