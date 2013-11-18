//
//  TDSpawn.m
//  CoopTD
//
//  Created by Remy Bardou on 10/19/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "BMSpawn.h"
#import "BMSpawnAI.h"
#import "BMCharacter.h"
#import "BMPlayer.h"
#import "BMCamera.h"

@implementation BMSpawn

- (void) setup {
    self.color = [UIColor redColor];
    self.intelligence = [[BMSpawnAI alloc] initWithCharacter:self andTarget:nil];
}

#pragma mark - Public API

- (void) spawnCharacterForPlayer:(BMPlayer *)player {
    BMCharacter *c = [[BMCharacter alloc] init];
    c.player = player;
    c.position = self.position;
    [self.gameScene addNode:c atWorldLayer:BMWorldLayerCharacter];
    
    if (![[BMCamera sharedCamera] trackingEnabled] && player == [BMPlayer localPlayer]) {
        [[BMCamera sharedCamera] pointCameraToCharacter:c trackingEnabled:YES];
    }
}

#pragma mark - Loop Update

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [super updateWithTimeSinceLastUpdate:interval];
}

@end
