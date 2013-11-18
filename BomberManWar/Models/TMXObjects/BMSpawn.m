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
    self.maxCharacterSpawns = 1; // temp
    
    self.color = [UIColor redColor];
    self.intelligence = [[BMSpawnAI alloc] initWithCharacter:self andTarget:nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public API

- (void) spawnCharacterForPlayer:(BMPlayer *)player {
    BMCharacter *c = [[BMCharacter alloc] init];
    c.player = player;
    c.position = self.position;
    [self.gameScene addNode:c atWorldLayer:BMWorldLayerCharacter];
    player.character = c;
    
    if (![[BMCamera sharedCamera] trackingEnabled]) {
        [[BMCamera sharedCamera] pointCameraToCharacter:c trackingEnabled:YES];
    }
}

#pragma mark - Loop Update

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [super updateWithTimeSinceLastUpdate:interval];
}

@end
