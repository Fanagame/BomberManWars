//
//  BMPlayer.m
//  BomberManWar
//
//  Created by Rémy Bardou on 15/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMPlayer.h"
#import "BMCharacter.h"
#import "BMHudNode.h"
#import "BMMultiplayerManager.h"
#import "BMCamera.h"

@interface BMPlayer ()

@property (nonatomic, assign) CGPoint lastPositionSentToPeers;

@end

@implementation BMPlayer

static BMPlayer *_localPlayer;
+ (instancetype) localPlayer {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _localPlayer = [[BMPlayer alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:_localPlayer selector:@selector(didTapDropBombButton) name:kHUDDropBombButtonPressedNotificationName object:nil];
    });
    return _localPlayer;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSDictionary *) dictionaryRepresentation {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    dic[@"gameCenterId"] = self.gameCenterId;
    dic[@"score"] = [NSNumber numberWithInteger:self.score];
    dic[@"remainingLives"] = [NSNumber numberWithInteger:self.remainingLives];
    dic[@"character_position"] = [NSValue valueWithCGPoint:self.character.position];
    dic[@"character_colorized"] = [NSNumber numberWithBool:(self == [BMPlayer localPlayer] ? NO : YES)];
    
    self.lastPositionSentToPeers = self.character.position;
    
    return dic;
}

- (void) updateWithBlob:(NSDictionary *)blob {
    NSLog(@"updateWithBlob");
//    NSLog(@"before update: %@", self);
    self.score = [blob[@"score"] integerValue];
    self.remainingLives = [blob[@"remainingLives"] integerValue];
    
    self.character.isColorized = [blob[@"character_colorized"] boolValue];
    
    if (blob[@"character_position"]) {
        [self.character moveToPosition:[((NSValue *)blob[@"character_position"]) CGPointValue]];
        self.character.hidden = NO;
    } else {
        self.character.hidden = YES;
    }
    
    [self.character updatePhysics];
//    NSLog(@"after update: %@", self);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"id: %@ | score: %d | lives: %d | position: (%f, %f)", self.gameCenterId, self.score, self.remainingLives, self.character.position.x, self.character.position.y];
}

//TODO: allow a range of values?
- (BOOL) hasPendingUpdates {
    if (CGPointEqualToPoint(self.character.position, self.lastPositionSentToPeers)) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - HUD delegate 

- (void) didTapDropBombButton {
    if (self.character && self.character.parent) {
        [self.character dropBomb];
    }
}

#pragma mark - BMJoystick delegate

- (void) joystick:(BMJoystick *)joystick directionUpdated:(BMDirection)direction {
    [self.character move:direction];
}

@end
