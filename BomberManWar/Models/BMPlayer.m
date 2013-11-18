//
//  BMPlayer.m
//  BomberManWar
//
//  Created by Rémy Bardou on 15/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMPlayer.h"
#import "BMCharacter.h"

@implementation BMPlayer

static BMPlayer *_localPlayer;
+ (instancetype) localPlayer {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _localPlayer = [[BMPlayer alloc] init];
    });
    return _localPlayer;
}

#pragma mark - BMJoystick delegate

- (void) joystick:(BMJoystick *)joystick directionUpdated:(BMDirection)direction {
    [self.character move:direction];
}

@end
