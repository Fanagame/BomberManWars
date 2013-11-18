//
//  TDSpawn.h
//  CoopTD
//
//  Created by Remy Bardou on 10/19/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "BMTMXObject.h"

@class BMPlayer, BMCharacter;

@interface BMSpawn : BMTMXObject

@property (nonatomic, weak) BMCharacter *character;

- (void) spawnCharacterForPlayer:(BMPlayer *)player;

@end
